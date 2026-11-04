// إيصالات التحويل البنكي: تُخزن خاصة في Cloudinary، ولا تُفتح إلا برابط مؤقت يطلبه
// من له صلاحية الطلبات. الطلب نفسه لا يحفظ رابطاً، بل صيغة الملف فقط (receipt.pdf).
const RECEIPT_MARKER = /^receipt\.(jpg|jpeg|png|pdf)$/;
const RECEIPT_LINK_SECONDS = 600;

// نفس رقم المدير الأعلى في firestore.rules
const SUPER_PHONES = ["0531131125", "966531131125", "+966531131125", "00966531131125"];

export const receiptPublicId = (orderId) => `melz_restaurant/receipts/receipt_${orderId}`;

export function receiptFormat(stored) {
  const match = RECEIPT_MARKER.exec(typeof stored === "string" ? stored : "");
  return match ? match[1] : null;
}

export async function sha1Hex(str) {
  const buf = await crypto.subtle.digest("SHA-1", new TextEncoder().encode(str));
  return [...new Uint8Array(buf)].map((b) => b.toString(16).padStart(2, "0")).join("");
}

export function signCloudinary(params, secret) {
  const toSign = Object.keys(params).sort().map((k) => `${k}=${params[k]}`).join("&");
  return sha1Hex(`${toSign}${secret}`);
}

// مطابقة لـ hasPerm('orders') في firestore.rules، على ملف المستخدم كما تعيده Firestore
export function canManageOrders(fields = {}) {
  if (fields.role?.stringValue !== "admin") return false;
  if (SUPER_PHONES.includes(fields.phone?.stringValue)) return true;
  if (fields.systemRole?.stringValue === "assistantAdmin") return true;
  const permissions = fields.permissions?.mapValue?.fields ?? {};
  return Object.keys(permissions).length === 0 || permissions.orders?.booleanValue === true;
}

export async function receiptDownloadUrl({ cloudName, apiKey, apiSecret, orderId, format, nowSeconds }) {
  const params = {
    expires_at: String(nowSeconds + RECEIPT_LINK_SECONDS),
    format,
    public_id: receiptPublicId(orderId),
    timestamp: String(nowSeconds),
    type: "authenticated",
  };
  const signature = await signCloudinary(params, apiSecret);
  const query = new URLSearchParams({ ...params, api_key: apiKey, signature });
  return `https://api.cloudinary.com/v1_1/${cloudName}/image/download?${query}`;
}
