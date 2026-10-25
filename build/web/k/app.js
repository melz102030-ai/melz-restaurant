'use strict';

if ('serviceWorker' in navigator) {
  navigator.serviceWorker.register('sw.js').catch(function () {});
}

// ─── إعداد فايربيس (نفس بيانات تطبيق Meals الرئيسي) ─────────────────────────
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

// ─── حالة عامة ───────────────────────────────────────────────────────────────
var state = {
  orders: [],
  settings: { restaurantName: 'Meals', estimatedPrepTime: 30 },
  isOffline: false,
  knownPendingIds: null, // null = لم يُحمَّل بعد (لا تنبيه عند أول تحميل)
  alarmPlaying: false,
  expandedCards: {},     // orderId -> bool
  deliveredExpanded: false,
  unsubOrders: null,
  unsubSettings: null,
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
function pad4(n) { return String(n).padStart(4, '0'); }

// ─── حالة الفتح/الإغلاق (مطابقة لمنطق RestaurantSettings.effectivelyOpen
// في lib/core/models/settings_model.dart — نفس القواعد بالضبط بما فيها
// الفترات الليلية الممتدة لما بعد منتصف الليل) ─────────────────────────────
var DAY_KEYS = ['sun', 'mon', 'tue', 'wed', 'thu', 'fri', 'sat']; // يطابق Date.getDay()
function parseHHMM(hhmm, date) {
  if (!hhmm) return null;
  var parts = String(hhmm).split(':');
  if (parts.length !== 2) return null;
  var h = parseInt(parts[0], 10), m = parseInt(parts[1], 10);
  if (isNaN(h) || isNaN(m)) return null;
  var d = new Date(date.getFullYear(), date.getMonth(), date.getDate(), h, m);
  return d;
}
function fmtHHMM(hhmm) {
  var parts = String(hhmm || '').split(':');
  if (parts.length !== 2) return hhmm || '';
  var h = parseInt(parts[0], 10) || 0, m = parseInt(parts[1], 10) || 0;
  var isPm = h >= 12;
  var h12 = h === 0 ? 12 : (h > 12 ? h - 12 : h);
  return h12 + ':' + String(m).padStart(2, '0') + ' ' + (isPm ? 'م' : 'ص');
}
function hasDetailedHours(s) { return s.workingHours && Object.keys(s.workingHours).length > 0; }
function dayShifts(s, date) { return (s.workingHours && s.workingHours[DAY_KEYS[date.getDay()]]) || []; }
function effectivelyOpen(s) {
  if (s.isOpen === false || s.allowOrders === false) return false;
  var now = new Date();
  if (hasDetailedHours(s)) {
    var shifts = dayShifts(s, now);
    if (!shifts.length) return false;
    for (var i = 0; i < shifts.length; i++) {
      var open = parseHHMM(shifts[i].open, now), close = parseHHMM(shifts[i].close, now);
      if (!open || !close) continue;
      if (close <= open) { if (now > open || now < close) return true; }
      else if (now > open && now < close) return true;
    }
    return false;
  }
  if (!s.openTime || !s.closeTime) return true;
  var open2 = parseHHMM(s.openTime, now), close2 = parseHHMM(s.closeTime, now);
  if (!open2 || !close2) return true;
  if (close2 <= open2) return now > open2 || now < close2;
  return now > open2 && now < close2;
}
function currentOpenShift(s) {
  if (!hasDetailedHours(s)) return null;
  var now = new Date();
  var today = dayShifts(s, now);
  for (var i = 0; i < today.length; i++) {
    var open = parseHHMM(today[i].open, now), close = parseHHMM(today[i].close, now);
    if (!open || !close) continue;
    if (close <= open) { if (now > open) return today[i]; }
    else if (now > open && now < close) return today[i];
  }
  var yesterday = new Date(now.getTime() - 24 * 60 * 60 * 1000);
  var yShifts = dayShifts(s, yesterday);
  for (var j = 0; j < yShifts.length; j++) {
    var yOpen = parseHHMM(yShifts[j].open, yesterday), yClose = parseHHMM(yShifts[j].close, yesterday);
    if (!yOpen || !yClose) continue;
    if (yClose <= yOpen) {
      var closeToday = new Date(now.getFullYear(), now.getMonth(), now.getDate(), yClose.getHours(), yClose.getMinutes());
      if (now < closeToday) return yShifts[j];
    }
  }
  return null;
}
function nextOpeningShift(s) {
  if (!hasDetailedHours(s)) return null;
  var now = new Date();
  for (var dayOffset = 0; dayOffset < 8; dayOffset++) {
    var day = new Date(now.getTime() + dayOffset * 24 * 60 * 60 * 1000);
    var shifts = dayShifts(s, day);
    var best = null, bestOpen = null;
    for (var i = 0; i < shifts.length; i++) {
      var open = parseHHMM(shifts[i].open, day);
      if (!open) continue;
      if (dayOffset === 0 && open <= now) continue;
      if (!bestOpen || open < bestOpen) { bestOpen = open; best = shifts[i]; }
    }
    if (best) return best;
  }
  return null;
}
function scheduleLabel(s) {
  var openLabel, closeLabel;
  if (hasDetailedHours(s)) {
    var next = nextOpeningShift(s);
    openLabel = next ? fmtHHMM(next.open) : fmtHHMM(s.openTime);
    var cur = currentOpenShift(s);
    closeLabel = cur ? fmtHHMM(cur.close) : fmtHHMM(s.closeTime);
  } else {
    openLabel = fmtHHMM(s.openTime);
    closeLabel = fmtHHMM(s.closeTime);
  }
  return openLabel + ' - ' + closeLabel;
}
function renderOpenStatus() {
  var elStatus = $('#openStatus');
  if (!elStatus) return;
  var s = state.settings;
  var open = effectivelyOpen(s);
  elStatus.textContent = (open ? 'مفتوح الآن' : 'مغلق الآن') + ' · ' + scheduleLabel(s);
  elStatus.className = 'open-status ' + (open ? 'open' : 'closed');
}
// أيقونة خطّية أحادية اللون (currentColor) بدل الإيموجي الملوّن — الإيموجي
// يحمل ألوانه الثابتة الخاصة (مثلاً 📞 وردي/أخضر) فيكسر أي نظام ألوان مهما
// كانت الخلفية، وهذا كان سبب رئيسي في مظهر "العفاشة" اللي اشتكى منه المستخدم
var ICONS = {
  phone: 'M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72c.127.96.361 1.903.7 2.81a2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45c.907.339 1.85.573 2.81.7A2 2 0 0 1 22 16.92z',
  x: 'M18 6 6 18M6 6l12 12',
  copy: 'M9 9h11v11H9zM5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1',
};
function svgIcon(name, size) {
  size = size || 15;
  var svg = document.createElementNS('http://www.w3.org/2000/svg', 'svg');
  svg.setAttribute('width', size);
  svg.setAttribute('height', size);
  svg.setAttribute('viewBox', '0 0 24 24');
  svg.setAttribute('fill', 'none');
  svg.setAttribute('stroke', 'currentColor');
  svg.setAttribute('stroke-width', '2');
  svg.setAttribute('stroke-linecap', 'round');
  svg.setAttribute('stroke-linejoin', 'round');
  var path = document.createElementNS('http://www.w3.org/2000/svg', 'path');
  path.setAttribute('d', ICONS[name] || '');
  svg.appendChild(path);
  return svg;
}
function toast(msg) {
  var t = el('div', { class: 'toast' }, [msg]);
  $('#toastRoot').appendChild(t);
  setTimeout(function () { t.remove(); }, 3000);
}

// ─── تسجيل الدخول ────────────────────────────────────────────────────────────
$('#loginForm').addEventListener('submit', function (e) {
  e.preventDefault();
  var phone = $('#phoneInput').value.trim();
  var password = $('#passwordInput').value.trim();
  var btn = $('#loginBtn');
  var errBox = $('#loginError');
  errBox.style.display = 'none';
  btn.disabled = true;
  btn.textContent = 'جارٍ الدخول...';

  auth.signInWithEmailAndPassword(phone + '@meals.local', password)
    .then(function (cred) {
      return db.collection('users').doc(cred.user.uid).get();
    })
    .then(function (doc) {
      if (!doc.exists || doc.data().role !== 'kitchen') {
        auth.signOut();
        throw new Error('هذا الحساب غير مخوَّل للدخول لشاشة المطبخ');
      }
      // نجاح — onAuthStateChanged سيتولى عرض الواجهة
    })
    .catch(function (err) {
      errBox.textContent = authErrorMessage(err);
      errBox.style.display = 'block';
    })
    .finally(function () {
      btn.disabled = false;
      btn.textContent = 'دخول';
    });
});

function authErrorMessage(err) {
  var code = err && err.code;
  switch (code) {
    case 'auth/user-not-found':
    case 'auth/invalid-credential':
    case 'auth/wrong-password':
      return 'رقم الجوال أو كلمة المرور غير صحيحة';
    case 'auth/too-many-requests':
      return 'طلبات كثيرة، حاول لاحقاً';
    case 'auth/network-request-failed':
      return 'تحقق من اتصال الإنترنت';
    default:
      return err && err.message ? err.message : 'خطأ غير متوقع';
  }
}

$('#logoutBtn').addEventListener('click', function () {
  stopAlarm();
  auth.signOut();
});

// ─── مراقبة حالة الدخول ──────────────────────────────────────────────────────
auth.onAuthStateChanged(function (user) {
  if (!user) {
    teardownListeners();
    $('#loginView').style.display = 'flex';
    $('#appView').style.display = 'none';
    $('#availView').style.display = 'none';
    return;
  }
  db.collection('users').doc(user.uid).get().then(function (doc) {
    if (!doc.exists || doc.data().role !== 'kitchen') {
      auth.signOut();
      return;
    }
    $('#loginView').style.display = 'none';
    $('#appView').style.display = 'block';
    primeAudio();
    setupListeners();
  });
});

// ─── إعداد/إيقاف مستمعي Firestore ────────────────────────────────────────────
function setupListeners() {
  if (state.unsubSettings) return; // مُفعَّل مسبقاً
  state.unsubSettings = db.doc('settings/restaurant').onSnapshot(function (snap) {
    if (snap.exists) state.settings = Object.assign({ restaurantName: 'Meals', estimatedPrepTime: 30 }, snap.data());
    renderOpenStatus();
  });

  state.unsubOrders = db.collection('orders')
    .where('status', 'in', ['pending', 'confirmed', 'preparing', 'ready', 'outForDelivery', 'delivered'])
    .onSnapshot({ includeMetadataChanges: true }, function (snap) {
      state.isOffline = snap.metadata.fromCache;
      var cutoff = Date.now() - 4 * 60 * 60 * 1000;
      var orders = snap.docs.map(function (d) { return orderFromDoc(d); });
      orders = orders.filter(function (o) {
        return o.status !== 'delivered' || o.updatedAt.getTime() > cutoff;
      });
      orders.sort(function (a, b) { return a.createdAt - b.createdAt; });
      state.orders = orders;

      // كشف الطلبات الجديدة (pending) وتشغيل المنبه
      var pendingIds = {};
      orders.forEach(function (o) { if (o.status === 'pending') pendingIds[o.id] = true; });
      if (state.knownPendingIds !== null) {
        var isNew = false;
        for (var id in pendingIds) { if (!state.knownPendingIds[id]) { isNew = true; break; } }
        if (isNew) playAlarm();
      }
      state.knownPendingIds = pendingIds;

      render();
    }, function (err) {
      console.warn('orders listener error', err);
    });
}

function teardownListeners() {
  if (state.unsubOrders) { state.unsubOrders(); state.unsubOrders = null; }
  if (state.unsubSettings) { state.unsubSettings(); state.unsubSettings = null; }
  state.orders = [];
  state.knownPendingIds = null;
}

function tsToDate(ts) { return ts && ts.toDate ? ts.toDate() : new Date(); }

function orderFromDoc(doc) {
  var m = doc.data();
  return {
    id: doc.id,
    orderNumber: m.orderNumber || 0,
    customerName: m.customerName || '',
    customerPhone: m.customerPhone || '',
    items: m.items || [],
    subtotal: m.subtotal || 0,
    deliveryFee: m.deliveryFee || 0,
    total: m.total || 0,
    status: m.status || 'pending',
    notes: m.notes || null,
    createdAt: tsToDate(m.createdAt),
    updatedAt: tsToDate(m.updatedAt),
    estimatedMinutes: m.estimatedMinutes || null,
    estimatedSetAt: m.estimatedSetAt ? tsToDate(m.estimatedSetAt) : null,
    kitchenNotes: m.kitchenNotes || null,
    orderType: m.orderType || 'delivery',
    paymentMethod: m.paymentMethod || 'cash',
    deliveryAddress: m.deliveryAddress || null,
    driverId: m.driverId || null,
    driverName: m.driverName || null,
    driverPhone: m.driverPhone || null,
    driverAcceptedAt: m.driverAcceptedAt ? tsToDate(m.driverAcceptedAt) : null,
  };
}

// ─── الصوت: منبه الطلب الجديد (نفس منطق التطبيق الرئيسي) ─────────────────────
var kCtx = null, kScheduled = [];
function getCtx() {
  if (!kCtx) kCtx = new (window.AudioContext || window.webkitAudioContext)();
  return kCtx;
}
function primeAudio() {
  try {
    var ctx = getCtx();
    if (ctx.state === 'suspended') ctx.resume().catch(function () {});
  } catch (e) {}
}
function playAlarm() {
  try {
    var ctx = getCtx();
    function scheduleTones() {
      function tone(freq, startSec, durationSec, vol) {
        var osc = ctx.createOscillator();
        var gain = ctx.createGain();
        osc.connect(gain);
        gain.connect(ctx.destination);
        osc.type = 'square';
        osc.frequency.setValueAtTime(freq, ctx.currentTime + startSec);
        gain.gain.setValueAtTime(vol, ctx.currentTime + startSec);
        gain.gain.setValueAtTime(vol, ctx.currentTime + startSec + durationSec - 0.02);
        gain.gain.linearRampToValueAtTime(0, ctx.currentTime + startSec + durationSec);
        osc.start(ctx.currentTime + startSec);
        osc.stop(ctx.currentTime + startSec + durationSec + 0.01);
        kScheduled.push(osc);
      }
      var REPS = 40;
      for (var i = 0; i < REPS; i++) {
        var t = i * 0.5;
        tone(1400, t, 0.25, 1.0);
        tone(750, t + 0.25, 0.23, 1.0);
      }
    }
    if (ctx.state === 'suspended') ctx.resume().then(scheduleTones);
    else scheduleTones();
  } catch (e) { console.warn('alarm error', e); }
  state.alarmPlaying = true;
  $('#stopAlarmBtn').classList.remove('hidden');
  $('#alarmBanner').classList.remove('hidden');
  setTimeout(stopAlarm, 22000);
}
function stopAlarm() {
  kScheduled.forEach(function (o) { try { o.stop(); } catch (e) {} });
  kScheduled = [];
  if (kCtx) try { kCtx.suspend(); } catch (e) {}
  state.alarmPlaying = false;
  $('#stopAlarmBtn').classList.add('hidden');
  $('#alarmBanner').classList.add('hidden');
}
$('#stopAlarmBtn').addEventListener('click', stopAlarm);
$('#alarmBanner').addEventListener('click', stopAlarm);
document.addEventListener('pointerdown', primeAudio);

// ─── تسميات/ألوان الحالة ─────────────────────────────────────────────────────
var STATUS_LABEL = {
  pending: 'قيد الانتظار', confirmed: 'تم التأكيد', preparing: 'قيد التحضير',
  ready: 'جاهز', outForDelivery: 'في الطريق إليك', delivered: 'تم التسليم', cancelled: 'ملغى',
};
var PAYMENT_LABEL = {
  cash: 'نقداً عند الاستلام', card: 'بطاقة بنكية', applePay: 'Apple Pay', mada: 'مدى',
  leanBankTransfer: 'دفع مباشر من حسابك البنكي', manualBankTransfer: 'تحويل بنكي',
};
var STATUS_COLOR = {
  pending: 'var(--st-pending)', confirmed: 'var(--st-confirmed)', preparing: 'var(--st-preparing)',
  ready: 'var(--st-ready)', outForDelivery: 'var(--st-delivery)', delivered: 'var(--st-delivered)', cancelled: 'var(--error)',
};

// ─── العرض الرئيسي ───────────────────────────────────────────────────────────
function render() {
  var total = state.orders.length;
  $('#activeCount').textContent = 'مجموع النشط: ' + total + ' طلب';
  $('#offlineBanner').classList.toggle('hidden', !state.isOffline);

  var groups = {
    pending: [], inProgress: [], ready: [], outForDelivery: [], delivered: [],
  };
  state.orders.forEach(function (o) {
    if (o.status === 'pending') groups.pending.push(o);
    else if (o.status === 'confirmed' || o.status === 'preparing') groups.inProgress.push(o);
    else if (o.status === 'ready') groups.ready.push(o);
    else if (o.status === 'outForDelivery') groups.outForDelivery.push(o);
    else if (o.status === 'delivered') groups.delivered.push(o);
  });

  var root = $('#ordersRoot');
  root.innerHTML = '';
  root.appendChild(buildSection('طلبات جديدة', groups.pending, 'var(--st-pending)', 'لا توجد طلبات جديدة'));
  root.appendChild(buildSection('قيد التنفيذ', groups.inProgress, 'var(--st-preparing)', 'لا توجد طلبات قيد التنفيذ'));
  root.appendChild(buildSection('جاهزة', groups.ready, 'var(--st-ready)', 'لا توجد طلبات جاهزة'));
  root.appendChild(buildSection('التوصيل', groups.outForDelivery, 'var(--st-delivery)', 'لا توجد طلبات في الطريق حالياً'));
  root.appendChild(buildSection('مُسلَّمة', groups.delivered, 'var(--st-delivered)', 'لا توجد طلبات مُسلَّمة خلال آخر 4 ساعات', true));
}

function buildSection(label, orders, color, emptyMsg, collapsible) {
  var wrap = el('div', { class: 'section' });
  var expanded = collapsible ? state.deliveredExpanded : true;
  var head = el('div', { class: 'section-head' }, [
    el('div', { class: 'dot', style: 'background:' + color }),
    el('h2', {}, [label]),
    orders.length ? el('span', { class: 'count-pill' }, [String(orders.length)]) : null,
    collapsible ? el('span', { class: 'chev' }, [expanded ? '▲' : '▼']) : null,
  ]);
  if (collapsible) {
    head.addEventListener('click', function () {
      state.deliveredExpanded = !state.deliveredExpanded;
      render();
    });
  }
  wrap.appendChild(head);
  if (expanded) {
    if (!orders.length) {
      wrap.appendChild(el('div', { class: 'empty-msg' }, [emptyMsg]));
    } else {
      orders.forEach(function (o, i) { wrap.appendChild(buildOrderCard(o, i)); });
    }
  }
  return wrap;
}

function openUnavailableItemsModal(order) {
  var selected = {};
  var uniqueItems = [];
  var seen = {};
  order.items.forEach(function (item) {
    if (!seen[item.menuItemId]) {
      seen[item.menuItemId] = true;
      uniqueItems.push(item);
    }
  });

  var checkboxRows = uniqueItems.map(function (item) {
    var cb = el('input', { type: 'checkbox', style: 'width:18px;height:18px;cursor:pointer;accent-color:var(--error)' });
    cb.addEventListener('change', function () {
      selected[item.menuItemId] = cb.checked ? item.name : null;
    });
    return el('label', { style: 'display:flex;align-items:center;gap:10px;padding:10px 0;cursor:pointer;font-size:14px;border-bottom:1px solid var(--border)' }, [cb, item.name]);
  });

  var body = el('div', { class: 'modal-body' }, [
    el('p', { style: 'font-size:13px;color:var(--text-secondary);margin-bottom:8px' }, ['اختر الأصناف غير المتوفرة في هذا الطلب:']),
    el('div', { style: 'max-height:260px;overflow-y:auto' }, checkboxRows),
    el('p', { style: 'font-size:11.5px;color:var(--text-hint);margin-top:10px' }, ['• سيُوقَف توفر الصنف في القائمة\n• يُبلَّغ العميل ليختار بديلاً بدل إلغاء طلبه كاملاً']),
  ]);

  var actions = el('div', { class: 'modal-actions' }, [
    el('button', { class: 'btn-ghost', onclick: closeModal }, ['تراجع']),
    el('button', {
      style: 'background:var(--error);color:#fff;border:none;padding:10px 18px;border-radius:10px;font-size:14px;cursor:pointer',
      onclick: function () {
        var ids = Object.keys(selected).filter(function (k) { return !!selected[k]; });
        if (!ids.length) { toast('اختر صنفاً واحداً على الأقل'); return; }
        closeModal();
        var batch = db.batch();
        ids.forEach(function (menuItemId) {
          batch.update(db.collection('menu_items').doc(menuItemId), { isAvailable: false });
        });
        batch.update(db.collection('orders').doc(order.id), {
          unavailableItemIds: ids,
          updatedAt: firebase.firestore.Timestamp.now(),
        });
        batch.commit()
          .then(function () { toast('تم إبلاغ العميل وإيقاف الأصناف'); })
          .catch(function (e) { toast('خطأ: ' + e.message); });
      },
    }, ['تأكيد وإبلاغ العميل']),
  ]);

  openModal('أصناف غير متوفرة', body, [actions]);
}

function buildOrderCard(order, index) {
  var isTerminal = order.status === 'delivered' || order.status === 'cancelled';
  var elapsedMin = Math.floor((Date.now() - order.createdAt.getTime()) / 60000);
  var isUrgent = elapsedMin > 15 && !isTerminal;
  var color = STATUS_COLOR[order.status] || 'var(--text-hint)';

  var card = el('div', { class: 'order-card' + (isUrgent ? ' urgent' : ''), 'data-id': order.id });
  card.style.animationDelay = (index * 40) + 'ms';
  card.style.setProperty('--card-accent', color);
  card.style.setProperty('--card-accent-soft', color + '1f');

  // Header — لون الحالة يظهر فقط على حافة البطاقة + رقم الطلب، الباقي محايد
  var badges = [
    el('span', { class: 'badge' }, [order.orderType === 'delivery' ? 'توصيل' : 'استلام من المطعم']),
  ];
  if (order.status === 'confirmed' || order.status === 'preparing') {
    badges.push(el('span', { class: 'badge accent' }, [STATUS_LABEL[order.status]]));
  }

  var callBtn = el('button', { class: 'call-btn', title: 'اتصل بالعميل' });
  callBtn.appendChild(svgIcon('phone'));
  callBtn.addEventListener('click', function () { window.location.href = 'tel:' + order.customerPhone; });

  var side = el('div', { class: 'order-side' }, [
    callBtn,
    el('div', {
      class: 'pill elapsed-pill' + (isUrgent ? ' loud' : ''), 'data-created': order.createdAt.getTime(),
    }, [elapsedMin + ' د']),
  ]);
  if (order.estimatedMinutes != null && order.estimatedSetAt && !isTerminal) {
    side.appendChild(countdownPill(order));
  }

  var head = el('div', { class: 'order-head' }, [
    el('div', { class: 'order-id' }, ['#' + pad4(order.orderNumber)]),
    el('div', { class: 'order-info' }, [
      el('div', { class: 'order-name' }, [order.customerName]),
      el('div', {
        class: 'order-phone', onclick: function () { window.location.href = 'tel:' + order.customerPhone; },
      }, [order.customerPhone]),
      el('div', { class: 'badges' }, badges),
    ]),
    side,
  ]);
  card.appendChild(head);

  // Items
  var itemsWrap = el('div', { class: 'order-items' });
  order.items.forEach(function (item) {
    var optLines = (item.selectedOptions || [])
      .filter(function (o) { return (o.selectedNames || []).length; })
      .map(function (o) {
        var extra = (o.extra || 0) > 0 ? ' (+' + o.extra.toFixed(2) + ')' : '';
        return o.groupName + ': ' + (o.selectedNames || []).join('، ') + extra;
      });
    itemsWrap.appendChild(el('div', { class: 'order-item-row' }, [
      el('div', { class: 'qty-box' }, ['×' + item.quantity]),
      el('div', {}, [
        el('div', { class: 'item-name' }, [item.name]),
      ].concat(optLines.map(function (line) { return el('div', { class: 'item-opts' }, [line]); }))),
    ]));
  });
  card.appendChild(itemsWrap);

  if (order.notes) {
    card.appendChild(el('div', { class: 'order-notes' }, [order.notes]));
  }

  // Driver panel (delivery only, not terminal)
  if (order.orderType === 'delivery' && !isTerminal) {
    card.appendChild(buildDriverPanel(order));
  }

  // Expand (time/notes inputs)
  var expanded = !!state.expandedCards[order.id];
  var timeInput = el('input', { type: 'number', inputmode: 'numeric', placeholder: 'مثال: 20', value: order.estimatedMinutes || '' });
  var notesInput = el('textarea', { rows: '2', placeholder: 'مثال: تأخير بسيط...' }, [order.kitchenNotes || '']);
  var expandWrap = el('div', { class: 'order-expand' + (expanded ? ' open' : '') }, [
    el('label', { style: 'font-size:11.5px;color:var(--text-secondary);font-weight:600' }, ['وقت التحضير (دقائق)']),
    timeInput,
    el('label', { style: 'font-size:11.5px;color:var(--text-secondary);font-weight:600' }, ['ملاحظة للعميل']),
    notesInput,
  ]);
  card.appendChild(expandWrap);

  // Actions — زر أساسي واحد فقط (الخطوة التالية) بلون بنفسجي موحّد؛ الباقي
  // أزرار محايدة (ghost) ما عدا الإلغاء (نص أحمر بلا تعبئة)
  var actionsRow = el('div', { class: 'action-btns' });
  actionsRow.appendChild(actionBtn('طباعة', 'ghost', function () { printOrder(order); }));

  if (!isTerminal) {
    var unavailBtn = actionBtn('غير متوفر', 'ghost', function () {
      openUnavailableItemsModal(order);
    });
    unavailBtn.style.color = 'var(--error)';
    actionsRow.appendChild(unavailBtn);
  }

  function doUpdate(newStatus, btnEl, minutesOverride) {
    btnEl.classList.add('loading');
    var mins = minutesOverride != null ? minutesOverride : parseInt(timeInput.value, 10);
    if (isNaN(mins)) mins = order.estimatedMinutes == null ? (state.settings.estimatedPrepTime || 30) : null;
    var update = { status: newStatus, updatedAt: firebase.firestore.Timestamp.now() };
    var notesVal = notesInput.value.trim();
    if (notesVal) update.kitchenNotes = notesVal;
    if (mins != null) {
      update.estimatedMinutes = mins;
      update.estimatedTime = mins + ' دقيقة';
      // لا نُعيد ضبط estimatedSetAt إلا إذا تغير الوقت فعلاً أو لم يُضبط قط
      // — بخلاف ذلك يعيد المؤقت الحساب من الصفر عند كل انتقال حالة
      if (mins !== order.estimatedMinutes || order.estimatedSetAt == null) {
        update.estimatedSetAt = firebase.firestore.Timestamp.now();
      }
    }
    db.collection('orders').doc(order.id).update(update)
      .then(function () {
        if (newStatus === 'confirmed') printOrder(order);
      })
      .catch(function (e) { toast('خطأ: ' + e.message); })
      .finally(function () { btnEl.classList.remove('loading'); });
  }

  if (order.status === 'pending') {
    actionsRow.appendChild(actionBtn('تأكيد', 'primary', function (btnEl) {
      openWaitTimeModal(function (minutes) {
        if (order.driverId && !order.driverAcceptedAt) {
          openConfirmModal(
            'المندوب لم يوافق بعد',
            'المندوب "' + order.driverName + '" لم يوافق بعد على استلام هذا الطلب. يمكنك تأكيد الطلب الآن على أي حال، أو الانتظار حتى يوافق.',
            'تأكيد الآن', function () { doUpdate('confirmed', btnEl, minutes); }
          );
        } else {
          doUpdate('confirmed', btnEl, minutes);
        }
      });
    }));
  }
  if (order.status === 'confirmed') {
    actionsRow.appendChild(actionBtn('بدء التحضير', 'primary', function (btnEl) { doUpdate('preparing', btnEl); }));
  }
  if (order.status === 'preparing') {
    actionsRow.appendChild(actionBtn('جاهز', 'primary', function (btnEl) { doUpdate('ready', btnEl); }));
  }
  if (order.status === 'ready' && order.orderType === 'pickup') {
    actionsRow.appendChild(actionBtn('تم التسليم', 'primary', function (btnEl) { doUpdate('delivered', btnEl); }));
  }
  if (order.status === 'outForDelivery') {
    actionsRow.appendChild(actionBtn('تم التسليم', 'primary', function (btnEl) { doUpdate('delivered', btnEl); }));
  }
  if (order.status !== 'ready' && order.status !== 'outForDelivery' && !isTerminal) {
    actionsRow.appendChild(actionBtn('إلغاء', 'danger', function (btnEl) {
      openConfirmModal('إلغاء الطلب', 'هل تريد إلغاء طلب "' + order.customerName + '"؟ لا يمكن التراجع عن هذا.',
        'إلغاء الطلب', function () { doUpdate('cancelled', btnEl); }, true);
    }));
  }

  var actionsWrap = el('div', { class: 'order-actions' }, [
    el('button', {
      class: 'text-btn',
      onclick: function () {
        state.expandedCards[order.id] = !expanded;
        render();
      },
    }, [expanded ? 'إخفاء' : 'تفاصيل']),
    actionsRow,
  ]);
  card.appendChild(actionsWrap);

  return card;
}

function actionBtn(label, variant, onclick) {
  var btn = el('button', { class: 'action-btn ' + variant }, [label]);
  btn.addEventListener('click', function () { onclick(btn); });
  return btn;
}

function countdownPill(order) {
  var endTime = order.estimatedSetAt.getTime() + order.estimatedMinutes * 60000;
  var remainingMs = endTime - Date.now();
  var isLate = remainingMs < 0;
  var absMs = Math.abs(remainingMs);
  var mm = Math.floor(absMs / 60000);
  var ss = Math.floor((absMs % 60000) / 1000);
  var txt = (isLate ? '-' : '') + mm + ':' + (ss < 10 ? '0' : '') + ss;
  var isNear = !isLate && mm < 3;
  var cls = isLate ? 'loud' : isNear ? 'warn' : 'ok';
  return el('div', { class: 'pill countdown-pill ' + cls, 'data-end': endTime }, [txt]);
}

// نظام مناديب واتساب: لا تعيين/تتبع داخل الصفحة إطلاقاً — زر نسخ بيانات
// الطلب فقط ليُرسله الموظف يدوياً لمندوب خارج التطبيق
function buildDriverCopyText(order) {
  var lines = ['طلب توصيل جديد'];
  lines.push('العميل: ' + order.customerName);
  lines.push('الجوال: ' + order.customerPhone);
  if (order.deliveryAddress) lines.push('العنوان: ' + order.deliveryAddress);
  lines.push('طريقة الدفع: ' + (PAYMENT_LABEL[order.paymentMethod] || order.paymentMethod));
  lines.push('---');
  order.items.forEach(function (item) {
    lines.push('×' + item.quantity + ' ' + item.name);
    var opts = (item.selectedOptions || []).filter(function (o) { return (o.selectedNames || []).length; })
      .map(function (o) {
        var extra = (o.extra || 0) > 0 ? ' (+' + o.extra.toFixed(2) + ')' : '';
        return o.groupName + ': ' + o.selectedNames.join('، ') + extra;
      }).join(' | ');
    if (opts) lines.push('   ' + opts);
  });
  lines.push('---');
  lines.push('الإجمالي: ' + order.total.toFixed(2) + ' ر.س');
  if (order.notes) lines.push('ملاحظات: ' + order.notes);
  return lines.join('\n');
}

function copyToClipboard(text) {
  if (navigator.clipboard && navigator.clipboard.writeText) {
    return navigator.clipboard.writeText(text);
  }
  // دعم المتصفحات القديمة (مثل WebView أندرويد 7 القديم) بلا Clipboard API
  var ta = document.createElement('textarea');
  ta.value = text;
  ta.style.position = 'fixed';
  ta.style.opacity = '0';
  document.body.appendChild(ta);
  ta.focus();
  ta.select();
  try { document.execCommand('copy'); } catch (e) {}
  document.body.removeChild(ta);
  return Promise.resolve();
}

function buildDriverPanel(order) {
  var wrap = el('div', { class: 'driver-panel' });
  if (state.settings.driverSystemMode === 'whatsapp') {
    var copyBtn = el('button', { class: 'driver-assign-btn' }, ['نسخ بيانات الطلب']);
    copyBtn.addEventListener('click', function () {
      copyToClipboard(buildDriverCopyText(order)).then(function () {
        toast('تم نسخ بيانات الطلب — الصقها لمندوب واتساب');
      });
    });
    wrap.appendChild(copyBtn);
    wrap.appendChild(el('div', { style: 'clear:both' }));
    return wrap;
  }
  if (!order.driverId) {
    var btn = el('button', { class: 'driver-assign-btn' }, ['تعيين مندوب']);
    btn.addEventListener('click', function () { openAssignDriverModal(order); });
    wrap.appendChild(btn);
    wrap.appendChild(el('div', { style: 'clear:both' }));
    return wrap;
  }
  var accepted = !!order.driverAcceptedAt;
  var color = accepted ? 'var(--success)' : 'var(--warning)';
  var canUnassign = order.status !== 'outForDelivery';
  var row = el('div', { class: 'driver-status', style: 'background:' + color + '1a;color:' + color + ';border:1px solid ' + color + '55' }, [
    el('span', {}, [accepted ? '✓' : '⏳']),
    el('span', { style: 'flex:1' }, [accepted ? 'المندوب ' + order.driverName + ' وافق' : 'بانتظار موافقة المندوب: ' + order.driverName]),
  ]);
  if (canUnassign) {
    var closeBtn = el('button', { style: 'border:none;background:transparent;color:var(--error);cursor:pointer;font-size:14px' }, ['✕']);
    closeBtn.addEventListener('click', function () {
      db.collection('orders').doc(order.id).update({
        driverId: null, driverName: null, driverPhone: null, assignedAt: null, driverAcceptedAt: null,
        updatedAt: firebase.firestore.Timestamp.now(),
      }).catch(function (e) { toast('خطأ: ' + e.message); });
    });
    row.appendChild(closeBtn);
  }
  wrap.appendChild(row);
  return wrap;
}

// ─── مودال: تعيين مندوب ──────────────────────────────────────────────────────
function openAssignDriverModal(order) {
  var activeCounts = {};
  state.orders.forEach(function (o) {
    if (o.driverId && o.status !== 'delivered' && o.status !== 'cancelled') {
      activeCounts[o.driverId] = (activeCounts[o.driverId] || 0) + 1;
    }
  });

  var body = el('div', { class: 'modal-body' }, [el('div', { class: 'empty-msg' }, ['جارٍ التحميل...'])]);
  var modal = openModal('تعيين مندوب للطلب', body, []);

  db.collection('users').where('role', '==', 'driver').get().then(function (snap) {
    var drivers = snap.docs.map(function (d) { return Object.assign({ id: d.id }, d.data()); });
    if (!drivers.length) {
      body.innerHTML = '';
      body.appendChild(el('div', { class: 'empty-msg', style: 'padding:24px 0;text-align:center' }, ['لا يوجد مناديب مسجّلين بعد — أضفهم من لوحة الإدارة']));
      return;
    }
    drivers.sort(function (a, b) { return (activeCounts[a.id] || 0) - (activeCounts[b.id] || 0); });
    body.innerHTML = '';
    drivers.forEach(function (d) {
      var count = activeCounts[d.id] || 0;
      var isBusy = count > 0;
      var statusColor = d.isAvailable === false ? 'var(--text-hint)' : isBusy ? 'var(--warning)' : 'var(--success)';
      var statusText = d.isAvailable === false ? 'غير متصل' : isBusy ? 'مشغول — ' + count + ' طلب حالي' : 'متاح الآن';
      var row = el('div', { class: 'driver-row' }, [
        el('div', { class: 'driver-avatar' }, ['🛵']),
        el('div', { style: 'flex:1' }, [
          el('div', { class: 'driver-row-name' }, [d.name || '']),
          el('div', { class: 'driver-row-status', style: 'color:' + statusColor }, [statusText]),
        ]),
      ]);
      row.addEventListener('click', function () {
        db.collection('orders').doc(order.id).update({
          driverId: d.id, driverName: d.name || '', driverPhone: d.phone || null,
          assignedAt: firebase.firestore.Timestamp.now(), driverAcceptedAt: null,
          updatedAt: firebase.firestore.Timestamp.now(),
        }).then(closeModal).catch(function (e) { toast('خطأ: ' + e.message); });
      });
      body.appendChild(row);
    });
  });
}

// ─── مودال تأكيد عام ──────────────────────────────────────────────────────────
function openConfirmModal(title, text, confirmLabel, onConfirm, danger) {
  var body = el('div', { class: 'modal-body' }, [el('div', { class: 'confirm-text' }, [text])]);
  var actions = el('div', { class: 'modal-actions' }, [
    el('button', { class: 'btn-ghost', onclick: closeModal }, ['تراجع']),
    el('button', { class: danger ? 'btn-danger' : 'btn-ghost', style: danger ? '' : 'background:var(--purple);color:#fff', onclick: function () { closeModal(); onConfirm(); } }, [confirmLabel]),
  ]);
  openModal(title, body, [actions]);
}

// ─── مودال وقت الانتظار الإجباري عند تأكيد الطلب ──────────────────────────────
var WAIT_TIME_OPTIONS = [10, 15, 20, 25, 30, 40];
function openWaitTimeModal(onPick) {
  var body = el('div', { class: 'modal-body' }, [
    el('div', { class: 'confirm-text', style: 'padding-bottom:4px' }, ['حدّد وقت تجهيز الطلب المتوقع قبل التأكيد:']),
    el('div', { style: 'display:flex;flex-wrap:wrap;gap:8px;padding:6px 4px 10px' },
      WAIT_TIME_OPTIONS.map(function (mins) {
        var btn = el('button', {
          style: 'flex:1;min-width:70px;padding:14px 8px;border-radius:10px;border:1.5px solid var(--purple);' +
            'background:transparent;color:var(--purple);font-weight:bold;font-size:14px;cursor:pointer',
        }, [mins + ' د']);
        btn.addEventListener('click', function () {
          closeModal();
          onPick(mins);
        });
        return btn;
      })),
  ]);
  var actions = el('div', { class: 'modal-actions' }, [
    el('button', { class: 'btn-ghost', onclick: closeModal }, ['تراجع']),
  ]);
  openModal('وقت الانتظار المتوقع', body, [actions]);
}

function openModal(title, bodyEl, extra) {
  closeModal();
  var backdrop = el('div', { class: 'modal-backdrop', id: 'activeModal' });
  var card = el('div', { class: 'modal-card' }, [
    el('div', { class: 'modal-head' }, [title]),
    bodyEl,
  ].concat(extra || []));
  backdrop.appendChild(card);
  backdrop.addEventListener('click', function (e) { if (e.target === backdrop) closeModal(); });
  $('#modalRoot').appendChild(backdrop);
  return backdrop;
}
function closeModal() {
  var m = $('#activeModal');
  if (m) m.remove();
}

// ─── الطباعة ──────────────────────────────────────────────────────────────────
// نسخة نصية بسيطة بلا HTML — تُرسَل لتطبيق الجسر المرافق المثبَّت على جهاز
// Sunmi (sunmi_print_bridge/) عبر رابط sunmiprint://، لأن طابعة Sunmi
// الداخلية غير مرئية لنافذة طباعة أندرويد القياسية (window.print)
function buildReceiptPlainText(order) {
  var df = new Intl.DateTimeFormat('ar', { hour: '2-digit', minute: '2-digit', day: '2-digit', month: '2-digit', year: 'numeric' });
  // أقصر من قبل (كان 32) — لأن الطباعة عبر تطبيق الجسر تستخدم خطاً أكبر
  // بالبولد، فيتّسع عدد أحرف أقل بكل سطر قبل أن يلتف تلقائياً بشكل عشوائي
  var sep = '--------------------';
  var lines = [];
  lines.push(state.settings.restaurantName);
  lines.push('طلب رقم ' + pad4(order.orderNumber));
  lines.push(df.format(order.createdAt));
  lines.push(sep);
  lines.push('العميل: ' + order.customerName);
  lines.push('الجوال: ' + order.customerPhone);
  lines.push('النوع: ' + (order.orderType === 'delivery' ? 'توصيل' : 'استلام من المطعم'));
  if (order.orderType === 'delivery' && order.deliveryAddress) lines.push('العنوان: ' + order.deliveryAddress);
  lines.push(sep);
  order.items.forEach(function (item) {
    // جرَّبنا printColumnsText (عمودين بسطر واحد) مرتين وبعرضين مختلفين —
    // في الحالتين اختفى اسم الصنف بالكامل من الطباعة الفعلية (يبدو أن
    // الدالة لا تحسب عرض النص العربي بشكل صحيح على هذه الطابعة). رجعنا
    // لسطرين منفصلين لأنها الطريقة الوحيدة المؤكَّد عملها فعلياً
    lines.push('×' + item.quantity + ' ' + item.name);
    lines.push((item.price * item.quantity).toFixed(2) + ' ر.س');
    // كل قيمة مختارة بسطر مستقل (لا نجمعها بفاصلة) — كانت تُطبَع كتلة
    // نصية واحدة طويلة تلتف على عدة أسطر فتبدو متلاصقة بلا فواصل واضحة
    (item.selectedOptions || []).filter(function (o) { return (o.selectedNames || []).length; })
      .forEach(function (o) {
        var extra = (o.extra || 0) > 0 ? ' (+' + o.extra.toFixed(2) + ')' : '';
        lines.push(o.groupName + ':' + extra);
        o.selectedNames.forEach(function (name) { lines.push('- ' + name); });
      });
  });
  lines.push(sep);
  lines.push('الإجمالي الفرعي: ' + order.subtotal.toFixed(2));
  if (order.deliveryFee > 0) lines.push('التوصيل: ' + order.deliveryFee.toFixed(2));
  lines.push('الإجمالي: ' + order.total.toFixed(2));
  if (order.notes) { lines.push(sep); lines.push('ملاحظات: ' + order.notes); }
  lines.push(sep);
  lines.push('شكراً لطلبك من ' + state.settings.restaurantName);
  return lines.join('\n');
}

// تُرسَل عبر fetch عادي لخادم محلي صغير (127.0.0.1:9898) يديره تطبيق
// الجسر (راجع sunmi_print_bridge/PrintBridgeService.kt) — بلا أي تنقّل أو
// فتح تطبيق آخر، فلا يغادر كروم المقدّمة إطلاقاً ولا تُعاد صفحة المطبخ من
// جديد بعد الطباعة (كانت هذه المشكلة الجذرية مع كل الطرق السابقة التي
// تعتمد على فتح تطبيق منفصل عبر رابط sunmiprint://)
function printViaSunmiBridge(order) {
  try {
    var text = buildReceiptPlainText(order);
    fetch('http://127.0.0.1:9898/print', { method: 'POST', body: text }).catch(function (e) {
      console.warn('Sunmi bridge print failed', e);
    });
    return true;
  } catch (e) {
    console.warn('Sunmi bridge print failed', e);
    return false;
  }
}

// هذه الصفحة مخصَّصة لأجهزة Sunmi التي عليها تطبيق الجسر دائماً (راجع
// sunmi_print_bridge/) — تستدعيه مباشرة بلا أي خطة بديلة تلقائية.
function printOrder(order) {
  printViaSunmiBridge(order);
}

// ─── إدارة توفر الأصناف ───────────────────────────────────────────────────────
var availData = { categories: [], items: [] };
$('#availBtn').addEventListener('click', openAvailability);
$('#availBackBtn').addEventListener('click', function () {
  $('#availView').style.display = 'none';
  $('#appView').style.display = 'block';
});
$('#availSearch').addEventListener('input', renderAvailability);

function openAvailability() {
  $('#appView').style.display = 'none';
  $('#availView').style.display = 'block';
  $('#availRoot').innerHTML = '<div class="empty-msg" style="padding:16px">جاري تحميل الأصناف...</div>';

  Promise.all([
    db.collection('categories').orderBy('sortOrder').get(),
    db.collection('menu_items').orderBy('sortOrder').get(),
  ]).then(function (res) {
    availData.categories = res[0].docs.map(function (d) { return Object.assign({ id: d.id }, d.data()); });
    availData.items = res[1].docs.map(function (d) { return Object.assign({ id: d.id }, d.data()); });
    renderAvailability();
  }).catch(function (e) {
    $('#availRoot').innerHTML = '';
    $('#availRoot').appendChild(el('div', { class: 'empty-msg', style: 'padding:16px' }, ['خطأ: ' + e.message]));
  });
}

function renderAvailability() {
  var q = $('#availSearch').value.trim().toLowerCase();
  var items = q ? availData.items.filter(function (i) { return (i.name || '').toLowerCase().indexOf(q) !== -1; }) : availData.items;

  var root = $('#availRoot');
  root.innerHTML = '';
  var sections = [];
  availData.categories.forEach(function (cat) {
    var catItems = items.filter(function (i) { return i.categoryId === cat.id; });
    if (catItems.length) sections.push({ title: cat.name, items: catItems });
  });
  var catIds = availData.categories.map(function (c) { return c.id; });
  var uncat = items.filter(function (i) { return catIds.indexOf(i.categoryId) === -1; });
  if (uncat.length) sections.push({ title: 'أخرى', items: uncat });

  if (!sections.length) {
    root.appendChild(el('div', { class: 'empty-msg', style: 'padding:16px' }, [q ? 'لا توجد نتائج بحث' : 'لا توجد أصناف']));
    return;
  }

  sections.forEach(function (sec) {
    root.appendChild(el('div', { class: 'avail-cat' }, [el('div', { class: 'bar' }), sec.title + ' (' + sec.items.length + ')']));
    sec.items.forEach(function (item) { root.appendChild(buildAvailItem(item)); });
  });
}

var availExpanded = {}; // itemId -> bool (هل لوحة خيارات الصنف مفتوحة)

function buildAvailItem(item) {
  var available = item.isAvailable !== false;
  var iconEl = item.imageUrl
    ? el('img', { class: 'avail-icon', src: item.imageUrl, style: available ? '' : 'filter:grayscale(1)' })
    : el('div', { class: 'avail-icon' }, ['🍽️']);

  var toggle = el('input', { type: 'checkbox' });
  toggle.checked = available;
  var switchWrap = el('label', {
    class: 'switch',
    onclick: function (e) { e.stopPropagation(); },
  }, [toggle, el('span', { class: 'slider' })]);

  toggle.addEventListener('change', function () {
    var val = toggle.checked;
    toggle.disabled = true;
    db.collection('menu_items').doc(item.id).update({ isAvailable: val })
      .then(function () {
        item.isAvailable = val;
        renderAvailability();
      })
      .catch(function (e) {
        toggle.checked = !val;
        toast('خطأ: ' + e.message);
      })
      .finally(function () { toggle.disabled = false; });
  });

  var hasOptions = (item.optionGroups || []).some(function (g) { return (g.options || []).length; });
  var isOpen = !!availExpanded[item.id];

  var row = el('div', {
    class: 'avail-item' + (available ? '' : ' off'),
    onclick: function () { availExpanded[item.id] = !availExpanded[item.id]; renderAvailability(); },
  }, [
    iconEl,
    el('div', { class: 'avail-info' }, [
      el('div', { class: 'avail-name' }, [item.name]),
      el('div', { class: 'avail-price' }, [(item.price || 0).toFixed(2) + ' ر.س']),
    ]),
    switchWrap,
    hasOptions ? el('span', { class: 'avail-expand-arrow' + (isOpen ? ' open' : '') }, ['▾']) : null,
  ]);

  var wrap = el('div', {}, [row]);
  if (isOpen) {
    wrap.appendChild(hasOptions ? buildAvailOptions(item) : el('div', { class: 'avail-options' }, [
      el('div', { class: 'avail-no-opts' }, ['لا توجد خيارات لهذا الصنف']),
    ]));
  }
  return wrap;
}

// لوحة خيارات الصنف — كل مجموعة وخياراتها مع مفتاح تفعيل/إيقاف لكل خيار
// على حِدة (مثال: إيقاف "جبنة إضافية" مؤقتاً لنفادها دون إيقاف الصنف كله)
function buildAvailOptions(item) {
  var panel = el('div', { class: 'avail-options' });
  (item.optionGroups || []).forEach(function (group) {
    if (!(group.options || []).length) return;
    var rows = group.options.map(function (opt) {
      var optAvailable = opt.isAvailable !== false;
      var optToggle = el('input', { type: 'checkbox' });
      optToggle.checked = optAvailable;
      var optSwitch = el('label', { class: 'switch small' }, [optToggle, el('span', { class: 'slider' })]);

      optToggle.addEventListener('change', function () {
        var val = optToggle.checked;
        optToggle.disabled = true;
        var updatedGroups = (item.optionGroups || []).map(function (g) {
          if (g.id !== group.id) return g;
          return Object.assign({}, g, {
            options: g.options.map(function (o) {
              return o.id === opt.id ? Object.assign({}, o, { isAvailable: val }) : o;
            }),
          });
        });
        db.collection('menu_items').doc(item.id).update({ optionGroups: updatedGroups })
          .then(function () {
            item.optionGroups = updatedGroups;
            opt.isAvailable = val;
            renderAvailability();
          })
          .catch(function (e) {
            optToggle.checked = !val;
            toast('خطأ: ' + e.message);
          })
          .finally(function () { optToggle.disabled = false; });
      });

      return el('div', { class: 'avail-opt-row' + (optAvailable ? '' : ' off') }, [
        el('span', { class: 'avail-opt-name' }, [opt.name]),
        optSwitch,
      ]);
    });
    panel.appendChild(el('div', { class: 'avail-opt-group' }, [
      el('div', { class: 'avail-opt-group-title' }, [group.name]),
    ].concat(rows)));
  });
  return panel;
}

// ─── تحديث العدّادات كل ثانية (المنقضي + الوقت المتبقي) بدون إعادة رسم كاملة ──
// (تحديث موضعي فقط لنصوص العدّادات — إعادة رسم الصفحة كاملة كل ثانية كانت
// تمسح ما يكتبه الطباخ في حقول "تفاصيل" المفتوحة وتفقد تركيز لوحة المفاتيح)
setInterval(function () {
  if ($('#appView').style.display !== 'block') return;
  document.querySelectorAll('.elapsed-pill').forEach(function (p) {
    var created = parseInt(p.getAttribute('data-created'), 10);
    var mins = Math.floor((Date.now() - created) / 60000);
    p.textContent = mins + ' د';
    p.classList.toggle('loud', mins > 15);
  });
  document.querySelectorAll('.countdown-pill').forEach(function (p) {
    var end = parseInt(p.getAttribute('data-end'), 10);
    var remainingMs = end - Date.now();
    var isLate = remainingMs < 0;
    var absMs = Math.abs(remainingMs);
    var mm = Math.floor(absMs / 60000);
    var ss = Math.floor((absMs % 60000) / 1000);
    p.textContent = (isLate ? '-' : '') + mm + ':' + (ss < 10 ? '0' : '') + ss;
    p.classList.remove('loud', 'warn', 'ok');
    p.classList.add(isLate ? 'loud' : (!isLate && mm < 3) ? 'warn' : 'ok');
  });
}, 1000);
