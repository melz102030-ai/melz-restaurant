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

async function sha1Hex(str) {
  const buf = await crypto.subtle.digest("SHA-1", new TextEncoder().encode(str));
  return [...new Uint8Array(buf)].map((b) => b.toString(16).padStart(2, "0")).join("");
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
    if (!uid) return json({ error: "unauthenticated" }, 401);

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
    if (role !== "admin") return json({ error: "permission-denied" }, 403);

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
