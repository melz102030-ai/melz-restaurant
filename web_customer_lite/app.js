'use strict';

if ('serviceWorker' in navigator) {
  navigator.serviceWorker.register('sw.js').catch(function () {});
}

firebase.initializeApp({
  apiKey: 'AIzaSyC6DBWYEkTNv7QE0P7MAbtJSlSc6YiJnw0',
  appId: '1:576056016616:web:54675719dc0de0da22535d',
  messagingSenderId: '576056016616',
  projectId: 'melz-restaurant',
  authDomain: 'melz-restaurant.firebaseapp.com',
  storageBucket: 'melz-restaurant.firebasestorage.app',
});
var auth = firebase.auth();
var db = firebase.firestore();

var CART_KEY = 'customer_lite_cart_v1';
var WEEKDAY_KEYS = ['sun', 'mon', 'tue', 'wed', 'thu', 'fri', 'sat'];

var state = {
  settings: { restaurantName: 'Meals', deliveryFee: 10, minOrderAmount: 30, cashPaymentPolicy: 'both', estimatedPrepTime: 30 },
  categories: [],
  items: [],
  activeCategory: null,
  query: '',
  cart: [],
  orderType: 'delivery',
  paymentMethod: 'cash',
  deliveryAddressText: '',
  deliveryLat: null,
  deliveryLng: null,
  notes: '',
  receiptUrl: null,
  currentUser: null,
};

// ─── أدوات عامة ──────────────────────────────────────────────────────────────
function $(sel, root) { return (root || document).querySelector(sel); }
function el(tag, attrs, children) {
  var e = document.createElement(tag);
  attrs = attrs || {};
  for (var k in attrs) {
    if (k === 'class') e.className = attrs[k];
    else if (k === 'html') e.innerHTML = attrs[k];
    else if (k.indexOf('on') === 0) e.addEventListener(k.slice(2), attrs[k]);
    else e.setAttribute(k, attrs[k]);
  }
  (children || []).forEach(function (c) {
    if (c == null) return;
    e.appendChild(typeof c === 'string' ? document.createTextNode(c) : c);
  });
  return e;
}
function esc(s) {
  return String(s == null ? '' : s).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
}
function toast(msg) {
  var t = el('div', { class: 'toast' }, [msg]);
  $('#toastRoot').appendChild(t);
  setTimeout(function () { t.remove(); }, 2800);
}

var ICONS = {
  search: 'M11 19a8 8 0 1 0 0-16 8 8 0 0 0 0 16zM21 21l-4.35-4.35',
  cart: 'M6 2 3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4ZM3 6h18M16 10a4 4 0 0 1-8 0',
  back: 'M19 12H5M12 19l-7-7 7-7',
  plus: 'M12 5v14M5 12h14',
  minus: 'M5 12h14',
  check: 'M20 6 9 17l-5-5',
  pin: 'M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z M12 13a3 3 0 1 0 0-6 3 3 0 0 0 0 6z',
  phone: 'M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72c.127.96.361 1.903.7 2.81a2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45c.907.339 1.85.573 2.81.7A2 2 0 0 1 22 16.92z',
  upload: 'M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4M17 8l-5-5-5 5M12 3v12',
};
function svgIcon(name, size) {
  size = size || 18;
  var svg = document.createElementNS('http://www.w3.org/2000/svg', 'svg');
  svg.setAttribute('width', size);
  svg.setAttribute('height', size);
  svg.setAttribute('viewBox', '0 0 24 24');
  svg.setAttribute('fill', 'none');
  svg.setAttribute('stroke', 'currentColor');
  svg.setAttribute('stroke-width', '2');
  svg.setAttribute('stroke-linecap', 'round');
  svg.setAttribute('stroke-linejoin', 'round');
  (ICONS[name] || '').split(' M').forEach(function (d, i) {
    var path = document.createElementNS('http://www.w3.org/2000/svg', 'path');
    path.setAttribute('d', (i === 0 ? d : 'M' + d));
    svg.appendChild(path);
  });
  return svg;
}

// ─── السلة (محلية — localStorage) ────────────────────────────────────────────
function loadCart() {
  try {
    var raw = localStorage.getItem(CART_KEY);
    state.cart = raw ? JSON.parse(raw) : [];
  } catch (e) { state.cart = []; }
}
function saveCart() {
  try { localStorage.setItem(CART_KEY, JSON.stringify(state.cart)); } catch (e) {}
}
function cartKeyFor(itemId, selectedOptions) {
  if (!selectedOptions.length) return itemId;
  return itemId + '_' + selectedOptions.map(function (g) { return g.groupId + ':' + g.selectedIds.join(','); }).join('|');
}
function addToCart(item, selectedOptions, qty) {
  var key = cartKeyFor(item.id, selectedOptions);
  var existing = state.cart.find(function (c) { return c.cartKey === key; });
  if (existing) {
    existing.quantity += qty;
  } else {
    var optionsExtra = selectedOptions.reduce(function (s, g) { return s + g.totalExtra; }, 0);
    state.cart.push({
      cartKey: key, itemId: item.id, name: item.name, imageUrl: item.imageUrl || null,
      unitPrice: item.finalPrice + optionsExtra, quantity: qty, selectedOptions: selectedOptions,
    });
  }
  saveCart();
  renderCartBadge();
}
function cartTotal() { return state.cart.reduce(function (s, c) { return s + c.unitPrice * c.quantity; }, 0); }
function cartCount() { return state.cart.reduce(function (s, c) { return s + c.quantity; }, 0); }
function renderCartBadge() {
  var n = cartCount();
  var badge = $('#cartBadge');
  badge.textContent = n;
  badge.classList.toggle('hidden', n === 0);
}

// ─── فايرستور: تحميل البيانات ─────────────────────────────────────────────────
db.doc('settings/restaurant').onSnapshot(function (snap) {
  if (snap.exists) state.settings = Object.assign({}, state.settings, snap.data());
  renderTopbar();
  renderMenu();
});

db.collection('categories').orderBy('sortOrder').onSnapshot(function (snap) {
  state.categories = snap.docs.map(function (d) { return Object.assign({ id: d.id }, d.data()); })
    .filter(function (c) { return c.isActive !== false; });
  renderCatBar();
  renderMenu();
});

db.collection('menu_items').orderBy('sortOrder').onSnapshot(function (snap) {
  state.items = snap.docs.map(function (d) {
    var m = d.data();
    return Object.assign({ id: d.id }, m, { finalPrice: (m.discountPercent > 0) ? m.price * (1 - m.discountPercent / 100) : m.price });
  });
  renderMenu();
  $('#loadingScreen').classList.add('hidden');
  $('#menuView').classList.remove('hidden');
}, function () {
  $('#loadingScreen').classList.add('hidden');
  $('#menuView').classList.remove('hidden');
});

var authReady = false;
var authReadyCallbacks = [];
auth.onAuthStateChanged(function (user) {
  state.currentUser = user;
  if (!authReady) {
    authReady = true;
    authReadyCallbacks.forEach(function (cb) { cb(); });
    authReadyCallbacks = [];
  }
});
function onceAuthReady(cb) {
  if (authReady) cb();
  else authReadyCallbacks.push(cb);
}

// ─── الهيدر وحالة الفتح/الإغلاق ───────────────────────────────────────────────
function parseHHMM(hhmm, base) {
  var parts = (hhmm || '').split(':');
  if (parts.length !== 2) return null;
  var d = new Date(base);
  d.setHours(parseInt(parts[0], 10) || 0, parseInt(parts[1], 10) || 0, 0, 0);
  return d;
}
function isEffectivelyOpen(settings) {
  if (settings.isOpen === false || settings.allowOrders === false) return false;
  var now = new Date();
  var hours = settings.workingHours;
  if (hours && Object.keys(hours).length) {
    var shifts = hours[WEEKDAY_KEYS[now.getDay()]] || [];
    if (!shifts.length) return false;
    for (var i = 0; i < shifts.length; i++) {
      var open = parseHHMM(shifts[i].open, now);
      var close = parseHHMM(shifts[i].close, now);
      if (!open || !close) continue;
      if (close <= open) { if (now >= open || now <= close) return true; }
      else if (now >= open && now <= close) return true;
    }
    return false;
  }
  if (!settings.openTime || !settings.closeTime) return true;
  var open2 = parseHHMM(settings.openTime, now);
  var close2 = parseHHMM(settings.closeTime, now);
  if (!open2 || !close2) return true;
  if (close2 <= open2) return now >= open2 || now <= close2;
  return now >= open2 && now <= close2;
}
function cashAllowedFor(settings, isDelivery) {
  switch (settings.cashPaymentPolicy) {
    case 'disabled': return false;
    case 'deliveryOnly': return isDelivery;
    case 'pickupOnly': return !isDelivery;
    default: return true;
  }
}
function renderTopbar() {
  $('#brandName').textContent = state.settings.restaurantName || 'Meals';
  var logo = $('#brandLogo');
  if (state.settings.logoUrl) { logo.src = state.settings.logoUrl; logo.style.display = ''; }
  else { logo.style.display = 'none'; }
  var open = isEffectivelyOpen(state.settings);
  var statusEl = $('#brandStatus');
  statusEl.textContent = open ? 'مفتوح الآن' : 'مغلق حالياً';
  statusEl.className = 'brand-status ' + (open ? 'open' : 'closed');
}

// ─── شريط الفئات + القائمة ────────────────────────────────────────────────────
function renderCatBar() {
  var bar = $('#catBar');
  bar.innerHTML = '';
  var allChip = el('button', { class: 'cat-chip' + (state.activeCategory === null ? ' active' : '') }, ['الكل']);
  allChip.addEventListener('click', function () { state.activeCategory = null; renderCatBar(); renderMenu(); });
  bar.appendChild(allChip);
  state.categories.forEach(function (cat) {
    var chip = el('button', { class: 'cat-chip' + (state.activeCategory === cat.id ? ' active' : '') },
      [cat.icon ? cat.icon + ' ' : '', cat.name]);
    chip.addEventListener('click', function () { state.activeCategory = cat.id; renderCatBar(); renderMenu(); });
    bar.appendChild(chip);
  });
}

$('#searchToggleBtn').appendChild(svgIcon('search'));
$('#searchToggleBtn').addEventListener('click', function () {
  $('#searchBar').classList.toggle('hidden');
  if (!$('#searchBar').classList.contains('hidden')) $('#searchInput').focus();
});
$('#searchInput').addEventListener('input', function (e) { state.query = e.target.value.trim().toLowerCase(); renderMenu(); });
$('#cartBtn').insertBefore(svgIcon('cart'), $('#cartBadge'));

function renderMenu() {
  var root = $('#menuRoot');
  root.innerHTML = '';
  var items = state.items.filter(function (i) {
    if (state.query) return i.name.toLowerCase().indexOf(state.query) !== -1;
    if (state.activeCategory) return i.categoryId === state.activeCategory;
    return true;
  });

  if (state.query || state.activeCategory) {
    root.appendChild(buildGrid(items));
    if (!items.length) root.appendChild(el('div', { class: 'empty-msg' }, ['لا توجد نتائج']));
    return;
  }

  // عرض "الكل": مجمّع حسب الفئة بنفس ترتيبها
  state.categories.forEach(function (cat) {
    var catItems = items.filter(function (i) { return i.categoryId === cat.id; });
    if (!catItems.length) return;
    root.appendChild(el('div', { class: 'section-title' }, [cat.name]));
    root.appendChild(buildGrid(catItems));
  });
  var uncatIds = state.categories.map(function (c) { return c.id; });
  var uncat = items.filter(function (i) { return uncatIds.indexOf(i.categoryId) === -1; });
  if (uncat.length) {
    root.appendChild(el('div', { class: 'section-title' }, ['أخرى']));
    root.appendChild(buildGrid(uncat));
  }
}

function buildGrid(items) {
  var grid = el('div', { class: 'item-grid' });
  items.forEach(function (item) { grid.appendChild(buildItemCard(item)); });
  return grid;
}

function buildItemCard(item) {
  var available = item.isAvailable !== false;
  var badges = [];
  if (item.isBestSeller) badges.push(el('span', { class: 'item-badge best' }, ['الأكثر طلباً']));
  if (item.isNew) badges.push(el('span', { class: 'item-badge new' }, ['جديد']));
  if (item.discountPercent > 0) badges.push(el('span', { class: 'item-badge off' }, ['خصم ' + item.discountPercent + '%']));

  var imgWrap = el('div', { class: 'item-img-wrap' }, [
    item.imageUrl ? el('img', { src: item.imageUrl, loading: 'lazy' }) : null,
    el('div', { class: 'item-badges' }, badges),
    !available ? el('div', { class: 'item-unavailable-overlay' }, ['نفد من المطعم']) : null,
  ]);

  var addBtn = el('button', { class: 'item-add-btn' });
  addBtn.appendChild(svgIcon('plus', 14));
  addBtn.addEventListener('click', function (e) { e.stopPropagation(); openItemSheet(item); });

  var priceRow = el('div', { class: 'item-price-row' }, [
    el('div', {}, [
      item.discountPercent > 0 ? el('span', { class: 'item-price-old' }, [item.price.toFixed(2)]) : null,
      el('span', { class: 'item-price' }, [item.finalPrice.toFixed(2) + ' ر.س']),
    ]),
    available ? addBtn : null,
  ]);

  var card = el('div', { class: 'item-card' }, [
    imgWrap,
    el('div', { class: 'item-info' }, [
      el('div', { class: 'item-name' }, [item.name]),
      item.description ? el('div', { class: 'item-desc' }, [item.description]) : null,
      priceRow,
    ]),
  ]);
  if (available) card.addEventListener('click', function () { openItemSheet(item); });
  return card;
}

// ─── ورقة تفاصيل الصنف ────────────────────────────────────────────────────────
function openItemSheet(item) {
  var qty = 1;
  var groupsState = {}; // groupId -> array of selected option ids

  function buildOptionGroup(group) {
    groupsState[group.id] = groupsState[group.id] || [];
    var rows = (group.options || []).map(function (opt) {
      var selected = groupsState[group.id].indexOf(opt.id) !== -1;
      var row = el('div', { class: 'opt-row' + (selected ? ' selected' : '') }, [
        el('div', { class: 'opt-row-label' }, [
          el('div', { class: 'opt-check' + (group.type === 'single' ? ' round' : '') }, selected ? [svgIcon('check', 11)] : []),
          opt.name,
        ]),
        opt.priceAdjustment > 0 ? el('div', { class: 'opt-row-price' }, ['+' + opt.priceAdjustment.toFixed(2)]) : null,
      ]);
      row.addEventListener('click', function () {
        if (group.type === 'single') {
          groupsState[group.id] = [opt.id];
        } else {
          var idx = groupsState[group.id].indexOf(opt.id);
          if (idx === -1) groupsState[group.id].push(opt.id);
          else groupsState[group.id].splice(idx, 1);
        }
        refreshGroup(group);
      });
      return row;
    });
    var wrap = el('div', { class: 'opt-group', 'data-group': group.id }, [
      el('div', { class: 'opt-group-head' }, [
        el('div', { class: 'opt-group-title' }, [group.name]),
        group.required ? el('div', { class: 'opt-group-req' }, ['إجباري']) : null,
      ]),
      el('div', { class: 'opt-group-hint' }, [group.type === 'single' ? 'اختر واحداً' : 'يمكن اختيار أكثر من واحد']),
      el('div', { style: 'margin-top:8px' }, rows),
    ]);
    return wrap;
  }

  function refreshGroup(group) {
    var old = sheetBody.querySelector('[data-group="' + group.id + '"]');
    var replacement = buildOptionGroup(group);
    old.replaceWith(replacement);
    updateAddBtn();
  }

  function allRequiredSatisfied() {
    return (item.optionGroups || []).every(function (g) {
      return !g.required || (groupsState[g.id] && groupsState[g.id].length > 0);
    });
  }

  function computeUnitPrice() {
    var extra = 0;
    (item.optionGroups || []).forEach(function (g) {
      (groupsState[g.id] || []).forEach(function (optId) {
        var opt = g.options.find(function (o) { return o.id === optId; });
        if (opt) extra += opt.priceAdjustment;
      });
    });
    return item.finalPrice + extra;
  }

  function updateAddBtn() {
    var ok = allRequiredSatisfied();
    addBtn.disabled = !ok;
    priceLabel.textContent = (computeUnitPrice() * qty).toFixed(2) + ' ر.س';
  }

  var qtyVal = el('span', { class: 'qty-val' }, [String(qty)]);
  var minusBtn = el('button', { class: 'qty-btn' }, ['−']);
  var plusBtn = el('button', { class: 'qty-btn' }, ['+']);
  minusBtn.addEventListener('click', function () { if (qty > 1) { qty--; qtyVal.textContent = qty; updateAddBtn(); } });
  plusBtn.addEventListener('click', function () { qty++; qtyVal.textContent = qty; updateAddBtn(); });

  var priceLabel = el('span', {}, ['']);
  var addBtn = el('button', { class: 'btn-primary' }, [svgIcon('cart', 17), el('span', {}, ['أضف للسلة  ']), priceLabel]);
  addBtn.addEventListener('click', function () {
    var selectedOptions = (item.optionGroups || [])
      .filter(function (g) { return (groupsState[g.id] || []).length; })
      .map(function (g) {
        var ids = groupsState[g.id];
        var names = ids.map(function (id) { var o = g.options.find(function (x) { return x.id === id; }); return o ? o.name : ''; });
        var extra = ids.reduce(function (s, id) { var o = g.options.find(function (x) { return x.id === id; }); return s + (o ? o.priceAdjustment : 0); }, 0);
        return { groupId: g.id, groupName: g.name, selectedIds: ids, selectedNames: names, totalExtra: extra };
      });
    addToCart(item, selectedOptions, qty);
    closeSheet();
    toast('أُضيف للسلة');
  });

  var sheetBody = el('div', { class: 'sheet-body' }, [
    el('div', { class: 'sheet-title' }, [item.name]),
    el('div', { class: 'sheet-price' }, [item.finalPrice.toFixed(2) + ' ر.س']),
    item.description ? el('div', { class: 'sheet-desc' }, [item.description]) : null,
  ].concat((item.optionGroups || []).map(buildOptionGroup)));

  var footer = el('div', { class: 'sheet-footer' }, [
    el('div', { class: 'qty-stepper' }, [minusBtn, qtyVal, plusBtn]),
    addBtn,
  ]);

  var card = el('div', { class: 'sheet-card' }, [
    el('div', { class: 'sheet-handle' }),
    el('div', { class: 'sheet-scroll' }, [
      item.imageUrl ? el('img', { class: 'sheet-img', src: item.imageUrl }) : null,
      sheetBody,
    ]),
    footer,
  ]);
  openSheet(card);
  updateAddBtn();
}

function openSheet(cardEl) {
  closeSheet();
  var backdrop = el('div', { class: 'sheet-backdrop', id: 'activeSheet' }, [cardEl]);
  backdrop.addEventListener('click', function (e) { if (e.target === backdrop) closeSheet(); });
  $('#sheetRoot').appendChild(backdrop);
}
function closeSheet() {
  var s = $('#activeSheet');
  if (s) s.remove();
}

// ─── التنقّل بين الواجهات ─────────────────────────────────────────────────────
function showView(id) {
  ['menuView', 'cartView', 'trackView'].forEach(function (v) {
    $('#' + v).classList.toggle('hidden', v !== id);
  });
  window.scrollTo(0, 0);
}
$('#cartBtn').addEventListener('click', function () { renderCart(); showView('cartView'); });
$('#cartBackBtn').appendChild(svgIcon('back'));
$('#cartBackBtn').addEventListener('click', function () { showView('menuView'); });
$('#trackBackBtn').appendChild(svgIcon('back'));
$('#trackBackBtn').addEventListener('click', function () {
  history.replaceState(null, '', location.pathname);
  showView('menuView');
});

// ─── السلة ────────────────────────────────────────────────────────────────────
function cartQtyChange(cartKey, delta) {
  var c = state.cart.find(function (x) { return x.cartKey === cartKey; });
  if (!c) return;
  c.quantity += delta;
  if (c.quantity <= 0) state.cart = state.cart.filter(function (x) { return x.cartKey !== cartKey; });
  saveCart();
  renderCartBadge();
  renderCart();
}

function renderCart() {
  var root = $('#cartRoot');
  root.innerHTML = '';

  if (!state.cart.length) {
    root.appendChild(el('div', { class: 'empty-msg' }, ['سلتك فارغة — تصفّح القائمة وأضف أصنافك المفضّلة']));
    return;
  }

  state.cart.forEach(function (c) {
    var optsText = c.selectedOptions.map(function (g) { return g.selectedNames.join('، '); }).join(' · ');
    root.appendChild(el('div', { class: 'cart-item-row' }, [
      c.imageUrl ? el('img', { class: 'cart-item-img', src: c.imageUrl }) : el('div', { class: 'cart-item-img' }),
      el('div', { class: 'cart-item-info' }, [
        el('div', { class: 'cart-item-name' }, [c.name]),
        optsText ? el('div', { class: 'cart-item-opts' }, [optsText]) : null,
        el('div', { class: 'cart-item-price' }, [(c.unitPrice * c.quantity).toFixed(2) + ' ر.س']),
      ]),
      el('div', { class: 'cart-stepper' }, [
        el('button', { class: 'cart-qty-btn', onclick: function () { cartQtyChange(c.cartKey, -1); } }, ['−']),
        el('span', { style: 'font-weight:bold;min-width:16px;text-align:center' }, [String(c.quantity)]),
        el('button', { class: 'cart-qty-btn', onclick: function () { cartQtyChange(c.cartKey, 1); } }, ['+']),
      ]),
    ]));
  });

  // نوع الطلب
  var deliveryEnabled = state.settings.deliveryEnabled !== false;
  if (!deliveryEnabled) state.orderType = 'pickup';
  var typeRow = el('div', { class: 'toggle-row' });
  if (deliveryEnabled) {
    var deliveryBtn = el('button', { class: 'toggle-pill' + (state.orderType === 'delivery' ? ' active' : '') }, ['توصيل']);
    deliveryBtn.addEventListener('click', function () { state.orderType = 'delivery'; renderCart(); });
    typeRow.appendChild(deliveryBtn);
  }
  var pickupBtn = el('button', { class: 'toggle-pill' + (state.orderType === 'pickup' ? ' active' : '') }, ['استلام من المطعم']);
  pickupBtn.addEventListener('click', function () { state.orderType = 'pickup'; renderCart(); });
  typeRow.appendChild(pickupBtn);
  root.appendChild(el('div', { class: 'section-card' }, [
    el('div', { class: 'section-card-title' }, ['نوع الطلب']),
    typeRow,
  ]));

  var isDelivery = state.orderType === 'delivery' && deliveryEnabled;

  // عنوان التوصيل
  if (isDelivery) {
    var addrInput = el('textarea', { class: 'field-input', rows: '2', placeholder: 'اكتب عنوانك بالتفصيل (الحي، الشارع، رقم المبنى...)' }, [state.deliveryAddressText]);
    addrInput.addEventListener('input', function (e) { state.deliveryAddressText = e.target.value; });
    var locateBtn = el('button', { class: 'locate-btn' }, [svgIcon('pin', 15), 'استخدام موقعي الحالي']);
    locateBtn.addEventListener('click', function () {
      if (!navigator.geolocation) { toast('المتصفح لا يدعم تحديد الموقع'); return; }
      locateBtn.textContent = 'جارٍ التحديد...';
      navigator.geolocation.getCurrentPosition(function (pos) {
        state.deliveryLat = pos.coords.latitude;
        state.deliveryLng = pos.coords.longitude;
        renderCart();
      }, function () {
        toast('تعذّر تحديد موقعك — تأكد من السماح بالوصول للموقع');
        locateBtn.innerHTML = '';
        locateBtn.appendChild(svgIcon('pin', 15));
        locateBtn.appendChild(document.createTextNode('استخدام موقعي الحالي'));
      }, { enableHighAccuracy: true, timeout: 10000 });
    });
    var locBlock = [locateBtn];
    if (state.deliveryLat != null) {
      locBlock.push(el('div', { class: 'location-ok' }, [svgIcon('check', 13), 'تم تحديد موقعك بنجاح']));
    }
    root.appendChild(el('div', { class: 'section-card' }, [
      el('div', { class: 'section-card-title' }, [svgIcon('pin', 15), 'عنوان التوصيل']),
      addrInput,
    ].concat(locBlock)));
  }

  // ملاحظات
  var notesInput = el('textarea', { class: 'field-input', rows: '2', placeholder: 'أي ملاحظات على الطلب؟ (اختياري)' }, [state.notes]);
  notesInput.addEventListener('input', function (e) { state.notes = e.target.value; });
  root.appendChild(el('div', { class: 'section-card' }, [
    el('div', { class: 'section-card-title' }, ['ملاحظات']),
    notesInput,
  ]));

  // طريقة الدفع
  var cashOk = cashAllowedFor(state.settings, isDelivery);
  var bankOk = (state.settings.bankIban || '').trim().length > 0;
  if (!cashOk && state.paymentMethod === 'cash' && bankOk) state.paymentMethod = 'manualBankTransfer';

  var payRows = [];
  if (cashOk) {
    var cashRow = el('div', { class: 'pay-option' + (state.paymentMethod === 'cash' ? ' selected' : '') }, [
      el('div', { class: 'pay-radio' }, [el('div', { class: 'pay-radio-dot' })]),
      el('div', { class: 'pay-label' }, ['نقداً عند الاستلام']),
    ]);
    cashRow.addEventListener('click', function () { state.paymentMethod = 'cash'; renderCart(); });
    payRows.push(cashRow);
  }
  if (bankOk) {
    var bankRow = el('div', { class: 'pay-option' + (state.paymentMethod === 'manualBankTransfer' ? ' selected' : '') }, [
      el('div', { class: 'pay-radio' }, [el('div', { class: 'pay-radio-dot' })]),
      el('div', { class: 'pay-label' }, ['تحويل بنكي']),
    ]);
    bankRow.addEventListener('click', function () { state.paymentMethod = 'manualBankTransfer'; renderCart(); });
    payRows.push(bankRow);
  }
  var payBlock = [el('div', { class: 'section-card-title' }, ['طريقة الدفع'])].concat(payRows);

  if (state.paymentMethod === 'manualBankTransfer' && bankOk) {
    var bankCard = el('div', { class: 'bank-card' }, [
      state.settings.bankAccountHolderName ? el('div', { class: 'bank-card-row' }, [el('span', {}, ['صاحب الحساب']), el('span', {}, [state.settings.bankAccountHolderName])]) : null,
      state.settings.bankName ? el('div', { class: 'bank-card-row' }, [el('span', {}, ['البنك']), el('span', {}, [state.settings.bankName])]) : null,
      el('div', { class: 'bank-iban' }, [state.settings.bankIban]),
    ]);
    var copyBtn = el('button', { class: 'bank-copy-btn', style: 'display:block;margin:0 auto' }, ['نسخ رقم الآيبان']);
    copyBtn.addEventListener('click', function () {
      copyToClipboard(state.settings.bankIban);
      toast('تم نسخ رقم الآيبان');
    });
    bankCard.appendChild(copyBtn);
    payBlock.push(bankCard);

    var fileInput = el('input', { type: 'file', accept: 'image/*,.pdf', style: 'display:none' });
    var uploadStatus = el('div', { style: 'font-size:11.5px;color:var(--text-hint);margin-top:8px' },
      [state.receiptUrl ? 'تم إرفاق الإيصال ✓' : 'يمكنك إرفاق إيصال التحويل الآن أو لاحقاً من صفحة تتبع الطلب']);
    var uploadBtn = el('button', { class: 'locate-btn' }, [svgIcon('upload', 15), state.receiptUrl ? 'تغيير الإيصال' : 'إرفاق إيصال التحويل']);
    uploadBtn.addEventListener('click', function () { fileInput.click(); });
    fileInput.addEventListener('change', function () {
      var file = fileInput.files[0];
      if (!file) return;
      uploadBtn.textContent = 'جارٍ الرفع...';
      uploadReceiptImage(file).then(function (url) {
        state.receiptUrl = url;
        toast('تم رفع الإيصال بنجاح');
        renderCart();
      }).catch(function (e) {
        toast('فشل رفع الإيصال: ' + e.message);
        renderCart();
      });
    });
    payBlock.push(uploadBtn, uploadStatus, fileInput);
  }
  root.appendChild(el('div', { class: 'section-card' }, payBlock));

  // الملخّص المالي
  var subtotal = cartTotal();
  var deliveryFee = 0;
  var outsideServiceArea = false;
  var pricingPending = false;
  if (isDelivery) {
    var r = resolveDeliveryFee();
    deliveryFee = r.fee;
    outsideServiceArea = r.outsideServiceArea;
    pricingPending = r.pending;
  }
  var total = subtotal + deliveryFee;

  var summaryRows = [
    el('div', { class: 'summary-row' }, [el('span', {}, ['المجموع الفرعي']), el('span', {}, [subtotal.toFixed(2)])]),
  ];
  if (isDelivery && !pricingPending && !outsideServiceArea) {
    summaryRows.push(el('div', { class: 'summary-row' }, [el('span', {}, ['رسوم التوصيل']), el('span', {}, [deliveryFee.toFixed(2)])]));
  }
  summaryRows.push(el('div', { class: 'summary-row total' }, [el('span', {}, ['الإجمالي']), el('span', {}, [(pricingPending ? subtotal : total).toFixed(2) + ' ر.س'])]));
  root.appendChild(el('div', { class: 'section-card' }, summaryRows));

  // زر إرسال الطلب
  var minOrder = state.settings.minOrderAmount || 0;
  var belowMin = subtotal < minOrder;
  var placeBtn = el('button', { class: 'btn-primary', style: 'width:100%' }, [
    belowMin ? 'الحد الأدنى للطلب ' + minOrder.toFixed(0) + ' ر.س' : 'إرسال الطلب — ' + (pricingPending ? subtotal : total).toFixed(2) + ' ر.س',
  ]);
  placeBtn.disabled = belowMin || !isEffectivelyOpen(state.settings) || (isDelivery && outsideServiceArea);
  placeBtn.addEventListener('click', placeOrder);
  root.appendChild(el('div', { class: 'cart-footer' }, [
    !isEffectivelyOpen(state.settings) ? el('div', { style: 'text-align:center;color:var(--error);font-size:12px;font-weight:bold;margin-bottom:8px' }, ['المطعم مغلق حالياً']) :
      (outsideServiceArea ? el('div', { style: 'text-align:center;color:var(--error);font-size:12px;font-weight:bold;margin-bottom:8px' }, ['عذراً، موقعك خارج نطاق التوصيل']) : null),
    placeBtn,
  ]));
}

function copyToClipboard(text) {
  if (navigator.clipboard && navigator.clipboard.writeText) { navigator.clipboard.writeText(text); return; }
  var ta = document.createElement('textarea');
  ta.value = text; ta.style.position = 'fixed'; ta.style.opacity = '0';
  document.body.appendChild(ta); ta.select();
  try { document.execCommand('copy'); } catch (e) {}
  document.body.removeChild(ta);
}

// ─── مناطق التوصيل (نفس منطق المسافة المباشرة بين نقطتين) ─────────────────────
function haversineKm(lat1, lng1, lat2, lng2) {
  var R = 6371;
  var dLat = (lat2 - lat1) * Math.PI / 180;
  var dLng = (lng2 - lng1) * Math.PI / 180;
  var a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) *
    Math.sin(dLng / 2) * Math.sin(dLng / 2);
  return R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
}
var deliveryZonesCache = [];
db.collection('deliveryZones').onSnapshot(function (snap) {
  deliveryZonesCache = snap.docs.map(function (d) { return Object.assign({ id: d.id }, d.data()); })
    .sort(function (a, b) { return a.maxDistanceKm - b.maxDistanceKm; });
});
function resolveDeliveryFee() {
  var s = state.settings;
  if (!s.useDeliveryZones || s.restaurantLat == null || s.restaurantLng == null || !deliveryZonesCache.length) {
    return { fee: s.deliveryFee || 0, outsideServiceArea: false, pending: false };
  }
  if (state.deliveryLat == null || state.deliveryLng == null) {
    return { fee: s.deliveryFee || 0, outsideServiceArea: false, pending: true };
  }
  var dist = haversineKm(s.restaurantLat, s.restaurantLng, state.deliveryLat, state.deliveryLng);
  var zone = deliveryZonesCache.find(function (z) { return dist <= z.maxDistanceKm; });
  if (!zone) return { fee: 0, outsideServiceArea: true, pending: false };
  return { fee: zone.fee, outsideServiceArea: false, pending: false, zoneId: zone.id, zoneName: zone.name };
}

// ─── رفع صورة الإيصال (Cloudinary، غير موقَّع) ─────────────────────────────────
function uploadReceiptImage(file) {
  var formData = new FormData();
  formData.append('upload_preset', 'melz_upload');
  formData.append('folder', 'melz_restaurant');
  formData.append('file', file);
  return fetch('https://api.cloudinary.com/v1_1/dwbzohzt9/image/upload', { method: 'POST', body: formData })
    .then(function (res) { return res.json().then(function (json) { return { res: res, json: json }; }); })
    .then(function (r) {
      if (!r.res.ok) throw new Error((r.json.error && r.json.error.message) || 'HTTP ' + r.res.status);
      return r.json.secure_url;
    });
}

// ─── تسجيل ضيف (بلا كلمة مرور) ────────────────────────────────────────────────
function showGuestSheet() {
  return new Promise(function (resolve) {
    var nameInput = el('input', { class: 'field-input', placeholder: 'الاسم' });
    var phoneInput = el('input', { class: 'field-input', type: 'tel', placeholder: '05XXXXXXXX', style: 'direction:ltr;text-align:center' });
    var errorMsg = el('div', { style: 'color:var(--error);font-size:11.5px;margin-top:6px;display:none' });
    var submitBtn = el('button', { class: 'btn-primary', style: 'width:100%;margin-top:16px' }, ['متابعة الطلب']);
    submitBtn.addEventListener('click', function () {
      var name = nameInput.value.trim();
      var digits = phoneInput.value.replace(/\D/g, '');
      if (!name) { errorMsg.textContent = 'أدخل اسمك'; errorMsg.style.display = 'block'; return; }
      if (digits.length < 9) { errorMsg.textContent = 'رقم جوال غير صحيح'; errorMsg.style.display = 'block'; return; }
      closeSheet();
      resolve({ name: name, phone: phoneInput.value.trim() });
    });
    var card = el('div', { class: 'sheet-card' }, [
      el('div', { class: 'sheet-handle' }),
      el('div', { class: 'sheet-body' }, [
        el('div', { class: 'sheet-title' }, ['بيانات التواصل']),
        el('div', { style: 'font-size:12.5px;color:var(--text-secondary);margin-top:4px' }, ['نحتاج اسمك ورقم جوالك فقط لإتمام الطلب والتواصل معك']),
        el('div', { style: 'margin-top:16px' }, [nameInput]),
        el('div', { style: 'margin-top:10px' }, [phoneInput]),
        errorMsg,
        submitBtn,
      ]),
    ]);
    var backdrop = el('div', { class: 'sheet-backdrop', id: 'activeSheet' }, [card]);
    backdrop.addEventListener('click', function (e) { if (e.target === backdrop) { closeSheet(); resolve(null); } });
    $('#sheetRoot').appendChild(backdrop);
  });
}

function ensureGuestUser() {
  if (auth.currentUser) {
    return db.collection('users').doc(auth.currentUser.uid).get().then(function (doc) {
      if (doc.exists && doc.data().phone) {
        return { id: auth.currentUser.uid, name: doc.data().name, phone: doc.data().phone };
      }
      return promptAndCreateGuest();
    });
  }
  return promptAndCreateGuest();
}
function promptAndCreateGuest() {
  return showGuestSheet().then(function (info) {
    if (!info) return null;
    return auth.signInAnonymously().then(function (cred) {
      var uid = cred.user.uid;
      var userDoc = { id: uid, phone: info.phone, name: info.name, role: 'customer', createdAt: firebase.firestore.Timestamp.now() };
      return db.collection('users').doc(uid).set(userDoc, { merge: true }).then(function () { return userDoc; });
    });
  });
}

// ─── رقم طلب عشوائي 4 خانات بلا تكرار (نفس آلية بقية التطبيق) ─────────────────
function nextOrderNumber() {
  var poolRef = db.collection('counters').doc('orderNumberPool');
  return db.runTransaction(function (tx) {
    return tx.get(poolRef).then(function (snap) {
      var sequence, index;
      if (snap.exists) {
        sequence = snap.data().sequence.slice();
        index = snap.data().index;
      } else {
        sequence = []; index = 0;
      }
      if (index >= sequence.length) {
        sequence = [];
        for (var i = 0; i < 9000; i++) sequence.push(1000 + i);
        for (var j = sequence.length - 1; j > 0; j--) {
          var k = Math.floor(Math.random() * (j + 1));
          var tmp = sequence[j]; sequence[j] = sequence[k]; sequence[k] = tmp;
        }
        index = 0;
      }
      var number = sequence[index];
      tx.set(poolRef, { sequence: sequence, index: index + 1 });
      return number;
    });
  });
}

// ─── إرسال الطلب ───────────────────────────────────────────────────────────────
function placeOrder() {
  if (!state.cart.length) return;
  ensureGuestUser().then(function (user) {
    if (!user) return; // أغلق نافذة البيانات بدون متابعة

    var isDelivery = state.orderType === 'delivery' && state.settings.deliveryEnabled !== false;
    var pricing = isDelivery ? resolveDeliveryFee() : { fee: 0, outsideServiceArea: false };
    var deliveryFee = isDelivery ? pricing.fee : 0;
    var subtotal = cartTotal();
    var total = subtotal + deliveryFee;

    var items = state.cart.map(function (c) {
      return {
        menuItemId: c.itemId, name: c.name, price: c.unitPrice, quantity: c.quantity, imageUrl: c.imageUrl,
        selectedOptions: c.selectedOptions.map(function (g) {
          return { groupName: g.groupName, selectedNames: g.selectedNames, extra: g.totalExtra };
        }),
      };
    });

    nextOrderNumber().then(function (orderNumber) {
      var ref = db.collection('orders').doc();
      var now = firebase.firestore.Timestamp.now();
      var order = {
        orderNumber: orderNumber,
        customerId: user.id, customerName: user.name, customerPhone: user.phone,
        items: items, subtotal: subtotal, deliveryFee: deliveryFee, total: total,
        status: 'pending', notes: state.notes.trim() || null,
        createdAt: now, updatedAt: now,
        estimatedTime: null, kitchenNotes: null, estimatedMinutes: null, estimatedSetAt: null,
        orderType: isDelivery ? 'delivery' : 'pickup',
        deliveryLat: isDelivery ? state.deliveryLat : null,
        deliveryLng: isDelivery ? state.deliveryLng : null,
        deliveryAddress: isDelivery ? (state.deliveryAddressText.trim() || null) : null,
        deliveryZoneId: isDelivery ? (pricing.zoneId || null) : null,
        deliveryZoneName: isDelivery ? (pricing.zoneName || null) : null,
        driverId: null, driverName: null, driverPhone: null, assignedAt: null, driverAcceptedAt: null, pickedUpAt: null,
        driverLat: null, driverLng: null, driverLocationUpdatedAt: null,
        paymentMethod: state.paymentMethod, paymentStatus: 'pending',
        leanPaymentIntentId: null, paymentReceiptUrl: state.receiptUrl,
      };
      return ref.set(order).then(function () { return ref.id; });
    }).then(function (orderId) {
      state.cart = [];
      state.notes = ''; state.receiptUrl = null;
      saveCart();
      renderCartBadge();
      showOrderConfirmation(orderId);
    }).catch(function (e) {
      toast('فشل إرسال الطلب: ' + e.message);
    });
  });
}

function showOrderConfirmation(orderId) {
  var phone = state.settings.restaurantPhone;
  var card = el('div', { class: 'confirm-card' }, [
    el('div', { class: 'confirm-icon' }, [svgIcon('phone', 24)]),
    el('div', { class: 'confirm-title' }, ['تم استلام طلبك!']),
    el('div', { class: 'confirm-text' }, ['سيتصل بك المطعم خلال دقائق لتأكيد الطلب.']),
    phone ? el('div', {}, [
      el('div', { style: 'font-size:11.5px;color:var(--text-hint);margin-top:10px' }, ['الاتصال سيصلك من هذا الرقم:']),
      el('div', { class: 'confirm-phone' }, [phone]),
    ]) : null,
    el('button', { class: 'btn-primary', style: 'width:100%;margin-top:18px' }, ['حسناً، تتبّع طلبي']),
  ]);
  card.querySelector('.btn-primary').addEventListener('click', function () {
    closeConfirm();
    openTrack(orderId);
  });
  var backdrop = el('div', { class: 'confirm-backdrop', id: 'activeConfirm' }, [card]);
  $('#confirmRoot').appendChild(backdrop);
}
function closeConfirm() {
  var c = $('#activeConfirm');
  if (c) c.remove();
}

// ─── تتبّع الطلب ───────────────────────────────────────────────────────────────
var STATUS_STEPS = [
  { key: 'pending', label: 'بانتظار التأكيد' },
  { key: 'confirmed', label: 'تم التأكيد' },
  { key: 'preparing', label: 'قيد التحضير' },
  { key: 'ready', label: 'جاهز' },
  { key: 'delivered', label: 'تم التسليم' },
];
var trackUnsub = null;
function openTrack(orderId) {
  history.replaceState(null, '', '#/track/' + orderId);
  showView('trackView');
  if (trackUnsub) trackUnsub();
  $('#trackRoot').innerHTML = '<div class="empty-msg">جارٍ التحميل...</div>';
  trackUnsub = db.collection('orders').doc(orderId).onSnapshot(function (snap) {
    if (!snap.exists) { $('#trackRoot').innerHTML = ''; $('#trackRoot').appendChild(el('div', { class: 'empty-msg' }, ['لم يعد هذا الطلب موجوداً'])); return; }
    renderTrack(Object.assign({ id: snap.id }, snap.data()));
  }, function () {
    $('#trackRoot').innerHTML = '';
    $('#trackRoot').appendChild(el('div', { class: 'empty-msg' }, ['ما تقدر تشوف هذا الطلب من هذا الجهاز']));
  });
}
function renderTrack(order) {
  var root = $('#trackRoot');
  root.innerHTML = '';
  var isCancelled = order.status === 'cancelled';
  var currentIdx = STATUS_STEPS.findIndex(function (s) { return s.key === order.status; });

  root.appendChild(el('div', { class: 'section-card' }, [
    el('div', { style: 'display:flex;justify-content:space-between;align-items:center' }, [
      el('div', { style: 'font-weight:bold;font-size:15px' }, ['طلب #' + String(order.orderNumber || 0).padStart(4, '0')]),
      el('button', { class: 'bank-copy-btn', style: 'background:var(--purple-soft);color:var(--purple)', onclick: function () { window.location.href = 'tel:' + state.settings.restaurantPhone; } }, ['اتصل بالمطعم']),
    ]),
  ]));

  if (isCancelled) {
    root.appendChild(el('div', { class: 'section-card' }, [
      el('div', { style: 'color:var(--error);font-weight:bold;text-align:center;padding:10px 0' }, ['تم إلغاء هذا الطلب']),
    ]));
  } else {
    var steps = STATUS_STEPS.map(function (s, i) {
      var done = i < currentIdx, current = i === currentIdx;
      return el('div', { class: 'track-step' }, [
        el('div', {}, [
          el('div', { class: 'track-dot' + (done ? ' done' : current ? ' current' : '') }, [done ? svgIcon('check', 13) : String(i + 1)]),
          i < STATUS_STEPS.length - 1 ? el('div', { class: 'track-line', style: 'height:26px;margin-right:13px' }) : null,
        ]),
        el('div', { class: 'track-label' + (done || current ? ' active' : ''), style: 'padding-top:4px' }, [s.label]),
      ]);
    });
    root.appendChild(el('div', { class: 'section-card' }, steps));
  }

  if (order.estimatedMinutes) {
    root.appendChild(el('div', { class: 'section-card' }, [
      el('div', { class: 'section-card-title' }, ['الوقت المتوقع']), el('div', {}, [order.estimatedMinutes + ' دقيقة تقريباً']),
    ]));
  }

  var itemsRows = (order.items || []).map(function (item) {
    var opts = (item.selectedOptions || []).map(function (o) { return o.selectedNames.join('، '); }).join(' · ');
    return el('div', { class: 'cart-item-row', style: 'margin:0 0 8px' }, [
      el('div', { class: 'cart-item-info' }, [
        el('div', { class: 'cart-item-name' }, ['×' + item.quantity + '  ' + item.name]),
        opts ? el('div', { class: 'cart-item-opts' }, [opts]) : null,
      ]),
      el('div', { class: 'cart-item-price' }, [(item.price * item.quantity).toFixed(2)]),
    ]);
  });
  root.appendChild(el('div', { class: 'section-card' }, [el('div', { class: 'section-card-title' }, ['الأصناف'])].concat(itemsRows).concat([
    el('div', { class: 'summary-row total' }, [el('span', {}, ['الإجمالي']), el('span', {}, [order.total.toFixed(2) + ' ر.س'])]),
  ])));

  if (order.status === 'pending' && !isCancelled) {
    var cancelBtn = el('button', { class: 'btn-ghost', style: 'width:100%;color:var(--error);border-color:rgba(244,67,54,.3)' }, ['إلغاء الطلب']);
    cancelBtn.addEventListener('click', function () {
      openConfirmDialog('إلغاء الطلب', 'هل تريد إلغاء طلبك؟ لا يمكن التراجع عن هذا.', 'إلغاء الطلب', function () {
        db.collection('orders').doc(order.id).update({ status: 'cancelled', updatedAt: firebase.firestore.Timestamp.now() });
      });
    });
    root.appendChild(el('div', { style: 'padding:0 14px' }, [cancelBtn]));
  }
}
function openConfirmDialog(title, text, confirmLabel, onConfirm) {
  var card = el('div', { class: 'confirm-card' }, [
    el('div', { class: 'confirm-title' }, [title]),
    el('div', { class: 'confirm-text' }, [text]),
    el('div', { style: 'display:flex;gap:10px;margin-top:18px' }, [
      el('button', { class: 'btn-ghost', style: 'flex:1', onclick: closeConfirm }, ['تراجع']),
      el('button', { class: 'btn-primary', style: 'flex:1;background:var(--error)', onclick: function () { closeConfirm(); onConfirm(); } }, [confirmLabel]),
    ]),
  ]);
  var backdrop = el('div', { class: 'confirm-backdrop', id: 'activeConfirm' }, [card]);
  $('#confirmRoot').appendChild(backdrop);
}

// ─── بدء التشغيل ───────────────────────────────────────────────────────────────
loadCart();
renderCartBadge();
var hashMatch = location.hash.match(/^#\/track\/(.+)$/);
if (hashMatch) {
  // يجب انتظار استعادة جلسة فايربيس (قد تكون جلسة ضيف محفوظة من زيارة سابقة)
  // قبل محاولة قراءة الطلب — قراءته قبل اكتمال الاستعادة تُرفض من قواعد الأمان
  onceAuthReady(function () { openTrack(hashMatch[1]); });
}
