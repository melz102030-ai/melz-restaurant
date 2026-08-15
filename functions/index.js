const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { defineSecret } = require("firebase-functions/params");
const { initializeApp } = require("firebase-admin/app");
const { getFirestore } = require("firebase-admin/firestore");
const crypto = require("crypto");

initializeApp();
const db = getFirestore();

// اسم حساب Cloudinary — نفس القيمة المستخدمة في lib/core/services/cloudinary_service.dart
const CLOUD_NAME = "dwbzohzt9";

// المفتاح السري لا يُخزَّن في الكود أبداً — يُضبط مرة واحدة عبر:
//   firebase functions:secrets:set CLOUDINARY_API_KEY
//   firebase functions:secrets:set CLOUDINARY_API_SECRET
const cloudinaryApiKey = defineSecret("CLOUDINARY_API_KEY");
const cloudinaryApiSecret = defineSecret("CLOUDINARY_API_SECRET");

// حذف صورة من Cloudinary بطلب موقّع من جهة الخادم — الأدمن فقط. تُستدعى من
// التطبيق عند استبدال أو حذف أي صورة (شعار/غلاف/صنف/فئة/بانر/إعلان) حتى لا
// تبقى الصور القديمة يتيمة في الحساب إلى الأبد.
exports.deleteCloudinaryImage = onCall(
  { secrets: [cloudinaryApiKey, cloudinaryApiSecret] },
  async (request) => {
    const publicId = request.data && request.data.publicId;
    if (!publicId || typeof publicId !== "string") {
      throw new HttpsError("invalid-argument", "publicId مطلوب");
    }
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "يجب تسجيل الدخول");
    }

    const userDoc = await db.collection("users").doc(request.auth.uid).get();
    if (userDoc.data()?.role !== "admin") {
      throw new HttpsError("permission-denied", "هذه العملية للأدمن فقط");
    }

    const timestamp = Math.floor(Date.now() / 1000);
    const apiSecret = cloudinaryApiSecret.value();
    const apiKey = cloudinaryApiKey.value();

    const toSign = `public_id=${publicId}&timestamp=${timestamp}${apiSecret}`;
    const signature = crypto.createHash("sha1").update(toSign).digest("hex");

    const body = new URLSearchParams({
      public_id: publicId,
      timestamp: String(timestamp),
      api_key: apiKey,
      signature,
    });

    const response = await fetch(
      `https://api.cloudinary.com/v1_1/${CLOUD_NAME}/image/destroy`,
      { method: "POST", body }
    );
    const data = await response.json();

    if (data.result !== "ok" && data.result !== "not found") {
      throw new HttpsError("internal", `فشل حذف الصورة: ${JSON.stringify(data)}`);
    }
    return { result: data.result };
  }
);
