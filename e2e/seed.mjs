// يملأ المحاكي ببيانات الرحلة. كل الكتابة هنا على المحاكي المحلي فقط
export const PROJECT = "demo-melz";
export const DOCS = `http://127.0.0.1:8080/v1/projects/${PROJECT}/databases/(default)/documents`;
const AUTH = "http://127.0.0.1:9099/identitytoolkit.googleapis.com/v1";

export const KITCHEN = { phone: "0500000001", password: "kitchen-pass" };
export const ADMIN = { phone: "0500000002", password: "admin-pass" };

function toFs(value) {
  if (value === null) return { nullValue: null };
  if (typeof value === "string") return { stringValue: value };
  if (typeof value === "boolean") return { booleanValue: value };
  if (typeof value === "number") {
    return Number.isInteger(value) ? { integerValue: String(value) } : { doubleValue: value };
  }
  if (value instanceof Date) return { timestampValue: value.toISOString() };
  if (Array.isArray(value)) return { arrayValue: { values: value.map(toFs) } };
  return { mapValue: { fields: Object.fromEntries(Object.entries(value).map(([k, v]) => [k, toFs(v)])) } };
}

export function fromFs(value) {
  if (!value || "nullValue" in value) return null;
  if ("stringValue" in value) return value.stringValue;
  if ("booleanValue" in value) return value.booleanValue;
  if ("integerValue" in value) return Number(value.integerValue);
  if ("doubleValue" in value) return value.doubleValue;
  if ("timestampValue" in value) return value.timestampValue;
  if ("arrayValue" in value) return (value.arrayValue.values ?? []).map(fromFs);
  if ("mapValue" in value) {
    return Object.fromEntries(Object.entries(value.mapValue.fields ?? {}).map(([k, v]) => [k, fromFs(v)]));
  }
  return null;
}

const OWNER = { Authorization: "Bearer owner", "Content-Type": "application/json" };

async function put(path, data) {
  const fields = toFs(data).mapValue.fields;
  const res = await fetch(`${DOCS}/${path}`, { method: "PATCH", headers: OWNER, body: JSON.stringify({ fields }) });
  if (!res.ok) throw new Error(`seed ${path}: ${res.status} ${await res.text()}`);
}

export async function readDoc(path) {
  const res = await fetch(`${DOCS}/${path}`, { headers: OWNER });
  if (!res.ok) throw new Error(`read ${path}: ${res.status}`);
  return fromFs({ mapValue: { fields: (await res.json()).fields } });
}

async function createStaff({ phone, password }, role, name) {
  const res = await fetch(`${AUTH}/accounts:signUp?key=e2e`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ email: `${phone}@meals.local`, password, returnSecureToken: true }),
  });
  if (!res.ok) throw new Error(`staff ${phone}: ${res.status} ${await res.text()}`);
  const { localId } = await res.json();
  await put(`users/${localId}`, { role, name, phone, createdAt: new Date(), isAvailable: true });
}

const sauce = (id, name) => ({ id, name, priceAdjustment: 1, isAvailable: true });

export async function seed() {
  await put("settings/restaurant", {
    restaurantName: "اختبار",
    isOpen: true,
    allowOrders: true,
    openTime: "",
    closeTime: "",
    minOrderAmount: 1,
    deliveryFee: 10,
    deliveryEnabled: false,
    useDeliveryZones: false,
    cashPaymentPolicy: "both",
    bankTransferEnabled: false,
    estimatedPrepTime: 20,
    restaurantPhone: "0500000000",
  });
  await put("categories/c1", { name: "الأصناف", sortOrder: 0, isActive: true });
  await put("menu_items/sauces", {
    name: "صوصات", description: "", categoryId: "c1", categoryName: "الأصناف",
    price: 1, excludeBasePrice: true, isAvailable: true, sortOrder: 0,
    optionGroups: [{
      id: "g1", name: "اختيار الصوص", type: "multiple", required: true, allowQuantity: true,
      options: [sauce("cocktail", "صوص كوكتيل"), sauce("ketchup", "صوص كاتشب")],
    }],
  });
  await createStaff(KITCHEN, "kitchen", "مطبخ");
  await createStaff(ADMIN, "admin", "مدير");
}
