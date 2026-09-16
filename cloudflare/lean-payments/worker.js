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

function leanBaseUrl(env) {
  return env.LEAN_ENV === "production"
    ? "https://api2.leantech.me"
    : "https://sandbox.leantech.me";
}

function leanAuthUrl(env) {
  return env.LEAN_ENV === "production"
    ? "https://auth.leantech.me/oauth2/token"
    : "https://auth.sandbox.leantech.me/oauth2/token";
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
async function getFirestoreAdminToken(env) {
  const sa = JSON.parse(env.FIREBASE_SERVICE_ACCOUNT_JSON);
  const now = Math.floor(Date.now() / 1000);
  const header = { alg: "RS256", typ: "JWT" };
  const claims = {
    iss: sa.client_email,
    scope: "https://www.googleapis.com/auth/datastore",
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
  const url = `https://firestore.googleapis.com/v1/projects/${env.FIREBASE_PROJECT_ID}/databases/(default)/documents/orders/${orderId}?${mask}`;
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
    `https://firestore.googleapis.com/v1/projects/${env.FIREBASE_PROJECT_ID}/databases/(default)/documents/orders/${orderId}`,
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

    // app_user_id يمنع لين من إنشاء عميل مكرَّر لنفس المستخدم عبر طلبات متتالية
    const custRes = await fetch(`${base}/customers/v1`, {
      method: "POST",
      headers: {
        Authorization: `Bearer ${leanToken}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({ app_user_id: uid }),
    });
    const custData = await custRes.json();
    if (!custRes.ok) {
      return json({ error: "lean-customer-failed", detail: custData }, 502);
    }
    const customerId = custData.customer_id || custData.id;

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
      `https://firestore.googleapis.com/v1/projects/${env.FIREBASE_PROJECT_ID}/databases/(default)/documents:runQuery`,
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

export default {
  async fetch(request, env) {
    if (request.method === "OPTIONS") {
      return new Response(null, { status: 204, headers: CORS_HEADERS });
    }
    const url = new URL(request.url);
    if (url.pathname === "/webhook") {
      if (request.method !== "POST") return json({ error: "method-not-allowed" }, 405);
      return handleWebhook(request, env);
    }
    if (request.method !== "POST") return json({ error: "method-not-allowed" }, 405);
    return handleCreatePayment(request, env);
  },
};
