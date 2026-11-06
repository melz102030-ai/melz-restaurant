// node --test cloudflare/lean-payments/pricing.test.mjs
import test from "node:test";
import assert from "node:assert/strict";
import {
  priceOrder,
  isRestaurantOpen,
  distanceKm,
  removeUnavailableItems,
  setOptionAvailability,
  OrderRejected,
  customerContact,
} from "./pricing.js";

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
  assert.deepEqual(r.items[0].selectedOptions[0].selectedNames, ["×2 ثوم", "×1 حار"]);
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
  assert.deepEqual(r.items[0].selectedOptions[0].selectedNames, ["×4 ثوم", "×2 حار"]);
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
  // العميل والمطبخ والفاتورة يرون اسم الوجبة وحده
  assert.equal(r.items[0].name, "وجبة");
  assert.equal(r.items[1].name, "↳ برجر");
});

test("رفض التركيبة: صنف ثابت متوقف أو محذوف، أو خيار مختار متوقف", () => {
  const priceWith = (items) =>
    priceOrder({
      request: {
        paymentMethod: "cash",
        orderType: "pickup",
        combos: [{ comboId: "c1", quantity: 1, optionItemId: "sauces" }],
      },
      settings: OPEN_SETTINGS,
      zones: [],
      itemsById: new Map(items),
      combosById,
    });
  const off = (item) => ({ ...item, isAvailable: false });

  rejectsWith(() => priceWith([["sauces", sauces], ["burger", off(burger)]]), "item-unavailable");
  rejectsWith(() => priceWith([["sauces", sauces]]), "item-unavailable");
  rejectsWith(() => priceWith([["sauces", off(sauces)], ["burger", burger]]), "item-unavailable");
  assert.equal(priceWith([["sauces", sauces], ["burger", burger]]).total, 30);
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

test("اسم العميل ورقمه يُقصَّان قبل وصولهما للمطبخ والفاتورة", () => {
  const { customerName, customerPhone } = customerContact({ name: "ا".repeat(5000), phone: "5".repeat(500) });
  assert.equal(customerName.length, 60);
  assert.equal(customerPhone.length, 20);
  assert.deepEqual(customerContact({ name: " علي ", phone: "05" }), { customerName: "علي", customerPhone: "05" });
  assert.deepEqual(customerContact(null), { customerName: "", customerPhone: "" });
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

  // فترة تمتد لبعد منتصف الليل تُحسب على اليوم الذي بدأت فيه
  const night = { workingHours: { mon: [{ open: "16:00", close: "04:00" }], tue: [] } };
  assert.equal(isRestaurantOpen(night, at("2026-11-02T20:00:00Z")), true, "الإثنين 23:00");
  assert.equal(isRestaurantOpen(night, at("2026-11-02T23:00:00Z")), true, "الثلاثاء 02:00 ضمن فترة الإثنين");
  assert.equal(isRestaurantOpen(night, at("2026-11-03T02:00:00Z")), false, "الثلاثاء 05:00 بعد الإغلاق");
  assert.equal(isRestaurantOpen(night, at("2026-11-03T15:00:00Z")), false, "الثلاثاء عطلة");
  assert.equal(isRestaurantOpen(night, at("2026-11-01T23:00:00Z")), false, "الإثنين 02:00 قبل بدء الفترة");

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

test("إزالة الأصناف غير المتوفرة تعيد الحساب من الأسطر المحفوظة ورسوم التوصيل", () => {
  const order = {
    status: "confirmed",
    deliveryFee: 10,
    unavailableItemIds: ["b"],
    items: [
      { menuItemId: "a", price: 12.5, quantity: 2 },
      { menuItemId: "b", price: 30, quantity: 1 },
      { menuItemId: "c", price: 4, quantity: 3 },
    ],
  };
  const r = removeUnavailableItems(order);
  assert.deepEqual(r.items.map((i) => i.menuItemId), ["a", "c"]);
  assert.equal(r.subtotal, 37);
  assert.equal(r.total, 47);
  assert.deepEqual(r.unavailableItemIds, []);

  assert.equal(removeUnavailableItems({ ...order, unavailableItemIds: [] }), null, "نقرة مكررة لا تغيّر شيئاً");
  rejectsWith(() => removeUnavailableItems({ ...order, status: "cancelled" }), "order-closed");
  rejectsWith(() => removeUnavailableItems({ ...order, unavailableItemIds: ["a", "b", "c"] }), "nothing-left");
});

test("توقيف خيار يغيّر توفره فقط ويبقي السعر والبقية كما هي", () => {
  const option = (id) => ({
    mapValue: { fields: { id: { stringValue: id }, name: { stringValue: id }, priceAdjustment: { integerValue: "3" } } },
  });
  const value = () => ({
    arrayValue: {
      values: [
        { mapValue: { fields: { id: { stringValue: "g1" }, options: { arrayValue: { values: [option("a"), option("b")] } } } } },
      ],
    },
  });
  const updated = setOptionAvailability(value(), "g1", "b", false);
  const [a, b] = updated.arrayValue.values[0].mapValue.fields.options.arrayValue.values;
  assert.deepEqual(b.mapValue.fields.isAvailable, { booleanValue: false });
  assert.deepEqual(b.mapValue.fields.priceAdjustment, { integerValue: "3" });
  assert.equal(a.mapValue.fields.isAvailable, undefined);

  rejectsWith(() => setOptionAvailability(value(), "g1", "ghost", false), "option-not-found");
  rejectsWith(() => setOptionAvailability(value(), "ghost", "a", false), "option-not-found");
});

test("حساب المسافة قريب من القيمة المعروفة", () => {
  // درجة عرض واحدة ≈ 111.3 كم بنصف القطر المستخدم
  assert.ok(Math.abs(distanceKm(24, 46, 25, 46) - 111.3) < 0.5);
});

test("وجبة على الصنف: تزيد سعره وتُحفظ ضمن خياراته لا سطراً مستقلاً", () => {
  const fries = { id: "fries", name: "بطاطس", price: 3 };
  const pepsi = { id: "pepsi", name: "بيبسي", price: 2 };
  const meal = { id: "m1", name: "وجبة كاملة", price: 5, linkedItemIds: ["burger"], items: [{ itemId: "fries" }], optionItemIds: ["pepsi"] };
  const run = (req, items = [["burger", burger], ["fries", fries], ["pepsi", pepsi]], combos = [["m1", meal]]) =>
    priceOrder({
      request: { paymentMethod: "cash", orderType: "pickup", items: [{ itemId: "burger", quantity: 2, ...req }] },
      settings: OPEN_SETTINGS,
      zones: [],
      itemsById: new Map(items),
      combosById: new Map(combos),
    });

  const r = run({ comboId: "m1", comboOptionItemId: "pepsi" });
  assert.equal(r.items.length, 1, "سطر واحد للصنف بلا سطر للوجبة");
  assert.equal(r.items[0].price, 23); // 18 بعد الخصم + 5
  assert.equal(r.total, 46);
  assert.deepEqual(r.items[0].selectedOptions.at(-1), { groupName: "وجبة كاملة", selectedNames: ["بطاطس", "بيبسي"], extra: 5 });

  rejectsWith(() => run({ comboId: "m1" }), "required-option-missing");
  rejectsWith(() => run({ comboId: "m1", comboOptionItemId: "pepsi" }, undefined, [["m1", { ...meal, linkedItemIds: ["other"] }]]), "item-unavailable");
  rejectsWith(() => run({ comboId: "m1", comboOptionItemId: "pepsi" }, [["burger", burger], ["pepsi", pepsi]]), "item-unavailable");
  rejectsWith(() => run({ comboId: "gone", comboOptionItemId: "pepsi" }), "item-unavailable");
});

test("مجموعة خيارات مكررة في بيانات قديمة تُحسب وتظهر مرة واحدة", () => {
  const dup = { ...burger, optionGroups: [burger.optionGroups[0], burger.optionGroups[0]] };
  const r = priceOrder({
    request: { paymentMethod: "cash", orderType: "pickup", items: [{ itemId: "burger", quantity: 1, options: [{ groupId: "size", selectedIds: ["l"] }] }] },
    settings: OPEN_SETTINGS,
    zones: [],
    itemsById: new Map([["burger", dup]]),
    combosById: new Map(),
  });
  assert.equal(r.items[0].selectedOptions.length, 1);
  assert.equal(r.total, 23);
});
