// دالة حذف صور Cloudinary — نسخة Cloudflare Workers (بديل عن Firebase Cloud
// Functions لتجنّب اشتراط بطاقة بنكية على خطة Blaze؛ لا يوجد أي تغيير على
// مكان تخزين الصور نفسه — تبقى في Cloudinary كما هي).
//
// الثقة بهوية المتصل: لا نتحقق من توقيع توكن Firebase بأنفسنا هنا (لا حاجة
// لحساب خدمة Google منفصل)، بل نمرّر نفس توكن Firebase ID Token الذي أرسله
// العميل إلى Firestore REST API مباشرة كـ Bearer — Firestore نفسها تتحقق من
// صحة التوقيع وترفض أي توكن مزوَّر أو منتهي الصلاحية. الـ uid المستخرَج محلياً
// من التوكن لا يُستخدم إلا لبناء مسار الطلب؛ إن كان مزوَّراً فسيفشل التحقق عند
// Firestore نفسها لأن التوقيع الكامل للتوكن يصبح غير صالح.

import {
  canManageOrders,
  receiptDownloadUrl,
  receiptFormat,
  receiptPublicId,
  sha1Hex,
  signCloudinary,
} from "./receipts.js";

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

function isAnonymousToken(idToken) {
  try {
    const payload = idToken.split(".")[1].replace(/-/g, "+").replace(/_/g, "/");
    return JSON.parse(atob(payload)).firebase?.sign_in_provider === "anonymous";
  } catch {
    return true;
  }
}

// يقرأ ملف المتصل بتوكنه هو، فتتحقق Firestore من صحة التوقيع. الحساب المجهول
// (الضيف) ليس مديراً مهما كان مكتوباً في ملفه، مثل قواعد الأمان تماماً.
async function isAdminCaller(env, idToken, uid) {
  if (isAnonymousToken(idToken)) return false;
  const res = await fetch(
    `https://firestore.googleapis.com/v1/projects/${env.FIREBASE_PROJECT_ID}/databases/(default)/documents/users/${uid}`,
    { headers: { Authorization: `Bearer ${idToken}` } }
  );
  if (!res.ok) return false;
  const doc = await res.json();
  return doc.fields?.role?.stringValue === "admin";
}

const IMAGE_FORMATS = "jpg,jpeg,png,webp,gif,heic";
const RECEIPT_FORMATS = "jpg,jpeg,png,pdf";
const IMAGES_FOLDER = "melz_restaurant";

// توقيع رفع إلى Cloudinary: المتصفح يرفع مباشرة، لكن بعد موافقة الخادم فقط.
// المدير يرفع صور القائمة، والعميل يرفع إيصالاً واحداً لطلب تحويل بنكي يملكه.
async function handleSignUpload(request, env, idToken, uid) {
  let body;
  try {
    body = await request.json();
  } catch {
    return json({ error: "invalid-body" }, 400);
  }

  let params;
  if (typeof body.receiptOrderId === "string") {
    const orderId = body.receiptOrderId;
    if (!/^[\w-]+$/.test(orderId)) return json({ error: "invalid-body" }, 400);
    const res = await fetch(
      `https://firestore.googleapis.com/v1/projects/${env.FIREBASE_PROJECT_ID}/databases/(default)/documents/orders/${orderId}`,
      { headers: { Authorization: `Bearer ${idToken}` } }
    );
    if (!res.ok) return json({ error: "permission-denied" }, 403);
    const f = (await res.json()).fields ?? {};
    const canUpload =
      f.customerId?.stringValue === uid &&
      f.paymentMethod?.stringValue === "manualBankTransfer" &&
      f.status?.stringValue !== "cancelled" &&
      !f.paymentReceiptUrl?.stringValue;
    if (!canUpload) return json({ error: "permission-denied" }, 403);
    // معرّف ثابت لكل طلب بلا استبدال، فلا يمكن رفع أكثر من ملف واحد للطلب نفسه
    params = {
      allowed_formats: RECEIPT_FORMATS,
      overwrite: "false",
      public_id: receiptPublicId(orderId),
      type: "authenticated",
    };
  } else {
    const publicId = body.publicId;
    if (typeof publicId !== "string" || !/^[\w-]{1,200}$/.test(publicId)) {
      return json({ error: "publicId-required" }, 400);
    }
    if (!(await isAdminCaller(env, idToken, uid))) return json({ error: "permission-denied" }, 403);
    params = { allowed_formats: IMAGE_FORMATS, folder: IMAGES_FOLDER, public_id: publicId };
  }

  params.timestamp = String(Math.floor(Date.now() / 1000));
  const signature = await signCloudinary(params, env.CLOUDINARY_API_SECRET);
  return json({ ...params, signature, api_key: env.CLOUDINARY_API_KEY });
}

// رابط مؤقت لإيصال طلب، لمن له صلاحية الطلبات فقط. يُبنى من معرّف الطلب، فلا يتبع
// أي رابط مكتوب في الطلب.
async function handleReceiptUrl(request, env, idToken, uid) {
  let orderId;
  try {
    orderId = (await request.json()).orderId;
  } catch {
    return json({ error: "invalid-body" }, 400);
  }
  if (typeof orderId !== "string" || !/^[\w-]+$/.test(orderId)) {
    return json({ error: "invalid-body" }, 400);
  }
  if (isAnonymousToken(idToken)) return json({ error: "permission-denied" }, 403);

  const documents = `https://firestore.googleapis.com/v1/projects/${env.FIREBASE_PROJECT_ID}/databases/(default)/documents`;
  const headers = { Authorization: `Bearer ${idToken}` };
  const userRes = await fetch(`${documents}/users/${uid}`, { headers });
  if (!userRes.ok || !canManageOrders((await userRes.json()).fields)) {
    return json({ error: "permission-denied" }, 403);
  }

  const orderRes = await fetch(`${documents}/orders/${orderId}`, { headers });
  if (!orderRes.ok) return json({ error: "permission-denied" }, 403);
  const format = receiptFormat((await orderRes.json()).fields?.paymentReceiptUrl?.stringValue);
  if (!format) return json({ error: "no-receipt" }, 404);

  const url = await receiptDownloadUrl({
    cloudName: env.CLOUDINARY_CLOUD_NAME,
    apiKey: env.CLOUDINARY_API_KEY,
    apiSecret: env.CLOUDINARY_API_SECRET,
    orderId,
    format,
    nowSeconds: Math.floor(Date.now() / 1000),
  });
  return json({ url });
}

export default {
  async fetch(request, env) {
    if (request.method === "OPTIONS") {
      return new Response(null, { status: 204, headers: CORS_HEADERS });
    }
    if (request.method !== "POST") {
      return json({ error: "method-not-allowed" }, 405);
    }

    const authHeader = request.headers.get("Authorization") || "";
    const idToken = authHeader.replace(/^Bearer\s+/i, "").trim();
    if (!idToken) return json({ error: "unauthenticated" }, 401);

    const uid = decodeUid(idToken);
    if (!uid || !/^[\w-]+$/.test(uid)) return json({ error: "unauthenticated" }, 401);

    if (new URL(request.url).pathname === "/sign-upload") {
      return handleSignUpload(request, env, idToken, uid);
    }
    if (new URL(request.url).pathname === "/receipt-url") {
      return handleReceiptUrl(request, env, idToken, uid);
    }

    let publicId;
    try {
      const body = await request.json();
      publicId = body.publicId;
    } catch {
      return json({ error: "invalid-body" }, 400);
    }
    if (!publicId || typeof publicId !== "string") {
      return json({ error: "publicId-required" }, 400);
    }

    // التحقق من صلاحية الأدمن عبر Firestore REST — Firestore تتحقق من التوقيع
    // وتُطبّق قواعد الأمان الفعلية (users/{uid} قراءة لأي مستخدم مسجَّل).
    const fsUrl = `https://firestore.googleapis.com/v1/projects/${env.FIREBASE_PROJECT_ID}/databases/(default)/documents/users/${uid}`;
    const fsRes = await fetch(fsUrl, {
      headers: { Authorization: `Bearer ${idToken}` },
    });
    if (!fsRes.ok) return json({ error: "unauthenticated" }, 401);

    const userDoc = await fsRes.json();
    const role = userDoc.fields?.role?.stringValue;
    if (role !== "admin" || isAnonymousToken(idToken)) {
      return json({ error: "permission-denied" }, 403);
    }

    const timestamp = Math.floor(Date.now() / 1000);
    const toSign = `public_id=${publicId}&timestamp=${timestamp}${env.CLOUDINARY_API_SECRET}`;
    const signature = await sha1Hex(toSign);

    const cldBody = new URLSearchParams({
      public_id: publicId,
      timestamp: String(timestamp),
      api_key: env.CLOUDINARY_API_KEY,
      signature,
    });

    const cldRes = await fetch(
      `https://api.cloudinary.com/v1_1/${env.CLOUDINARY_CLOUD_NAME}/image/destroy`,
      { method: "POST", body: cldBody }
    );
    const data = await cldRes.json();

    if (data.result !== "ok" && data.result !== "not found") {
      return json({ error: "cloudinary-failed", detail: data }, 502);
    }
    return json({ result: data.result });
  },
};
