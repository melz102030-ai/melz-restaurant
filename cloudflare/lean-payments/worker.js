// دفع مباشر من الحساب البنكي عبر لين (Lean Technologies — Payment Initiation
// Service) — Cloudflare Workers، بنفس أسلوب worker حذف صور Cloudinary
// (cloudflare/worker.js): لا سر حسّاس يمر عبر تطبيق العميل، ولا حاجة لخطة
// Firebase Blaze المدفوعة.
//
// مساران:
//   POST /            — العميل يطلب فتح "نية دفع" لطلبه الحالي
//   POST /webhook      — لين يُخطر بنتيجة الدفع (نجاح/فشل) بعد إتمامها فعلياً
//
// التوثيق:
// - القراءة (جلب الطلب): نمرّر توكن Firebase الذي أرسله العميل مباشرة إلى
//   Firestore REST API — هي من تتحقق من التوقيع وتمنع أي عميل من قراءة/دفع
//   طلب ليس له (قاعدة الأمان customerId == uid في firestore.rules).
// - الكتابة (حفظ رقم نية الدفع، تحديث حالة الدفع بعد الويبهوك): تتجاوز
//   قواعد أمان العميل العادي (لا يملك صلاحية تعديل هذه الحقول أصلاً)، فتتم
//   عبر حساب خدمة Firebase (Service Account) — بالضبط كعمل Admin SDK من
//   خادم موثوق، بمعزل تام عن هوية العميل.
//
// ⚠️ ملاحظة صريحة: شكل حمولة webhook الدقيق (أسماء الحقول) غير موثَّق علناً
// بالكامل من لين وقت كتابة هذا الكود — لذلك لا نثق بحقل الحالة داخل الحمولة
// نفسها، بل نُعيد جلب "نية الدفع" الرسمية من واجهة لين بمعرّفها كمصدر الحقيقة
// الوحيد للحالة الفعلية. يلزم اختبار حقيقي واحد على الأقل في Sandbox للتأكد
// من قيم status الفعلية القادمة داخل مصفوفة payments، وتحديث المطابقة أدناه
// إن لزم.

import { priceOrder, removeUnavailableItems, setOptionAvailability, OrderRejected, customerContact } from "./pricing.js";
import { canDeleteUser, canReclaimStaffAccount, canResetStaffPassword } from "./staff.js";

const CORS_HEADERS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
  "Access-Control-Allow-Headers": "Authorization, Content-Type",
};

function json(obj, status = 200) {
  return new Response(JSON.stringify(obj), {
    status,
    headers: { "Content-Type": "application/json", ...CORS_HEADERS },
  });
}

function decodeUid(idToken) {
  try {
    const payload = idToken.split(".")[1];
    const b64 = payload.replace(/-/g, "+").replace(/_/g, "/");
    const decoded = JSON.parse(atob(b64));
    return decoded.user_id || decoded.sub || null;
  } catch {
    return null;
  }
}

// نطاق لين مخصَّص للسعودية (kababjik مسجَّل عليه) — مختلف عن النطاق العام
// الافتراضي (leantech.me بدون .sa.) المستخدم لدول أخرى؛ استخدام النطاق
// الخطأ يرفض أي app_token/client_secret صحيحين بخطأ invalid_client مضلِّل
function leanBaseUrl(env) {
  return env.LEAN_ENV === "production"
    ? "https://sa.leantech.me"
    : "https://sandbox.sa.leantech.me";
}

function leanAuthUrl(env) {
  return env.LEAN_ENV === "production"
    ? "https://auth.sa.leantech.me/oauth2/token"
    : "https://auth.sandbox.sa.leantech.me/oauth2/token";
}

// توكن وصول لين (OAuth client_credentials) — نطلبه من جديد كل استدعاء؛ خفيف
// ولا يستحق تعقيد تخزين مؤقت عبر Workers KV بحجم استخدام مطعم واحد أو بضعة
async function getLeanAccessToken(env) {
  const res = await fetch(leanAuthUrl(env), {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      client_id: env.LEAN_APP_TOKEN,
      client_secret: env.LEAN_CLIENT_SECRET,
      grant_type: "client_credentials",
      scope: "api",
    }),
  });
  if (!res.ok) throw new Error(`lean-auth-failed: ${await res.text()}`);
  const data = await res.json();
  return data.access_token;
}

// PEM → ArrayBuffer، لازمة لاستيراد المفتاح الخاص لحساب خدمة Firebase
function pemToArrayBuffer(pem) {
  const b64 = pem
    .replace(/-----BEGIN PRIVATE KEY-----/, "")
    .replace(/-----END PRIVATE KEY-----/, "")
    .replace(/\s+/g, "");
  const raw = atob(b64);
  const buf = new Uint8Array(raw.length);
  for (let i = 0; i < raw.length; i++) buf[i] = raw.charCodeAt(i);
  return buf.buffer;
}

function base64url(input) {
  const str =
    typeof input === "string"
      ? btoa(input)
      : btoa(String.fromCharCode(...new Uint8Array(input)));
  return str.replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/, "");
}

// توكن وصول Google بصلاحية إدارية (Service Account JWT bearer) — للكتابة
// على Firestore متجاوزاً قواعد أمان العميل، تماماً كعمل Admin SDK
// اختبارات الرحلة (e2e/) تضبط هذا المتغير فقط، فيعمل الخادم على المحاكي المحلي بدل
// Firestore الحقيقي. لا يوجد في النشر (wrangler.toml)، فلا أثر له على الموقع.
const firestoreOrigin = (env) => env.FIRESTORE_EMULATOR_ORIGIN || "https://firestore.googleapis.com";

async function getFirestoreAdminToken(env, scope = "https://www.googleapis.com/auth/datastore") {
  if (env.FIRESTORE_EMULATOR_ORIGIN) return "owner"; // صلاحية المدير في المحاكي
  const sa = JSON.parse(env.FIREBASE_SERVICE_ACCOUNT_JSON);
  const now = Math.floor(Date.now() / 1000);
  const header = { alg: "RS256", typ: "JWT" };
  const claims = {
    iss: sa.client_email,
    scope,
    aud: "https://oauth2.googleapis.com/token",
    iat: now,
    exp: now + 3600,
  };
  const unsigned = `${base64url(JSON.stringify(header))}.${base64url(JSON.stringify(claims))}`;
  const key = await crypto.subtle.importKey(
    "pkcs8",
    pemToArrayBuffer(sa.private_key),
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
    false,
    ["sign"]
  );
  const sig = await crypto.subtle.sign(
    "RSASSA-PKCS1-v1_5",
    key,
    new TextEncoder().encode(unsigned)
  );
  const jwt = `${unsigned}.${base64url(sig)}`;

  const res = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion: jwt,
    }),
  });
  if (!res.ok) throw new Error(`firebase-admin-auth-failed: ${await res.text()}`);
  const data = await res.json();
  return data.access_token;
}

async function patchOrder(env, orderId, fields, adminToken) {
  const token = adminToken || (await getFirestoreAdminToken(env));
  const mask = Object.keys(fields)
    .map((f) => `updateMask.fieldPaths=${f}`)
    .join("&");
  const url = `${firestoreOrigin(env)}/v1/projects/${env.FIREBASE_PROJECT_ID}/databases/(default)/documents/orders/${orderId}?${mask}`;
  const body = {
    fields: Object.fromEntries(
      Object.entries(fields).map(([k, v]) => [
        k,
        typeof v === "number" ? { doubleValue: v } : { stringValue: v },
      ])
    ),
  };
  const res = await fetch(url, {
    method: "PATCH",
    headers: { Authorization: `Bearer ${token}`, "Content-Type": "application/json" },
    body: JSON.stringify(body),
  });
  if (!res.ok) throw new Error(`firestore-patch-failed: ${await res.text()}`);
}

async function handleCreatePayment(request, env) {
  const authHeader = request.headers.get("Authorization") || "";
  const idToken = authHeader.replace(/^Bearer\s+/i, "").trim();
  if (!idToken) return json({ error: "unauthenticated" }, 401);
  const uid = decodeUid(idToken);
  if (!uid) return json({ error: "unauthenticated" }, 401);

  let orderId;
  try {
    ({ orderId } = await request.json());
  } catch {
    return json({ error: "invalid-body" }, 400);
  }
  if (!orderId || typeof orderId !== "string") {
    return json({ error: "orderId-required" }, 400);
  }

  // جلب الطلب بتوكن العميل نفسه — Firestore ترفض أي طلب ليس ملكه فعلياً
  const orderRes = await fetch(
    `${firestoreOrigin(env)}/v1/projects/${env.FIREBASE_PROJECT_ID}/databases/(default)/documents/orders/${orderId}`,
    { headers: { Authorization: `Bearer ${idToken}` } }
  );
  if (!orderRes.ok) return json({ error: "order-not-found-or-forbidden" }, 403);
  const orderDoc = await orderRes.json();
  const totalField = orderDoc.fields?.total;
  const total = parseFloat(totalField?.doubleValue ?? totalField?.integerValue ?? "0");
  if (!total || total <= 0) return json({ error: "invalid-order-total" }, 400);

  try {
    const leanToken = await getLeanAccessToken(env);
    const base = leanBaseUrl(env);

    // app_user_id يمنع لين من إنشاء عميل مكرَّر لنفس المستخدم — لكن خلافاً
    // لما افترضناه أول مرة، لين ليست idempotent هنا: تطلب الإنشاء مرة
    // ثانية لنفس app_user_id يُرفض صراحة بـ CUSTOMER_ALREADY_EXISTS بدل
    // إعادة العميل الموجود، فنحتاج جلبه صراحة في هذه الحالة تحديداً
    let customerId;
    const custRes = await fetch(`${base}/customers/v1`, {
      method: "POST",
      headers: {
        Authorization: `Bearer ${leanToken}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({ app_user_id: uid }),
    });
    const custData = await custRes.json();
    if (custRes.ok) {
      customerId = custData.customer_id || custData.id;
    } else if (custData.status === "CUSTOMER_ALREADY_EXISTS") {
      const lookupRes = await fetch(`${base}/customers/v1/app-user-id/${uid}`, {
        headers: { Authorization: `Bearer ${leanToken}` },
      });
      const lookupData = await lookupRes.json();
      if (!lookupRes.ok) {
        return json({ error: "lean-customer-lookup-failed", detail: lookupData }, 502);
      }
      customerId = lookupData.customer_id || lookupData.id;
    } else {
      return json({ error: "lean-customer-failed", detail: custData }, 502);
    }
    if (!customerId) {
      return json({ error: "lean-customer-id-missing", detail: custData }, 502);
    }

    const intentRes = await fetch(`${base}/payments/v1/intents`, {
      method: "POST",
      headers: {
        Authorization: `Bearer ${leanToken}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        customer_id: customerId,
        amount: total,
        currency: "SAR",
        description: orderId.slice(0, 12),
      }),
    });
    const intentData = await intentRes.json();
    if (!intentRes.ok) {
      return json({ error: "lean-intent-failed", detail: intentData }, 502);
    }

    await patchOrder(env, orderId, {
      leanPaymentIntentId: intentData.payment_intent_id,
    });

    return json({
      paymentIntentId: intentData.payment_intent_id,
      appToken: env.LEAN_APP_TOKEN,
    });
  } catch (e) {
    return json({ error: "lean-error", detail: String(e) }, 502);
  }
}

async function verifyLeanSignature(request, secret) {
  const sigHeader = request.headers.get("lean-signature") || "";
  const raw = await request.clone().text();
  const key = await crypto.subtle.importKey(
    "raw",
    new TextEncoder().encode(secret),
    { name: "HMAC", hash: "SHA-512" },
    false,
    ["sign"]
  );
  const mac = await crypto.subtle.sign("HMAC", key, new TextEncoder().encode(raw));
  const hex = [...new Uint8Array(mac)].map((b) => b.toString(16).padStart(2, "0")).join("");
  return sigHeader === `sha512=${hex}`;
}

async function handleWebhook(request, env) {
  const valid = await verifyLeanSignature(request, env.LEAN_WEBHOOK_SECRET);
  if (!valid) return json({ error: "invalid-signature" }, 401);

  const body = await request.json();
  const intentId =
    body.payment_intent_id || body.id || body.data?.id || body.payload?.id;
  if (!intentId) return json({ error: "no-intent-id-in-payload", body }, 200);

  try {
    const leanToken = await getLeanAccessToken(env);
    const intentRes = await fetch(`${leanBaseUrl(env)}/payments/v1/intents/${intentId}`, {
      headers: { Authorization: `Bearer ${leanToken}` },
    });
    const intent = await intentRes.json();
    const payments = intent.payments || [];
    const lastPayment = payments[payments.length - 1];
    const status = (lastPayment?.status || "").toUpperCase();

    const paymentStatus = ["PAID", "COMPLETED", "SUCCESS", "SUCCESSFUL"].includes(status)
      ? "paid"
      : ["FAILED", "DECLINED", "REJECTED", "CANCELLED"].includes(status)
      ? "failed"
      : null;
    if (!paymentStatus) {
      return json({ ok: true, note: "status-not-final-yet", status });
    }

    // نجد الطلب عبر رقم نية الدفع الذي حفظناه عند إنشائها — أدق من أي
    // تخمين لشكل الحمولة، ويعمل بغض النظر عن اختلاف حقول الويبهوك مستقبلاً
    const adminToken = await getFirestoreAdminToken(env);
    const q = await fetch(
      `${firestoreOrigin(env)}/v1/projects/${env.FIREBASE_PROJECT_ID}/databases/(default)/documents:runQuery`,
      {
        method: "POST",
        headers: {
          Authorization: `Bearer ${adminToken}`,
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          structuredQuery: {
            from: [{ collectionId: "orders" }],
            where: {
              fieldFilter: {
                field: { fieldPath: "leanPaymentIntentId" },
                op: "EQUAL",
                value: { stringValue: intentId },
              },
            },
            limit: 1,
          },
        }),
      }
    );
    const rows = await q.json();
    const docPath = rows?.[0]?.document?.name;
    if (!docPath) return json({ ok: true, note: "order-not-matched", intentId });

    const orderId = docPath.split("/").pop();
    await patchOrder(env, orderId, { paymentStatus }, adminToken);
    return json({ ok: true, orderId, status, paymentStatus });
  } catch (e) {
    return json({ error: "webhook-processing-failed", detail: String(e) }, 502);
  }
}

// ─── إنشاء الطلبات من جهة الخادم ─────────────────────────────────────────────
// التطبيق يرسل المعرّفات والكميات فقط (راجع pricing.js)، والخادم يقرأ الأسعار
// ويحسب الإجمالي ويكتب الطلب بحساب الخدمة، فلا يملك المتصفح أي تأثير على المبلغ.

const firestoreBase = (env) =>
  `${firestoreOrigin(env)}/v1/projects/${env.FIREBASE_PROJECT_ID}/databases/(default)/documents`;

function fromFs(value) {
  if (!value || "nullValue" in value) return null;
  if ("stringValue" in value) return value.stringValue;
  if ("booleanValue" in value) return value.booleanValue;
  if ("integerValue" in value) return Number(value.integerValue);
  if ("doubleValue" in value) return value.doubleValue;
  if ("timestampValue" in value) return value.timestampValue;
  if ("arrayValue" in value) return (value.arrayValue.values ?? []).map(fromFs);
  if ("mapValue" in value) return docFields(value.mapValue.fields);
  return null;
}

function docFields(fields) {
  return Object.fromEntries(Object.entries(fields ?? {}).map(([k, v]) => [k, fromFs(v)]));
}

// الحقول العددية الصحيحة في Dart (quantity/orderNumber) يجب أن تُحفظ integerValue،
// وإلا فشل قراءتها في OrderItem.fromMap لأن النوع المتوقع int
const INT_FIELDS = new Set(["quantity", "displayQuantity", "orderNumber"]);

function toFs(value, key) {
  if (value === null || value === undefined) return { nullValue: null };
  if (typeof value === "string") return { stringValue: value };
  if (typeof value === "boolean") return { booleanValue: value };
  if (typeof value === "number") {
    return INT_FIELDS.has(key) ? { integerValue: String(value) } : { doubleValue: value };
  }
  if (value instanceof Date) return { timestampValue: value.toISOString() };
  if (Array.isArray(value)) return { arrayValue: { values: value.map((v) => toFs(v)) } };
  return { mapValue: { fields: toFsFields(value) } };
}

function toFsFields(obj) {
  return Object.fromEntries(Object.entries(obj).map(([k, v]) => [k, toFs(v, k)]));
}

async function fsFetch(env, token, path, init = {}) {
  return fetch(`${firestoreBase(env)}${path}`, {
    ...init,
    headers: { Authorization: `Bearer ${token}`, "Content-Type": "application/json" },
  });
}

async function batchGetDocs(env, token, collection, ids) {
  const unique = [...new Set(ids.filter((id) => typeof id === "string" && /^[\w-]+$/.test(id)))];
  const result = new Map();
  if (unique.length === 0) return result;
  const prefix = `projects/${env.FIREBASE_PROJECT_ID}/databases/(default)/documents/${collection}`;
  const res = await fsFetch(env, token, ":batchGet", {
    method: "POST",
    body: JSON.stringify({ documents: unique.map((id) => `${prefix}/${id}`) }),
  });
  if (!res.ok) throw new Error(`firestore-batchget-failed: ${await res.text()}`);
  for (const row of await res.json()) {
    if (!row.found) continue;
    const id = row.found.name.split("/").pop();
    result.set(id, { id, ...docFields(row.found.fields) });
  }
  return result;
}

async function loadOrderContext(env, token, request) {
  const reqItems = Array.isArray(request.items) ? request.items : [];
  const reqCombos = Array.isArray(request.combos) ? request.combos : [];

  const combosById = await batchGetDocs(env, token, "combos", reqCombos.map((c) => c?.comboId));
  const itemIds = reqItems.map((i) => i?.itemId);
  for (const combo of combosById.values()) {
    for (const ref of combo.items ?? []) itemIds.push(ref.itemId);
    itemIds.push(...(combo.optionItemIds ?? []));
  }
  const itemsById = await batchGetDocs(env, token, "menu_items", itemIds);

  const settingsRes = await fsFetch(env, token, "/settings/restaurant");
  if (!settingsRes.ok) throw new Error(`settings-read-failed: ${settingsRes.status}`);
  const settings = docFields((await settingsRes.json()).fields);

  const zonesRes = await fsFetch(env, token, "/deliveryZones?pageSize=100");
  if (!zonesRes.ok) throw new Error(`zones-read-failed: ${zonesRes.status}`);
  const zones = ((await zonesRes.json()).documents ?? []).map((d) => ({
    id: d.name.split("/").pop(),
    ...docFields(d.fields),
  }));

  return { settings, zones, itemsById, combosById };
}

function newDocId() {
  const chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
  return [...crypto.getRandomValues(new Uint8Array(20))].map((b) => chars[b % chars.length]).join("");
}

function shuffledOrderNumbers() {
  const list = Array.from({ length: 9000 }, (_, i) => 1000 + i);
  const random = crypto.getRandomValues(new Uint32Array(list.length));
  for (let i = list.length - 1; i > 0; i--) {
    const j = random[i] % (i + 1);
    [list[i], list[j]] = [list[j], list[i]];
  }
  return list;
}

// يسحب رقم الطلب من مجموعة الأرقام ويكتب الطلب في معاملة واحدة، فلا يضيع رقم
// ولا يتكرر. Firestore يعيد ABORTED عند تزاحم طلبات متزامنة فتُعاد المحاولة.
async function commitOrder(env, token, fields) {
  const docRoot = `projects/${env.FIREBASE_PROJECT_ID}/databases/(default)/documents`;
  const poolName = `${docRoot}/counters/orderNumberPool`;

  for (let attempt = 0; attempt < 6; attempt++) {
    if (attempt > 0) {
      await new Promise((r) => setTimeout(r, 150 * attempt + Math.random() * 250));
    }
    const txRes = await fsFetch(env, token, ":beginTransaction", { method: "POST", body: "{}" });
    if (!txRes.ok) throw new Error(`begin-transaction-failed: ${await txRes.text()}`);
    const { transaction } = await txRes.json();

    const getRes = await fsFetch(env, token, ":batchGet", {
      method: "POST",
      body: JSON.stringify({ documents: [poolName], transaction }),
    });
    if (!getRes.ok) throw new Error(`pool-read-failed: ${await getRes.text()}`);
    const rows = await getRes.json();
    const found = rows.find((r) => r.found)?.found;
    const pool = found ? docFields(found.fields) : {};

    let sequence = Array.isArray(pool.sequence) ? pool.sequence : [];
    let index = Number.isInteger(pool.index) ? pool.index : 0;
    const reshuffled = index >= sequence.length;
    if (reshuffled) {
      sequence = shuffledOrderNumbers();
      index = 0;
    }
    const orderNumber = sequence[index];

    const orderId = newDocId();
    const orderFields = { ...fields, orderNumber };
    const commitRes = await fsFetch(env, token, ":commit", {
      method: "POST",
      body: JSON.stringify({
        transaction,
        writes: [
          {
            update: {
              name: poolName,
              fields: reshuffled
                ? {
                    sequence: { arrayValue: { values: sequence.map((n) => ({ integerValue: String(n) })) } },
                    index: { integerValue: String(index + 1) },
                  }
                : { index: { integerValue: String(index + 1) } },
            },
            updateMask: { fieldPaths: reshuffled ? ["sequence", "index"] : ["index"] },
          },
          {
            update: { name: `${docRoot}/orders/${orderId}`, fields: toFsFields(orderFields) },
            currentDocument: { exists: false },
          },
        ],
      }),
    });
    if (commitRes.ok) return { orderId, orderNumber };
    if (commitRes.status !== 409) throw new Error(`commit-failed: ${await commitRes.text()}`);
  }
  throw new Error("commit-contention");
}

async function handleCreateOrder(request, env) {
  const authHeader = request.headers.get("Authorization") || "";
  const idToken = authHeader.replace(/^Bearer\s+/i, "").trim();
  const uid = idToken ? decodeUid(idToken) : null;
  if (!uid || !/^[\w-]+$/.test(uid)) return json({ error: "unauthenticated" }, 401);

  let body;
  try {
    body = await request.json();
  } catch {
    return json({ error: "invalid-body" }, 400);
  }

  // كتابة الطلب تتم بصلاحية إدارية، فيجب التأكد من صحة هوية المتصل قبلها:
  // قراءة ملفه بتوكنه هو تجعل Firestore تتحقق من توقيع التوكن وترفض أي تزوير
  const profileRes = await fsFetch(env, idToken, `/users/${uid}`);
  if (profileRes.status === 401 || profileRes.status === 403) {
    return json({ error: "unauthenticated" }, 401);
  }
  if (!profileRes.ok && profileRes.status !== 404) {
    return json({ error: "profile-read-failed", message: "تعذّر إرسال الطلب، حاول مجدداً" }, 502);
  }
  const profile = profileRes.ok ? docFields((await profileRes.json()).fields) : null;
  // dryRun يحسب فقط بلا أي كتابة — للتحقق من سلامة الخادم بعد النشر
  if (!profile && body.dryRun !== true) {
    return json({ error: "profile-missing", message: "تعذّر إرسال الطلب، أعد تحميل الصفحة وحاول مجدداً" }, 403);
  }

  try {
    const adminToken = await getFirestoreAdminToken(env);
    const context = await loadOrderContext(env, adminToken, body);
    const priced = priceOrder({ request: body, ...context });

    if (body.dryRun === true) return json({ dryRun: true, ...priced });

    const now = new Date();
    const { orderId, orderNumber } = await commitOrder(env, adminToken, {
      ...priced,
      customerId: uid,
      ...customerContact(profile),
      status: "pending",
      createdAt: now,
      updatedAt: now,
      estimatedTime: null,
      kitchenNotes: null,
      estimatedMinutes: null,
      estimatedSetAt: null,
      driverId: null,
      driverName: null,
      driverPhone: null,
      assignedAt: null,
      driverAcceptedAt: null,
      pickedUpAt: null,
      driverLat: null,
      driverLng: null,
      driverLocationUpdatedAt: null,
      paymentStatus: "pending",
      leanPaymentIntentId: null,
      paymentReceiptUrl: null,
      unavailableItemIds: [],
    });
    return json({ orderId, orderNumber, total: priced.total });
  } catch (e) {
    if (e instanceof OrderRejected) {
      return json({ error: e.code, message: e.message }, e.status);
    }
    console.error("create-order-failed", String(e));
    return json({ error: "order-failed", message: "تعذّر إرسال الطلب، حاول مجدداً" }, 502);
  }
}

// العميل يوافق على إزالة ما نفد من طلبه — القواعد تمنع أي متصفح من تعديل الأسعار
async function handleAcknowledgeUnavailable(request, env) {
  const authHeader = request.headers.get("Authorization") || "";
  const idToken = authHeader.replace(/^Bearer\s+/i, "").trim();
  const uid = idToken ? decodeUid(idToken) : null;
  if (!uid) return json({ error: "unauthenticated" }, 401);

  let orderId;
  try {
    ({ orderId } = await request.json());
  } catch {
    return json({ error: "invalid-body" }, 400);
  }
  if (typeof orderId !== "string" || !/^[\w-]+$/.test(orderId)) {
    return json({ error: "orderId-required" }, 400);
  }

  const failure = { error: "update-failed", message: "تعذّر تحديث طلبك، حاول مجدداً" };
  try {
    // القراءة بتوكن العميل تتحقق من صحته، ثم نتأكد أن الطلب طلبه هو
    const orderRes = await fsFetch(env, idToken, `/orders/${orderId}`);
    if (!orderRes.ok) return json({ error: "order-not-found-or-forbidden", message: failure.message }, 403);
    const doc = await orderRes.json();
    const order = docFields(doc.fields);
    if (order.customerId !== uid) {
      return json({ error: "order-not-found-or-forbidden", message: failure.message }, 403);
    }

    const changes = removeUnavailableItems(order);
    if (!changes) return json({ ok: true, alreadyDone: true });

    const fields = { ...changes, updatedAt: new Date() };
    const mask = Object.keys(fields).map((f) => `updateMask.fieldPaths=${f}`).join("&");
    const precondition = `currentDocument.updateTime=${encodeURIComponent(doc.updateTime)}`;
    const adminToken = await getFirestoreAdminToken(env);
    const patchRes = await fsFetch(env, adminToken, `/orders/${orderId}?${mask}&${precondition}`, {
      method: "PATCH",
      body: JSON.stringify({ fields: toFsFields(fields) }),
    });
    if (!patchRes.ok) {
      console.error("ack-unavailable-patch-failed", await patchRes.text());
      return json(failure, 502);
    }
    return json({ ok: true, subtotal: changes.subtotal, total: changes.total });
  } catch (e) {
    if (e instanceof OrderRejected) return json({ error: e.code, message: e.message }, e.status);
    console.error("ack-unavailable-failed", String(e));
    return json(failure, 502);
  }
}

// المطبخ يوقف/يشغّل خياراً واحداً نفد — عبر الخادم، لأن السماح له بكتابة حقل
// optionGroups كاملاً في القواعد يتيح له تغيير الأسعار أيضاً
async function handleOptionAvailability(request, env) {
  const authHeader = request.headers.get("Authorization") || "";
  const idToken = authHeader.replace(/^Bearer\s+/i, "").trim();
  const uid = idToken ? decodeUid(idToken) : null;
  if (!uid || !/^[\w-]+$/.test(uid)) return json({ error: "unauthenticated" }, 401);

  let body;
  try {
    body = await request.json();
  } catch {
    return json({ error: "invalid-body" }, 400);
  }
  const { itemId, groupId, optionId, isAvailable } = body;
  const validIds = [itemId, groupId, optionId].every((v) => typeof v === "string" && v.length > 0);
  if (!validIds || !/^[\w-]+$/.test(itemId) || typeof isAvailable !== "boolean") {
    return json({ error: "invalid-body", message: "طلب غير صحيح" }, 400);
  }

  const failure = { error: "update-failed", message: "تعذّر تحديث الخيار، حاول مجدداً" };
  try {
    // قراءة الملف بتوكن المتصل تتحقق من صحته. الحساب المجهول ليس موظفاً مهما كان دوره
    const profileRes = await fsFetch(env, idToken, `/users/${uid}`);
    if (!profileRes.ok) return json({ error: "permission-denied", message: "لا تملك صلاحية هذا الإجراء" }, 403);
    const role = (await profileRes.json()).fields?.role?.stringValue;
    const claims = JSON.parse(atob(idToken.split(".")[1].replace(/-/g, "+").replace(/_/g, "/")));
    const isGuest = claims.firebase?.sign_in_provider === "anonymous";
    if (isGuest || (role !== "kitchen" && role !== "admin")) {
      return json({ error: "permission-denied", message: "لا تملك صلاحية هذا الإجراء" }, 403);
    }

    const adminToken = await getFirestoreAdminToken(env);
    const itemRes = await fsFetch(env, adminToken, `/menu_items/${itemId}`);
    if (!itemRes.ok) return json({ error: "item-not-found", message: "لم يُعثر على هذا الصنف، حدّث الصفحة" }, 404);
    const doc = await itemRes.json();

    const optionGroups = setOptionAvailability(doc.fields?.optionGroups, groupId, optionId, isAvailable);
    const precondition = `currentDocument.updateTime=${encodeURIComponent(doc.updateTime)}`;
    const patchRes = await fsFetch(
      env,
      adminToken,
      `/menu_items/${itemId}?updateMask.fieldPaths=optionGroups&${precondition}`,
      { method: "PATCH", body: JSON.stringify({ fields: { optionGroups } }) }
    );
    if (!patchRes.ok) {
      console.error("option-availability-patch-failed", await patchRes.text());
      return json(failure, 502);
    }
    return json({ ok: true });
  } catch (e) {
    if (e instanceof OrderRejected) return json({ error: e.code, message: e.message }, e.status);
    console.error("option-availability-failed", String(e));
    return json(failure, 502);
  }
}

// المدير يعيّن كلمة مرور جديدة لموظف نسيها — يتطلب صلاحية حساب الخدمة، فلا يمكن من
// المتصفح. بعدها تُبطَل جلسات الموظف المفتوحة حتى يدخل بالكلمة الجديدة.
async function handleResetStaffPassword(request, env) {
  const authHeader = request.headers.get("Authorization") || "";
  const idToken = authHeader.replace(/^Bearer\s+/i, "").trim();
  const uid = idToken ? decodeUid(idToken) : null;
  if (!uid || !/^[\w-]+$/.test(uid)) return json({ error: "unauthenticated" }, 401);

  let body;
  try {
    body = await request.json();
  } catch {
    return json({ error: "invalid-body" }, 400);
  }
  const { userId, newPassword } = body;
  if (typeof userId !== "string" || !/^[\w-]+$/.test(userId)) {
    return json({ error: "invalid-body", message: "طلب غير صحيح" }, 400);
  }
  if (typeof newPassword !== "string" || newPassword.length < 6 || newPassword.length > 128) {
    return json({ error: "weak-password", message: "كلمة المرور يجب أن تكون 6 أحرف على الأقل" }, 400);
  }

  const denied = { error: "permission-denied", message: "لا تملك صلاحية تغيير كلمة مرور هذا الموظف" };
  const failure = { error: "reset-failed", message: "تعذّر تغيير كلمة المرور، حاول مجدداً" };
  try {
    // قراءة ملف المتصل بتوكنه تتحقق من صحته
    const callerRes = await fsFetch(env, idToken, `/users/${uid}`);
    if (!callerRes.ok) return json(denied, 403);
    const caller = docFields((await callerRes.json()).fields);

    const adminToken = await getFirestoreAdminToken(env);
    const targetRes = await fsFetch(env, adminToken, `/users/${userId}`);
    if (!targetRes.ok) return json({ error: "user-not-found", message: "لم يُعثر على هذا الموظف" }, 404);
    const target = docFields((await targetRes.json()).fields);

    const claims = JSON.parse(atob(idToken.split(".")[1].replace(/-/g, "+").replace(/_/g, "/")));
    const allowed = canResetStaffPassword({
      caller,
      target,
      isAnonymous: claims.firebase?.sign_in_provider === "anonymous",
      isSelf: uid === userId,
    });
    if (!allowed) return json(denied, 403);

    const authToken = await getFirestoreAdminToken(env, "https://www.googleapis.com/auth/identitytoolkit");
    const res = await fetch(
      `https://identitytoolkit.googleapis.com/v1/projects/${env.FIREBASE_PROJECT_ID}/accounts:update`,
      {
        method: "POST",
        headers: { Authorization: `Bearer ${authToken}`, "Content-Type": "application/json" },
        body: JSON.stringify({
          localId: userId,
          password: newPassword,
          validSince: String(Math.floor(Date.now() / 1000)),
        }),
      }
    );
    if (!res.ok) {
      console.error("reset-password-failed", res.status, await res.text());
      return json(failure, 502);
    }
    return json({ ok: true });
  } catch (e) {
    console.error("reset-password-error", String(e));
    return json(failure, 502);
  }
}

// هوية المتصل بعد تحقق Firestore من توكنه، أو null إن كان غير صالح
async function readCaller(request, env) {
  const authHeader = request.headers.get("Authorization") || "";
  const idToken = authHeader.replace(/^Bearer\s+/i, "").trim();
  const uid = idToken ? decodeUid(idToken) : null;
  if (!uid || !/^[\w-]+$/.test(uid)) return null;
  const res = await fsFetch(env, idToken, `/users/${uid}`);
  if (!res.ok) return null;
  const claims = JSON.parse(atob(idToken.split(".")[1].replace(/-/g, "+").replace(/_/g, "/")));
  return {
    uid,
    profile: docFields((await res.json()).fields),
    isAnonymous: claims.firebase?.sign_in_provider === "anonymous",
  };
}

const AUTH_SCOPE = "https://www.googleapis.com/auth/identitytoolkit";
const authApi = (env, action) =>
  `https://identitytoolkit.googleapis.com/v1/projects/${env.FIREBASE_PROJECT_ID}/accounts:${action}`;

async function authAdminCall(env, token, action, body) {
  return fetch(authApi(env, action), {
    method: "POST",
    headers: { Authorization: `Bearer ${token}`, "Content-Type": "application/json" },
    body: JSON.stringify(body),
  });
}

// حذف مستخدم: حساب الدخول مع ملفه، حتى يصير رقمه متاحاً لإضافته من جديد
async function handleDeleteUser(request, env) {
  const denied = { error: "permission-denied", message: "لا تملك صلاحية حذف هذا المستخدم" };
  const failure = { error: "delete-failed", message: "تعذّر حذف المستخدم، حاول مجدداً" };
  let body;
  try {
    body = await request.json();
  } catch {
    return json({ error: "invalid-body" }, 400);
  }
  const { userId } = body;
  if (typeof userId !== "string" || !/^[\w-]+$/.test(userId)) {
    return json({ error: "invalid-body", message: "طلب غير صحيح" }, 400);
  }
  try {
    const caller = await readCaller(request, env);
    if (!caller) return json(denied, 403);

    const adminToken = await getFirestoreAdminToken(env);
    const targetRes = await fsFetch(env, adminToken, `/users/${userId}`);
    if (!targetRes.ok) return json({ error: "user-not-found", message: "لم يُعثر على هذا المستخدم" }, 404);
    const target = docFields((await targetRes.json()).fields);

    const allowed = canDeleteUser({
      caller: caller.profile,
      target,
      isAnonymous: caller.isAnonymous,
      isSelf: caller.uid === userId,
    });
    if (!allowed) return json(denied, 403);

    const authToken = await getFirestoreAdminToken(env, AUTH_SCOPE);
    const authRes = await authAdminCall(env, authToken, "delete", { localId: userId });
    // حساب دخول محذوف من قبل لا يمنع إكمال حذف الملف
    if (!authRes.ok) {
      const detail = await authRes.text();
      if (!detail.includes("USER_NOT_FOUND")) {
        console.error("delete-user-auth-failed", authRes.status, detail);
        return json(failure, 502);
      }
    }
    const docRes = await fsFetch(env, adminToken, `/users/${userId}`, { method: "DELETE" });
    if (!docRes.ok) {
      console.error("delete-user-doc-failed", docRes.status, await docRes.text());
      return json(failure, 502);
    }
    return json({ ok: true });
  } catch (e) {
    console.error("delete-user-error", String(e));
    return json(failure, 502);
  }
}

// رقم محجوز بحساب دخول بلا ملف، من موظف حُذف قبل حذف الحسابات مع ملفاتها: يُعاد
// استخدامه للموظف الجديد بكلمة المرور الجديدة. رقم موظف موجود فعلاً يبقى مرفوضاً.
async function handleReclaimStaffAccount(request, env) {
  const denied = { error: "permission-denied", message: "لا تملك صلاحية إضافة موظفين" };
  const inUse = { error: "phone-in-use", message: "يوجد موظف مسجّل بهذا الرقم مسبقاً" };
  const failure = { error: "reclaim-failed", message: "تعذّرت إضافة الموظف، حاول مجدداً" };
  let body;
  try {
    body = await request.json();
  } catch {
    return json({ error: "invalid-body" }, 400);
  }
  const { phone, name, role, password } = body;
  const valid =
    typeof phone === "string" && /^[+\d]{7,20}$/.test(phone) &&
    typeof name === "string" && name.trim().length > 0 && name.length <= 100 &&
    typeof password === "string" && password.length >= 6 && password.length <= 128;
  if (!valid) return json({ error: "invalid-body", message: "بيانات الموظف غير صحيحة" }, 400);

  try {
    const caller = await readCaller(request, env);
    if (!caller) return json(denied, 403);
    const allowed = canReclaimStaffAccount({
      caller: caller.profile,
      isAnonymous: caller.isAnonymous,
      role,
      phone,
    });
    if (!allowed) return json(denied, 403);

    const authToken = await getFirestoreAdminToken(env, AUTH_SCOPE);
    const lookup = await authAdminCall(env, authToken, "lookup", { email: [`${phone}@meals.local`] });
    if (!lookup.ok) {
      console.error("reclaim-lookup-failed", lookup.status, await lookup.text());
      return json(failure, 502);
    }
    const uid = (await lookup.json()).users?.[0]?.localId;
    if (!uid) return json(failure, 404);

    const adminToken = await getFirestoreAdminToken(env);
    const existing = await fsFetch(env, adminToken, `/users/${uid}`);
    if (existing.ok) return json(inUse, 409);
    if (existing.status !== 404) return json(failure, 502);

    const update = await authAdminCall(env, authToken, "update", {
      localId: uid,
      password,
      disableUser: false,
      validSince: String(Math.floor(Date.now() / 1000)),
    });
    if (!update.ok) {
      console.error("reclaim-update-failed", update.status, await update.text());
      return json(failure, 502);
    }

    const doc = await fsFetch(
      env,
      adminToken,
      `/users/${uid}?currentDocument.exists=false`,
      {
        method: "PATCH",
        body: JSON.stringify({
          fields: toFsFields({
            phone,
            name: name.trim(),
            role,
            createdAt: new Date(),
            fcmToken: null,
            isAvailable: true,
            vehicleType: null,
            savedLat: null,
            savedLng: null,
            savedAddress: null,
            extraRoles: [],
            systemRole: "none",
            permissions: {},
          }),
        }),
      }
    );
    if (!doc.ok) {
      console.error("reclaim-doc-failed", doc.status, await doc.text());
      return json(failure, 502);
    }
    return json({ ok: true, uid });
  } catch (e) {
    console.error("reclaim-error", String(e));
    return json(failure, 502);
  }
}

// فحص تشخيصي بلا حاجة لعميل حقيقي أو طلب فعلي — يختبر فقط أن أسرار لين
// وحساب خدمة Firebase صالحة وتُصدر توكن وصول بنجاح. لا يكشف أي قيمة سرّية
// في الرد، فقط ok/error لكل جزء. يُزال أو يُقيَّد لاحقاً بعد التأكد النهائي.
async function handleHealth(env) {
  const result = {};
  try {
    const t = await getLeanAccessToken(env);
    result.lean = t ? "ok" : "empty-token";
  } catch (e) {
    result.lean = `error: ${String(e)}`;
  }
  try {
    const t = await getFirestoreAdminToken(env);
    result.firebaseAdmin = t ? "ok" : "empty-token";
  } catch (e) {
    result.firebaseAdmin = `error: ${String(e)}`;
  }
  return json(result);
}

export default {
  async fetch(request, env) {
    if (request.method === "OPTIONS") {
      return new Response(null, { status: 204, headers: CORS_HEADERS });
    }
    const url = new URL(request.url);
    if (url.pathname === "/health") {
      return handleHealth(env);
    }
    if (url.pathname === "/webhook") {
      if (request.method !== "POST") return json({ error: "method-not-allowed" }, 405);
      return handleWebhook(request, env);
    }
    if (request.method !== "POST") return json({ error: "method-not-allowed" }, 405);
    if (url.pathname === "/orders") return handleCreateOrder(request, env);
    if (url.pathname === "/menu/option-availability") return handleOptionAvailability(request, env);
    if (url.pathname === "/staff/reset-password") return handleResetStaffPassword(request, env);
    if (url.pathname === "/staff/delete") return handleDeleteUser(request, env);
    if (url.pathname === "/staff/reclaim") return handleReclaimStaffAccount(request, env);
    if (url.pathname === "/orders/acknowledge-unavailable") {
      return handleAcknowledgeUnavailable(request, env);
    }
    return handleCreatePayment(request, env);
  },
};
