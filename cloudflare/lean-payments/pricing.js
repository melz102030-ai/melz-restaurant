// حساب الطلب من جهة الخادم — المصدر الوحيد الموثوق لأسعار الطلب وإجماليه.
// العميل يرسل معرّفات الأصناف والخيارات والكميات فقط؛ كل سعر هنا يُقرأ من
// قاعدة البيانات، حتى لا يؤثر أي تلاعب في المتصفح على المبلغ.
// دوال نقية بلا أي اتصال بالشبكة، ومغطّاة باختبارات pricing.test.mjs.

export class OrderRejected extends Error {
  constructor(code, message, status = 400) {
    super(message);
    this.code = code;
    this.status = status;
  }
}

const MAX_LINES = 50;
const MAX_QTY = 99;
const MAX_NOTE = 120;
const MAX_ORDER_NOTES = 500;
const MAX_ADDRESS = 300;
// فرق التقريب المسموح بين ما عرضه التطبيق وما حسبه الخادم
const TOTAL_TOLERANCE = 0.05;
const EARTH_RADIUS_M = 6378137; // نفس قيمة Geolocator.distanceBetween في التطبيق
const RIYADH_OFFSET_MS = 3 * 60 * 60 * 1000;

const round2 = (n) => Math.round((n + Number.EPSILON) * 100) / 100;

const cleanText = (v, max) => {
  if (typeof v !== "string") return null;
  const t = v.trim().slice(0, max);
  return t.length ? t : null;
};

function validQty(v) {
  if (!Number.isInteger(v) || v < 1 || v > MAX_QTY) {
    throw new OrderRejected("invalid-quantity", "كمية غير صحيحة في الطلب");
  }
  return v;
}

// الخيار يصل بصيغة "id" أو "id*3" (نفس صيغة selectedIds في سلة التطبيق)
function parseSelectedId(raw) {
  if (typeof raw !== "string" || !raw) {
    throw new OrderRejected("invalid-option", "خيار غير صحيح في الطلب");
  }
  const star = raw.lastIndexOf("*");
  if (star < 0) return { id: raw, qty: 1 };
  return { id: raw.slice(0, star), qty: validQty(Number(raw.slice(star + 1))) };
}

function itemBasePrice(item) {
  if (item.excludeBasePrice === true) return 0;
  const price = Number(item.price ?? 0);
  const discount = Number(item.discountPercent ?? 0);
  return discount > 0 ? price * (1 - discount / 100) : price;
}

// يتحقق من خيارات صنف واحد ويعيد فرق سعرها وشكلها المحفوظ في الطلب
function priceOptions(item, requested) {
  const groups = Array.isArray(item.optionGroups) ? item.optionGroups : [];
  const byGroup = new Map();
  for (const entry of Array.isArray(requested) ? requested : []) {
    const group = groups.find((g) => g.id === entry?.groupId);
    if (!group) {
      throw new OrderRejected(
        "item-changed",
        `تغيّرت خيارات "${item.name}"، احذفه من السلة وأضفه من جديد`,
        409
      );
    }
    byGroup.set(group.id, Array.isArray(entry.selectedIds) ? entry.selectedIds : []);
  }

  let extra = 0;
  const selectedOptions = [];
  for (const group of groups) {
    const parsed = (byGroup.get(group.id) ?? []).map(parseSelectedId);
    if (parsed.length === 0) {
      if (group.required === true) {
        throw new OrderRejected(
          "required-option-missing",
          `اختر "${group.name}" في "${item.name}"`
        );
      }
      continue;
    }
    if (group.type !== "multiple" && parsed.length > 1) {
      throw new OrderRejected("invalid-option", `اختر خياراً واحداً فقط من "${group.name}"`);
    }

    let groupExtra = 0;
    const names = [];
    for (const opt of group.options ?? []) {
      const sel = parsed.find((p) => p.id === opt.id);
      if (!sel) continue;
      if (opt.isAvailable === false) {
        throw new OrderRejected(
          "option-unavailable",
          `الخيار "${opt.name}" غير متوفر حالياً، عدّل "${item.name}" في السلة`,
          409
        );
      }
      if (sel.qty > 1 && group.allowQuantity !== true) {
        throw new OrderRejected("invalid-option", `لا يمكن زيادة عدد "${opt.name}"`);
      }
      groupExtra += Number(opt.priceAdjustment ?? 0) * sel.qty;
      names.push(sel.qty > 1 ? `${opt.name} ×${sel.qty}` : opt.name);
    }
    if (names.length !== parsed.length) {
      throw new OrderRejected(
        "item-changed",
        `تغيّرت خيارات "${item.name}"، احذفه من السلة وأضفه من جديد`,
        409
      );
    }
    extra += groupExtra;
    selectedOptions.push({ groupName: group.name, selectedNames: names, extra: groupExtra });
  }
  return { extra, selectedOptions };
}

function orderLine({ menuItemId, name, price, quantity, imageUrl, selectedOptions = [], note }) {
  return {
    menuItemId,
    name,
    price,
    quantity,
    imageUrl: imageUrl ?? null,
    selectedOptions,
    ...(note ? { note } : {}),
  };
}

// يبني أسطر الطلب من طلب العميل وبيانات الأصناف والتركيبات الحية
export function buildOrderLines(request, itemsById, combosById) {
  const reqItems = Array.isArray(request.items) ? request.items : [];
  const reqCombos = Array.isArray(request.combos) ? request.combos : [];
  if (reqItems.length + reqCombos.length === 0) {
    throw new OrderRejected("empty-order", "السلة فارغة");
  }
  if (reqItems.length + reqCombos.length > MAX_LINES) {
    throw new OrderRejected("too-many-lines", "عدد أصناف الطلب كبير جداً");
  }

  const lines = [];
  let subtotal = 0;

  for (const req of reqItems) {
    const item = itemsById.get(req?.itemId);
    const quantity = validQty(req?.quantity);
    if (!item) {
      throw new OrderRejected("item-unavailable", "أحد أصناف السلة لم يعد موجوداً، احذفه وحاول مجدداً", 409);
    }
    if (item.isAvailable === false) {
      throw new OrderRejected("item-unavailable", `"${item.name}" غير متوفر حالياً، احذفه من السلة`, 409);
    }
    const { extra, selectedOptions } = priceOptions(item, req.options);
    const unit = itemBasePrice(item) + extra;
    subtotal += unit * quantity;
    lines.push(
      orderLine({
        menuItemId: item.id,
        name: item.name,
        price: unit,
        quantity,
        imageUrl: item.imageUrl,
        selectedOptions,
        note: cleanText(req.note, MAX_NOTE),
      })
    );
  }

  for (const req of reqCombos) {
    const combo = combosById.get(req?.comboId);
    const quantity = validQty(req?.quantity);
    if (!combo || combo.isActive === false) {
      throw new OrderRejected("item-unavailable", "إحدى التركيبات في السلة لم تعد متوفرة، احذفها وحاول مجدداً", 409);
    }
    const optionIds = Array.isArray(combo.optionItemIds) ? combo.optionItemIds : [];
    if (optionIds.length > 0 && !optionIds.includes(req.optionItemId)) {
      throw new OrderRejected("required-option-missing", `اختر صنفاً من تركيبة "${combo.name}"`);
    }

    const price = Number(combo.price ?? 0);
    subtotal += price * quantity;
    lines.push(
      orderLine({
        menuItemId: `combo_${combo.id}`,
        name: `تركيبة: ${combo.name}`,
        price,
        quantity,
        imageUrl: combo.imageUrl,
      })
    );

    // أصناف التركيبة تُحفظ بسعر صفر حتى يراها المطبخ، والسعر كله في سطر الرأس
    const subIds = [
      ...(Array.isArray(combo.items) ? combo.items.map((r) => r.itemId) : []),
      ...(optionIds.length > 0 ? [req.optionItemId] : []),
    ];
    for (const id of subIds) {
      const sub = itemsById.get(id);
      if (!sub) continue;
      lines.push(
        orderLine({
          menuItemId: sub.id,
          name: `↳ ${sub.name}`,
          price: 0,
          quantity,
          imageUrl: sub.imageUrl,
        })
      );
    }
  }

  return { lines, subtotal: round2(subtotal) };
}

export function distanceKm(lat1, lng1, lat2, lng2) {
  const rad = (d) => (d * Math.PI) / 180;
  const dLat = rad(lat2 - lat1);
  const dLng = rad(lng2 - lng1);
  const a =
    Math.sin(dLat / 2) ** 2 +
    Math.sin(dLng / 2) ** 2 * Math.cos(rad(lat1)) * Math.cos(rad(lat2));
  return (EARTH_RADIUS_M * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))) / 1000;
}

function resolveDelivery(settings, zones, lat, lng) {
  const flatFee = Number(settings.deliveryFee ?? 10);
  const hasLocation = settings.restaurantLat != null && settings.restaurantLng != null;
  if (settings.useDeliveryZones !== true || !hasLocation || zones.length === 0) {
    return { fee: flatFee, zoneId: null, zoneName: null };
  }
  const distance = distanceKm(settings.restaurantLat, settings.restaurantLng, lat, lng);
  const sorted = [...zones].sort((a, b) => Number(a.maxDistanceKm ?? 0) - Number(b.maxDistanceKm ?? 0));
  const zone = sorted.find((z) => distance <= Number(z.maxDistanceKm ?? 0));
  if (!zone) {
    throw new OrderRejected("outside-service-area", "عذراً، موقعك خارج نطاق التوصيل المتاح");
  }
  return { fee: Number(zone.fee ?? 0), zoneId: zone.id, zoneName: zone.name ?? "" };
}

function minutesOf(hhmm) {
  const parts = String(hhmm).trim().split(":");
  if (parts.length !== 2) return null;
  const h = Number.parseInt(parts[0], 10);
  const m = Number.parseInt(parts[1], 10);
  return Number.isNaN(h) || Number.isNaN(m) ? null : h * 60 + m;
}

// true/false حسب وقوع الدقيقة الحالية ضمن فترة، مع تجاوز منتصف الليل (22:00 - 02:00)
function inShift(nowMin, open, close) {
  if (close <= open) return nowMin > open || nowMin < close;
  return nowMin > open && nowMin < close;
}

// نفس منطق effectivelyOpen في التطبيق، لكن بتوقيت الرياض دائماً لا بساعة الجهاز
export function isRestaurantOpen(settings, nowMs = Date.now()) {
  if (settings.isOpen === false || settings.allowOrders === false) return false;

  const riyadh = new Date(nowMs + RIYADH_OFFSET_MS);
  const nowMin = riyadh.getUTCHours() * 60 + riyadh.getUTCMinutes() + riyadh.getUTCSeconds() / 60;
  const hours = settings.workingHours;

  if (hours && typeof hours === "object" && Object.keys(hours).length > 0) {
    const dayKey = ["sun", "mon", "tue", "wed", "thu", "fri", "sat"][riyadh.getUTCDay()];
    for (const shift of Array.isArray(hours[dayKey]) ? hours[dayKey] : []) {
      const open = minutesOf(shift.open ?? "08:00");
      const close = minutesOf(shift.close ?? "22:00");
      if (open != null && close != null && inShift(nowMin, open, close)) return true;
    }
    return false;
  }

  const openTime = settings.openTime ?? "08:00";
  const closeTime = settings.closeTime ?? "00:00";
  if (!openTime || !closeTime) return true;
  const open = minutesOf(openTime);
  const close = minutesOf(closeTime);
  if (open == null || close == null) return true;
  return inShift(nowMin, open, close);
}

function cashAllowed(settings, isDelivery) {
  switch (settings.cashPaymentPolicy) {
    case "disabled":
      return false;
    case "deliveryOnly":
      return isDelivery;
    case "pickupOnly":
      return !isDelivery;
    default:
      return true;
  }
}

function checkPayment(method, settings, isDelivery) {
  if (method === "cash") {
    if (!cashAllowed(settings, isDelivery)) {
      throw new OrderRejected(
        "cash-not-allowed",
        isDelivery ? "الدفع نقداً غير متاح للتوصيل حالياً" : "الدفع نقداً غير متاح للاستلام من المطعم حالياً"
      );
    }
    return;
  }
  if (method === "manualBankTransfer") {
    const enabled = settings.bankTransferEnabled !== false;
    if (!enabled || !String(settings.bankIban ?? "").trim()) {
      throw new OrderRejected("transfer-not-allowed", "التحويل البنكي غير متاح حالياً");
    }
    return;
  }
  // الدفع عبر لين مؤجَّل في التطبيق، وتُضاف هنا طرق الدفع الجديدة عند تفعيلها
  throw new OrderRejected("payment-not-allowed", "طريقة الدفع غير متاحة حالياً");
}

// يتحقق من كل شروط الطلب ويحسبه بالكامل. يعيد الحقول المالية وحقول التوصيل
// الجاهزة للحفظ، أو يرمي OrderRejected برسالة تُعرض للعميل كما هي.
export function priceOrder({ request, settings, zones, itemsById, combosById, nowMs = Date.now() }) {
  if (!isRestaurantOpen(settings, nowMs)) {
    throw new OrderRejected("restaurant-closed", "المطعم مغلق حالياً، لا يمكن إرسال الطلب");
  }

  const { lines, subtotal } = buildOrderLines(request, itemsById, combosById);

  const minOrder = Number(settings.minOrderAmount ?? 30);
  if (subtotal < minOrder) {
    throw new OrderRejected("below-minimum", `الحد الأدنى للطلب ${minOrder.toFixed(0)} ر.س`);
  }

  const isDelivery = settings.deliveryEnabled !== false && request.orderType === "delivery";
  let delivery = { fee: 0, zoneId: null, zoneName: null };
  let lat = null;
  let lng = null;
  if (isDelivery) {
    lat = request.deliveryLat;
    lng = request.deliveryLng;
    const validCoords =
      Number.isFinite(lat) && Number.isFinite(lng) && Math.abs(lat) <= 90 && Math.abs(lng) <= 180;
    if (!validCoords) {
      throw new OrderRejected("location-required", "الرجاء تحديد موقع التوصيل على الخريطة أولاً");
    }
    delivery = resolveDelivery(settings, zones, lat, lng);
  }

  checkPayment(request.paymentMethod, settings, isDelivery);

  const total = round2(subtotal + delivery.fee);

  // السعر الذي رآه العميل قد يكون قديماً (سلة محفوظة قبل تعديل الأسعار) —
  // لا يُحفظ طلب بمبلغ مختلف عمّا وافق عليه
  if (
    typeof request.expectedTotal === "number" &&
    Math.abs(request.expectedTotal - total) > TOTAL_TOLERANCE
  ) {
    throw new OrderRejected(
      "price-changed",
      `تغيّر إجمالي طلبك إلى ${total.toFixed(2)} ر.س بسبب تحديث الأسعار. احذف الأصناف من السلة وأضفها من جديد`,
      409
    );
  }

  return {
    items: lines,
    subtotal,
    deliveryFee: delivery.fee,
    total,
    orderType: isDelivery ? "delivery" : "pickup",
    deliveryLat: lat,
    deliveryLng: lng,
    deliveryAddress: isDelivery ? cleanText(request.deliveryAddress, MAX_ADDRESS) : null,
    deliveryZoneId: delivery.zoneId,
    deliveryZoneName: delivery.zoneName,
    paymentMethod: request.paymentMethod,
    notes: cleanText(request.notes, MAX_ORDER_NOTES),
  };
}
