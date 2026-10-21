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
function esc(s) {
  return String(s == null ? '' : s).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
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

function buildOrderCard(order, index) {
  var isTerminal = order.status === 'delivered' || order.status === 'cancelled';
  var elapsedMin = Math.floor((Date.now() - order.createdAt.getTime()) / 60000);
  var isUrgent = elapsedMin > 15 && !isTerminal;
  var color = STATUS_COLOR[order.status] || 'var(--text-hint)';

  var card = el('div', { class: 'order-card' + (isUrgent ? ' urgent' : ''), 'data-id': order.id });
  card.style.animationDelay = (index * 40) + 'ms';

  // Header
  var badges = [
    el('span', { class: 'badge', style: 'background:' + (order.orderType === 'delivery' ? 'rgba(106,13,173,.12);color:var(--purple)' : 'rgba(128,0,64,.12);color:#800040') },
      [order.orderType === 'delivery' ? 'توصيل' : 'استلام من المطعم']),
  ];
  if (order.status === 'confirmed' || order.status === 'preparing') {
    badges.push(el('span', { class: 'badge', style: 'background:' + color + '26;color:' + color }, [STATUS_LABEL[order.status]]));
  }

  var side = el('div', { class: 'order-side' }, [
    el('button', {
      class: 'call-btn', title: 'اتصل بالعميل',
      onclick: function () { window.location.href = 'tel:' + order.customerPhone; },
    }, ['📞']),
    el('div', {
      class: 'pill elapsed-pill', 'data-created': order.createdAt.getTime(),
      style: 'background:' + (isUrgent ? 'rgba(244,67,54,.15);color:var(--error)' : 'var(--surface-light);color:var(--text-hint)'),
    }, ['⏱ ' + elapsedMin + ' د']),
  ]);
  if (order.estimatedMinutes != null && order.estimatedSetAt && !isTerminal) {
    side.appendChild(countdownPill(order));
  }

  var head = el('div', { class: 'order-head' }, [
    el('div', { class: 'order-id', style: 'background:' + color + '26;color:' + color }, ['#' + order.id.slice(0, 6).toUpperCase()]),
    el('div', { class: 'order-info' }, [
      el('div', { class: 'order-name' }, [order.customerName]),
      el('div', { class: 'order-phone' }, [order.customerPhone]),
      el('div', { class: 'badges' }, badges),
    ]),
    side,
  ]);
  card.appendChild(head);

  // Items
  var itemsWrap = el('div', { class: 'order-items' });
  order.items.forEach(function (item) {
    var optsSummary = (item.selectedOptions || [])
      .filter(function (o) { return (o.selectedNames || []).length; })
      .map(function (o) { return o.groupName + ': ' + (o.selectedNames || []).join('، '); })
      .join(' | ');
    itemsWrap.appendChild(el('div', { class: 'order-item-row' }, [
      el('div', { class: 'qty-box' }, ['×' + item.quantity]),
      el('div', {}, [item.name + (optsSummary ? '' : ''), optsSummary ? el('div', { class: 'item-opts' }, [optsSummary]) : null]),
    ]));
  });
  card.appendChild(itemsWrap);

  if (order.notes) {
    card.appendChild(el('div', { class: 'order-notes' }, ['📝 ' + order.notes]));
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

  // Actions
  var actionsRow = el('div', { class: 'action-btns' });
  actionsRow.appendChild(actionBtn('طباعة', 'var(--purple)', function () { printOrder(order); }));

  function doUpdate(newStatus, btnEl) {
    btnEl.classList.add('loading');
    var mins = parseInt(timeInput.value, 10);
    if (isNaN(mins)) mins = order.estimatedMinutes == null ? (state.settings.estimatedPrepTime || 30) : null;
    var update = { status: newStatus, updatedAt: firebase.firestore.Timestamp.now() };
    var notesVal = notesInput.value.trim();
    if (notesVal) update.kitchenNotes = notesVal;
    if (mins != null) { update.estimatedMinutes = mins; update.estimatedTime = mins + ' دقيقة'; update.estimatedSetAt = firebase.firestore.Timestamp.now(); }
    db.collection('orders').doc(order.id).update(update)
      .then(function () {
        if (newStatus === 'confirmed') printOrder(order);
      })
      .catch(function (e) { toast('خطأ: ' + e.message); })
      .finally(function () { btnEl.classList.remove('loading'); });
  }

  if (order.status === 'pending') {
    actionsRow.appendChild(actionBtn('تأكيد', '#2196F3', function (btnEl) {
      if (order.driverId && !order.driverAcceptedAt) {
        openConfirmModal(
          'المندوب لم يوافق بعد',
          'المندوب "' + order.driverName + '" لم يوافق بعد على استلام هذا الطلب. يمكنك تأكيد الطلب الآن على أي حال، أو الانتظار حتى يوافق.',
          'تأكيد الآن', function () { doUpdate('confirmed', btnEl); }
        );
      } else {
        doUpdate('confirmed', btnEl);
      }
    }));
  }
  if (order.status === 'confirmed') {
    actionsRow.appendChild(actionBtn('بدء التحضير', 'var(--st-preparing)', function (btnEl) { doUpdate('preparing', btnEl); }));
  }
  if (order.status === 'preparing') {
    actionsRow.appendChild(actionBtn('جاهز', 'var(--st-ready)', function (btnEl) { doUpdate('ready', btnEl); }));
  }
  if (order.status === 'ready' && order.orderType === 'pickup') {
    actionsRow.appendChild(actionBtn('تم التسليم', 'var(--st-delivered)', function (btnEl) { doUpdate('delivered', btnEl); }));
  }
  if (order.status === 'outForDelivery') {
    actionsRow.appendChild(actionBtn('تم التسليم', 'var(--st-delivered)', function (btnEl) { doUpdate('delivered', btnEl); }));
  }
  if (order.status !== 'ready' && order.status !== 'outForDelivery' && !isTerminal) {
    actionsRow.appendChild(actionBtn('إلغاء', 'var(--error)', function (btnEl) {
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

function actionBtn(label, color, onclick) {
  var btn = el('button', { class: 'action-btn', style: 'background:' + color }, [label]);
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
  var color = isLate ? 'var(--error)' : isNear ? 'var(--warning)' : 'var(--success)';
  return el('div', {
    class: 'pill countdown-pill', 'data-end': endTime,
    style: 'background:' + color + '26;color:' + color + ';border:1px solid ' + color + '66',
  }, [(isLate ? '⚠ ' : '⏳ ') + txt]);
}

function buildDriverPanel(order) {
  var wrap = el('div', { class: 'driver-panel' });
  if (!order.driverId) {
    var btn = el('button', { class: 'driver-assign-btn' }, ['🛵 تعيين مندوب']);
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
function printOrder(order) {
  try {
    var df = new Intl.DateTimeFormat('ar', { hour: '2-digit', minute: '2-digit', day: '2-digit', month: '2-digit', year: 'numeric' });
    var shortId = order.id.slice(0, 6).toUpperCase();
    var itemsRows = order.items.map(function (item) {
      var optsLine = (item.selectedOptions || []).filter(function (o) { return (o.selectedNames || []).length; })
        .map(function (o) { return o.groupName + ': ' + o.selectedNames.join('، '); }).join(' | ');
      return '<tr><td style="width:28px;font-weight:bold">×' + item.quantity + '</td><td>' + esc(item.name) +
        (optsLine ? '<div style="font-size:10px;color:#444;padding-right:14px">' + esc(optsLine) + '</div>' : '') +
        '</td><td style="text-align:left;white-space:nowrap">' + (item.price * item.quantity).toFixed(2) + '</td></tr>';
    }).join('');
    var addressLine = order.orderType === 'delivery' && order.deliveryAddress ? '<div>العنوان: ' + esc(order.deliveryAddress) + '</div>' : '';
    var notesSection = order.notes ? '<div class="line"></div><div>ملاحظات: ' + esc(order.notes) + '</div>' : '';
    var html = '' +
      '<div class="slip">' +
      '<h1>' + esc(state.settings.restaurantName) + '</h1>' +
      '<div class="center hint">طلب رقم ' + shortId + '</div>' +
      '<div class="center hint">' + df.format(order.createdAt) + '</div>' +
      '<div class="line"></div>' +
      '<div>العميل: ' + esc(order.customerName) + '</div>' +
      '<div>الجوال: ' + esc(order.customerPhone) + '</div>' +
      '<div>النوع: ' + (order.orderType === 'delivery' ? 'توصيل' : 'استلام من المطعم') + '</div>' +
      addressLine +
      '<div class="line"></div>' +
      '<table>' + itemsRows + '</table>' +
      '<div class="line"></div>' +
      '<table>' +
      '<tr><td>الإجمالي الفرعي</td><td style="text-align:left">' + order.subtotal.toFixed(2) + '</td></tr>' +
      (order.deliveryFee > 0 ? '<tr><td>التوصيل</td><td style="text-align:left">' + order.deliveryFee.toFixed(2) + '</td></tr>' : '') +
      '<tr class="total"><td>الإجمالي</td><td style="text-align:left">' + order.total.toFixed(2) + '</td></tr>' +
      '</table>' +
      notesSection +
      '<div class="line"></div>' +
      '<div class="center hint">شكراً لطلبك من ' + esc(state.settings.restaurantName) + '</div>' +
      '</div>';
    $('#receiptArea').innerHTML = html;
    setTimeout(function () { try { window.print(); } catch (e) { console.warn('print failed', e); } }, 80);
  } catch (e) {
    console.warn('printOrder failed', e);
  }
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

function buildAvailItem(item) {
  var available = item.isAvailable !== false;
  var iconEl = item.imageUrl
    ? el('img', { class: 'avail-icon', src: item.imageUrl, style: available ? '' : 'filter:grayscale(1)' })
    : el('div', { class: 'avail-icon' }, ['🍽️']);

  var toggle = el('input', { type: 'checkbox' });
  toggle.checked = available;
  var switchWrap = el('label', { class: 'switch' }, [toggle, el('span', { class: 'slider' })]);

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

  return el('div', { class: 'avail-item' + (available ? '' : ' off') }, [
    iconEl,
    el('div', { class: 'avail-info' }, [
      el('div', { class: 'avail-name' }, [item.name]),
      el('div', { class: 'avail-price' }, [(item.price || 0).toFixed(2) + ' ر.س']),
    ]),
    switchWrap,
  ]);
}

// ─── تحديث العدّادات كل ثانية (المنقضي + الوقت المتبقي) بدون إعادة رسم كاملة ──
// (تحديث موضعي فقط لنصوص العدّادات — إعادة رسم الصفحة كاملة كل ثانية كانت
// تمسح ما يكتبه الطباخ في حقول "تفاصيل" المفتوحة وتفقد تركيز لوحة المفاتيح)
setInterval(function () {
  if ($('#appView').style.display !== 'block') return;
  document.querySelectorAll('.elapsed-pill').forEach(function (p) {
    var created = parseInt(p.getAttribute('data-created'), 10);
    var mins = Math.floor((Date.now() - created) / 60000);
    p.textContent = '⏱ ' + mins + ' د';
  });
  document.querySelectorAll('.countdown-pill').forEach(function (p) {
    var end = parseInt(p.getAttribute('data-end'), 10);
    var remainingMs = end - Date.now();
    var isLate = remainingMs < 0;
    var absMs = Math.abs(remainingMs);
    var mm = Math.floor(absMs / 60000);
    var ss = Math.floor((absMs % 60000) / 1000);
    p.textContent = (isLate ? '⚠ -' : '⏳ ') + mm + ':' + (ss < 10 ? '0' : '') + ss;
  });
}, 1000);
