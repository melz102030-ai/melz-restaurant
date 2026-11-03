// node --test cloudflare/lean-payments/pricing.test.mjs
import test from "node:test";
import assert from "node:assert/strict";
import { priceOrder, isRestaurantOpen, distanceKm, OrderRejected } from "./pricing.js";

const OPEN_SETTINGS = { minOrderAmount: 5, deliveryFee: 10, openTime: "", closeTime: "" };

const sauces = {
  id: "sauces",
  name: "الصوصات",
  price: 3,
  excludeBasePrice: true,
  optionGroups: [
    {
      id: "g1",
      name: "اختر الصوص",
      type: "multiple",
      required: true,
      allowQuantity: true,
      options: [
        { id: "garlic", name: "ثوم", priceAdjustment: 3 },
        { id: "hot", name: "حار", priceAdjustment: 3 },
        { id: "off", name: "متوقف", priceAdjustment: 3, isAvailable: false },
      ],
    },
  ],
};
const burger = {
  id: "burger",
  name: "برجر",
  price: 20,
  discountPercent: 10,
  optionGroups: [
    {
      id: "size",
      name: "الحجم",
      type: "single",
      options: [
        { id: "s", name: "عادي", priceAdjustment: 0 },
        { id: "l", name: "كبير", priceAdjustment: 5 },
      ],
    },
  ],
};
const combo = {
  id: "c1",
  name: "وجبة",
  price: 30,
  items: [{ itemId: "burger", qty: 1 }],
  optionItemIds: ["sauces"],
};

const itemsById = new Map([["sauces", sauces], ["burger", burger]]);
const combosById = new Map([["c1", combo]]);

const price = (request, settings = OPEN_SETTINGS, zones = []) =>
  priceOrder({
    request: { paymentMethod: "cash", orderType: "pickup", ...request },
    settings,
    zones,
    itemsById,
    combosById,
  });

const rejectsWith = (fn, code) =>
  assert.throws(fn, (e) => e instanceof OrderRejected && e.code === code);

test("صنف لا يُحتسب سعره: المبلغ من الخيارات وعددها فقط", () => {
  const r = price({
    items: [{ itemId: "sauces", quantity: 1, options: [{ groupId: "g1", selectedIds: ["garlic*2", "hot"] }] }],
  });
  assert.equal(r.total, 9);
  assert.deepEqual(r.items[0].selectedOptions[0].selectedNames, ["ثوم ×2", "حار"]);
  assert.equal(r.items[0].selectedOptions[0].extra, 9);
  assert.equal(r.items[0].displayQuantity, 3, "الكمية المعروضة مجموع الخيارات");
  assert.equal(r.items[0].quantity, 1, "كمية الحساب لا تتغير");
});

test("نفس تركيبة صنف لا يُحتسب سعره مرتين: العدد المعروض يتضاعف والإجمالي صحيح", () => {
  const r = price({
    items: [{ itemId: "sauces", quantity: 2, options: [{ groupId: "g1", selectedIds: ["garlic*2", "hot"] }] }],
  });
  assert.equal(r.total, 18);
  assert.equal(r.items[0].price, 9);
  assert.equal(r.items[0].quantity, 2);
  assert.equal(r.items[0].displayQuantity, 6);
  assert.deepEqual(r.items[0].selectedOptions[0].selectedNames, ["ثوم ×4", "حار ×2"]);
});

test("الخصم والخيار والكمية تدخل في السعر، وتجاهل أي سعر يرسله العميل", () => {
  const r = price({
    items: [{ itemId: "burger", quantity: 2, price: 1, total: 1, options: [{ groupId: "size", selectedIds: ["l"] }] }],
  });
  assert.equal(r.items[0].price, 23);
  assert.equal(r.items[0].displayQuantity, undefined);
  assert.equal(r.subtotal, 46);
  assert.equal(r.total, 46);
});

test("التركيبة: السعر في سطر الرأس وأصنافها بسعر صفر", () => {
  const r = price({ combos: [{ comboId: "c1", quantity: 2, optionItemId: "sauces" }] });
  assert.equal(r.total, 60);
  assert.deepEqual(r.items.map((l) => l.price), [30, 0, 0]);
  assert.equal(r.items[0].menuItemId, "combo_c1");
  assert.equal(r.items[1].name, "↳ برجر");
});

test("رفض: مبلغ معروض مختلف، خيار متوقف، خيار إجباري ناقص، زيادة عدد غير مسموحة", () => {
  const sauce = { itemId: "sauces", quantity: 1, options: [{ groupId: "g1", selectedIds: ["garlic"] }] };
  rejectsWith(() => price({ items: [sauce, sauce, sauce, sauce], expectedTotal: 1 }), "price-changed");
  rejectsWith(
    () => price({ items: [{ itemId: "sauces", quantity: 4, options: [{ groupId: "g1", selectedIds: ["off"] }] }] }),
    "option-unavailable"
  );
  rejectsWith(() => price({ items: [{ itemId: "sauces", quantity: 4 }] }), "required-option-missing");
  rejectsWith(
    () => price({ items: [{ itemId: "burger", quantity: 1, options: [{ groupId: "size", selectedIds: ["l*2"] }] }] }),
    "invalid-option"
  );
  rejectsWith(
    () => price({ items: [{ itemId: "burger", quantity: 1, options: [{ groupId: "size", selectedIds: ["s", "l"] }] }] }),
    "invalid-option"
  );
  rejectsWith(() => price({ items: [{ itemId: "burger", quantity: 0 }] }), "invalid-quantity");
  rejectsWith(() => price({ items: [{ itemId: "burger", quantity: 1.5 }] }), "invalid-quantity");
  rejectsWith(() => price({ items: [{ itemId: "ghost", quantity: 1 }] }), "item-unavailable");
  rejectsWith(() => price({ combos: [{ comboId: "c1", quantity: 1 }] }), "required-option-missing");
  rejectsWith(() => price({}), "empty-order");
});

test("الحد الأدنى وطرق الدفع", () => {
  const one = { items: [{ itemId: "burger", quantity: 1 }] };
  rejectsWith(() => price(one, { ...OPEN_SETTINGS, minOrderAmount: 100 }), "below-minimum");
  rejectsWith(() => price(one, { ...OPEN_SETTINGS, cashPaymentPolicy: "disabled" }), "cash-not-allowed");
  rejectsWith(() => price({ ...one, paymentMethod: "manualBankTransfer" }), "transfer-not-allowed");
  rejectsWith(() => price({ ...one, paymentMethod: "card" }), "payment-not-allowed");
  const r = price({ ...one, paymentMethod: "manualBankTransfer" }, { ...OPEN_SETTINGS, bankIban: "SA00" });
  assert.equal(r.paymentMethod, "manualBankTransfer");
});

test("التوصيل: رسم ثابت، نطاقات، خارج النطاق، وتعطيل التوصيل يحوّل لاستلام", () => {
  const order = { orderType: "delivery", deliveryLat: 24.8, deliveryLng: 46.7, items: [{ itemId: "burger", quantity: 1 }] };
  assert.equal(price(order).total, 28);
  assert.equal(price({ ...order, deliveryLat: undefined }, { ...OPEN_SETTINGS, deliveryEnabled: false }).orderType, "pickup");
  rejectsWith(() => price({ ...order, deliveryLat: undefined }), "location-required");

  const zoned = { ...OPEN_SETTINGS, useDeliveryZones: true, restaurantLat: 24.8, restaurantLng: 46.7 };
  const zones = [
    { id: "far", name: "بعيد", maxDistanceKm: 20, fee: 25 },
    { id: "near", name: "قريب", maxDistanceKm: 5, fee: 7 },
  ];
  const near = price(order, zoned, zones);
  assert.equal(near.deliveryFee, 7);
  assert.equal(near.deliveryZoneId, "near");
  assert.equal(price({ ...order, deliveryLat: 24.9 }, zoned, zones).deliveryFee, 25);
  rejectsWith(() => price({ ...order, deliveryLat: 26 }, zoned, zones), "outside-service-area");
});

test("أوقات العمل بتوقيت الرياض بغض النظر عن الجهاز", () => {
  // 2026-11-03 هو يوم ثلاثاء؛ 20:00 UTC = 23:00 بتوقيت الرياض
  const at = (iso) => Date.parse(iso);
  const s = { workingHours: { tue: [{ open: "16:00", close: "23:30" }], wed: [] } };
  assert.equal(isRestaurantOpen(s, at("2026-11-03T20:00:00Z")), true);
  assert.equal(isRestaurantOpen(s, at("2026-11-03T21:00:00Z")), false);
  assert.equal(isRestaurantOpen(s, at("2026-11-04T10:00:00Z")), false, "الأربعاء عطلة");

  const overnight = { openTime: "22:00", closeTime: "02:00" };
  assert.equal(isRestaurantOpen(overnight, at("2026-11-03T22:00:00Z")), true, "01:00 بعد منتصف الليل");
  assert.equal(isRestaurantOpen(overnight, at("2026-11-03T10:00:00Z")), false);

  assert.equal(isRestaurantOpen({ ...s, isOpen: false }, at("2026-11-03T20:00:00Z")), false);
  assert.equal(isRestaurantOpen({ allowOrders: false, openTime: "", closeTime: "" }), false);
  rejectsWith(
    () => priceOrder({
      request: { items: [{ itemId: "burger", quantity: 1 }], paymentMethod: "cash" },
      settings: { ...OPEN_SETTINGS, isOpen: false }, zones: [], itemsById, combosById,
    }),
    "restaurant-closed"
  );
});

test("حساب المسافة قريب من القيمة المعروفة", () => {
  // درجة عرض واحدة ≈ 111.3 كم بنصف القطر المستخدم
  assert.ok(Math.abs(distanceKm(24, 46, 25, 46) - 111.3) < 0.5);
});
