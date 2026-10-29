'use strict';

// ─── Firebase ─────────────────────────────────────────────────────────────────
firebase.initializeApp({
  apiKey: 'AIzaSyC6DBWYEkTNv7QE0P7MAbtJSlSc6YiJnw0',
  appId: '1:576056016616:web:54675719dc0de0da22535d',
  messagingSenderId: '576056016616',
  projectId: 'melz-restaurant',
  authDomain: 'melz-restaurant.firebaseapp.com',
  storageBucket: 'melz-restaurant.firebasestorage.app',
});
var db = firebase.firestore();

// ─── State ────────────────────────────────────────────────────────────────────
var s = {
  cats: [],
  items: [],
  openCats: {},
  menuLoaded: false,
};

// ─── Helpers ──────────────────────────────────────────────────────────────────
function $(id) { return document.getElementById(id); }
function qel(tag, cls, html) {
  var e = document.createElement(tag);
  if (cls) e.className = cls;
  if (html !== undefined) e.innerHTML = html;
  return e;
}
function sar(p) { return p.toFixed(2) + ' ر.س'; }
function esc(str) {
  return String(str || '').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
}

// ─── Theme ────────────────────────────────────────────────────────────────────
// Flutter يخزّن الألوان كـ ARGB integers (مثلاً 0xFF6A0DAD)
// نحوّلها إلى hex string مقبول في CSS: نأخذ 3 bytes السفلية (RGB) فقط
function argbToHex(n) {
  if (!n && n !== 0) return null;
  var r = (n >> 16) & 0xFF;
  var g = (n >> 8) & 0xFF;
  var b = n & 0xFF;
  return '#' + [r, g, b].map(function(c) { return c.toString(16).padStart(2, '0'); }).join('');
}

// لوّن يبدو فاتحاً أم داكناً؟ نستخدمه لتحديد لون النص على خلفية ملوّنة
function isLight(hex) {
  if (!hex) return true;
  var c = parseInt(hex.slice(1), 16);
  var r = (c >> 16) & 0xFF, g = (c >> 8) & 0xFF, b = c & 0xFF;
  return (0.299 * r + 0.587 * g + 0.114 * b) > 155;
}

// نسخة شفافة من لون hex (CSS rgba)
function hexAlpha(hex, alpha) {
  if (!hex) return 'transparent';
  var c = parseInt(hex.slice(1), 16);
  var r = (c >> 16) & 0xFF, g = (c >> 8) & 0xFF, b = c & 0xFF;
  return 'rgba(' + r + ',' + g + ',' + b + ',' + alpha + ')';
}

// الخطوط المدعومة من Google Fonts (نفس قائمة AppThemeSettings في Flutter)
var FONT_MAP = {
  'Cairo': 'Cairo',
  'Tajawal': 'Tajawal',
  'Almarai': 'Almarai',
  'Changa': 'Changa',
  'ElMessiri': 'El+Messiri',
  'El Messiri': 'El+Messiri',
  'El+Messiri': 'El+Messiri',
  'Markazi Text': 'Markazi+Text',
  'MarkaziText': 'Markazi+Text',
  'Reem Kufi': 'Reem+Kufi',
  'ReemKufi': 'Reem+Kufi',
  'IBM Plex Sans Arabic': 'IBM+Plex+Sans+Arabic',
  'IBMPlexSansArabic': 'IBM+Plex+Sans+Arabic',
};

function loadTheme() {
  return db.doc('settings/theme').get().then(function(doc) {
    var d = doc.exists ? doc.data() : {};

    var primary    = argbToHex(d.primaryColor)    || '#6A0DAD';
    var secondary  = argbToHex(d.secondaryColor)  || '#800040';
    var bg         = argbToHex(d.backgroundColor) || '#F5EEDC';
    var card       = argbToHex(d.cardColor)        || '#FFFFFF';
    var textCol    = argbToHex(d.textColor)        || '#1A0030';
    var font       = d.fontFamily || 'Cairo';

    // CSS variables
    var root = document.documentElement;
    root.style.setProperty('--primary',   primary);
    root.style.setProperty('--secondary', secondary);
    root.style.setProperty('--bg',        bg);
    root.style.setProperty('--card',      card);
    root.style.setProperty('--text',      textCol);
    root.style.setProperty('--text2',     hexAlpha(textCol, 0.6));
    root.style.setProperty('--text3',     hexAlpha(textCol, 0.35));
    root.style.setProperty('--p10',       hexAlpha(primary, 0.1));
    root.style.setProperty('--p20',       hexAlpha(primary, 0.2));
    root.style.setProperty('--border',    hexAlpha(primary, 0.15));
    root.style.setProperty('--shadow-p',  '0 6px 24px ' + hexAlpha(primary, 0.25));
    root.style.setProperty('--font',      "'" + font + "', sans-serif");

    // تحديث theme-color meta
    var meta = document.getElementById('metaTheme');
    if (meta) meta.setAttribute('content', primary);

    // تحميل الخط من Google Fonts
    var gfName = FONT_MAP[font] || font.replace(/ /g, '+');
    var linkId = 'gfont-link';
    var existing = document.getElementById(linkId);
    if (existing) existing.remove();
    var link = document.createElement('link');
    link.id = linkId;
    link.rel = 'stylesheet';
    link.href = 'https://fonts.googleapis.com/css2?family=' + gfName + ':wght@400;600;700;800;900&display=swap';
    document.head.appendChild(link);

  }).catch(function() {
    // إذا فشل تحميل الثيم نبقى على الألوان الافتراضية
  });
}

// ─── Views ────────────────────────────────────────────────────────────────────
function showMenu() {
  $('landing').classList.remove('active');
  $('menu').classList.add('active');
  window.scrollTo(0, 0);
  if (!s.menuLoaded) loadMenu();
}

function showLanding() {
  $('menu').classList.remove('active');
  $('landing').classList.add('active');
  window.scrollTo(0, 0);
}

// ─── Load settings (landing page) ─────────────────────────────────────────────
function loadSettings() {
  db.doc('settings/restaurant').get().then(function(doc) {
    var d = doc.exists ? doc.data() : {};
    var name = d.restaurantName || 'ميلز';

    $('landName').textContent = name;
    $('menuTitle').textContent = name + ' · المنيو';
    $('landTagline').textContent = d.tagline || d.address || 'وجبات التوفير';
    $('landFooter').textContent = name;
    document.title = name;

    if (d.logoUrl) {
      var img = document.createElement('img');
      img.src = d.logoUrl;
      img.alt = name;
      $('logoInner').innerHTML = '';
      $('logoInner').appendChild(img);
    }

    var mapsBtn = $('btnMaps');
    if (d.googleMapsUrl) {
      mapsBtn.href = d.googleMapsUrl;
      mapsBtn.classList.remove('disabled-btn');
    }

    var reviewBtn = $('btnReview');
    if (d.googleReviewUrl) {
      reviewBtn.href = d.googleReviewUrl;
      reviewBtn.classList.remove('disabled-btn');
    }
  }).catch(function() {});
}

// ─── Load menu ────────────────────────────────────────────────────────────────
function loadMenu() {
  s.menuLoaded = true;

  var catP = db.collection('categories')
    .orderBy('sortOrder').get()
    .then(function(snap) {
      s.cats = snap.docs
        .map(function(d) { var data = d.data(); return { id: d.id, name: data.name || '', isActive: data.isActive !== false }; })
        .filter(function(c) { return c.isActive; });
    });

  var itemP = db.collection('menu_items')
    .orderBy('sortOrder').get()
    .then(function(snap) {
      s.items = snap.docs
        .map(function(d) {
          var data = d.data();
          return {
            id: d.id,
            name: data.name || '',
            description: data.description || '',
            price: parseFloat(data.price || data.finalPrice || 0),
            imageUrl: data.imageUrl || null,
            categoryId: data.categoryId || '',
            isAvailable: data.isAvailable !== false,
            isBestSeller: !!data.isBestSeller,
          };
        })
        .filter(function(i) { return i.isAvailable; });
    });

  Promise.all([catP, itemP])
    .then(function() { renderMenu(); })
    .catch(function() {
      $('menuLoading').innerHTML = '<div style="font-size:28px;margin-bottom:10px">⚠️</div>تعذّر تحميل القائمة';
    });
}

// ─── Render menu ──────────────────────────────────────────────────────────────
function renderMenu() {
  $('menuLoading').classList.add('hidden');

  var tabsEl = $('catTabs');
  tabsEl.innerHTML = '';
  var firstCatId = null;
  s.cats.forEach(function(cat, i) {
    var count = s.items.filter(function(x) { return x.categoryId === cat.id; }).length;
    if (!count) return;
    if (!firstCatId) firstCatId = cat.id;
    var tab = document.createElement('button');
    tab.className = 'cat-tab' + (i === 0 ? ' active' : '');
    tab.setAttribute('data-catid', cat.id);
    tab.textContent = cat.name;
    tab.addEventListener('click', function() {
      document.querySelectorAll('.cat-tab').forEach(function(t) { t.classList.remove('active'); });
      tab.classList.add('active');
      jumpToSection(cat.id);
    });
    tabsEl.appendChild(tab);
  });
  $('catTabsWrap').classList.remove('hidden');

  var body = $('menuBody');
  body.innerHTML = '';
  s.cats.forEach(function(cat) {
    var catItems = s.items.filter(function(x) { return x.categoryId === cat.id; });
    if (!catItems.length) return;

    var section = document.createElement('div');
    section.className = 'cat-section';
    section.setAttribute('data-sec', cat.id);

    var head = document.createElement('div');
    head.className = 'cat-head';
    head.innerHTML =
      '<div class="cat-head-left"><div class="cat-dot"></div>' +
      '<span class="cat-title">' + esc(cat.name) + '</span>' +
      '<span class="cat-count">' + catItems.length + '</span></div>' +
      '<svg class="cat-arrow" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="6 9 12 15 18 9"/></svg>';

    var panel = document.createElement('div');
    panel.className = 'items-panel';
    panel.setAttribute('data-panel', cat.id);

    var grid = document.createElement('div');
    grid.className = 'items-grid';
    catItems.forEach(function(item) { grid.appendChild(buildCard(item)); });
    panel.appendChild(grid);

    head.addEventListener('click', function() { toggleCat(cat.id, head, panel); });
    section.appendChild(head);
    section.appendChild(panel);
    body.appendChild(section);
  });

  body.classList.remove('hidden');

  if (firstCatId) {
    var fh = body.querySelector('[data-sec="' + firstCatId + '"] .cat-head');
    var fp = body.querySelector('[data-panel="' + firstCatId + '"]');
    if (fh && fp) openCat(firstCatId, fh, fp);
  }
}

function buildCard(item) {
  var card = document.createElement('div');
  card.className = 'item-card';
  card.addEventListener('click', function() { openModal(item); });

  var imgWrap = qel('div', 'item-img-wrap');
  if (item.imageUrl) {
    var img = document.createElement('img');
    img.className = 'item-img';
    img.src = item.imageUrl;
    img.alt = item.name;
    img.loading = 'lazy';
    imgWrap.appendChild(img);
  } else {
    imgWrap.appendChild(qel('div', 'item-img-ph', '🍽️'));
  }
  if (item.isBestSeller) imgWrap.appendChild(qel('span', 'item-best', '⭐ الأكثر طلباً'));
  card.appendChild(imgWrap);

  var info = qel('div', 'item-info');
  info.appendChild(qel('div', 'item-name', esc(item.name)));
  info.appendChild(qel('div', 'item-price', sar(item.price)));
  card.appendChild(info);
  return card;
}

// ─── Category open/close ──────────────────────────────────────────────────────
function openCat(id, head, panel) {
  s.openCats[id] = true;
  head.classList.add('open');
  panel.classList.add('open');
}
function closeCat(id, head, panel) {
  s.openCats[id] = false;
  head.classList.remove('open');
  panel.classList.remove('open');
}
function toggleCat(id, head, panel) {
  if (s.openCats[id]) closeCat(id, head, panel);
  else openCat(id, head, panel);
}
function jumpToSection(id) {
  var sec = document.querySelector('[data-sec="' + id + '"]');
  if (!sec) return;
  var head = sec.querySelector('.cat-head');
  var panel = sec.querySelector('[data-panel="' + id + '"]');
  if (head && panel && !s.openCats[id]) openCat(id, head, panel);
  setTimeout(function() { sec.scrollIntoView({ behavior: 'smooth', block: 'start' }); }, 40);
}

// ─── Modal ────────────────────────────────────────────────────────────────────
function openModal(item) {
  $('mdName').textContent = item.name;
  $('mdDesc').textContent = item.description;
  $('mdPrice').textContent = sar(item.price);
  if (item.isBestSeller) $('mdBest').classList.remove('hidden');
  else $('mdBest').classList.add('hidden');

  var wrap = $('mdImg');
  wrap.innerHTML = '';
  if (item.imageUrl) {
    var img = document.createElement('img');
    img.className = 'modal-img'; img.src = item.imageUrl; img.alt = item.name;
    wrap.appendChild(img);
  } else {
    wrap.appendChild(qel('div', 'modal-img-ph', '🍽️'));
  }

  $('modalBd').classList.add('open');
  document.body.style.overflow = 'hidden';
}
function closeMd(e) { if (e.target === $('modalBd')) closeMdNow(); }
function closeMdNow() { $('modalBd').classList.remove('open'); document.body.style.overflow = ''; }
document.addEventListener('keydown', function(e) { if (e.key === 'Escape') closeMdNow(); });

// ─── Search ───────────────────────────────────────────────────────────────────
var searchTimer;
$('searchInput').addEventListener('input', function() {
  clearTimeout(searchTimer);
  searchTimer = setTimeout(function() { doSearch($('searchInput').value.trim()); }, 200);
});

function doSearch(q) {
  var clearBtn = $('searchClear');
  if (!q) {
    clearBtn.classList.add('hidden');
    $('menuBody').classList.remove('hidden');
    $('catTabsWrap').classList.remove('hidden');
    $('searchResults').classList.add('hidden');
    $('noResults').classList.add('hidden');
    return;
  }
  clearBtn.classList.remove('hidden');
  $('menuBody').classList.add('hidden');
  $('catTabsWrap').classList.add('hidden');

  var low = q.toLowerCase();
  var matches = s.items.filter(function(i) {
    return i.name.toLowerCase().indexOf(low) >= 0 || i.description.toLowerCase().indexOf(low) >= 0;
  });

  if (!matches.length) {
    $('searchResults').classList.add('hidden');
    $('noQ').textContent = q;
    $('noResults').classList.remove('hidden');
    return;
  }
  $('noResults').classList.add('hidden');
  var grid = qel('div', 'items-grid');
  matches.forEach(function(item) { grid.appendChild(buildCard(item)); });
  var res = $('searchResults');
  res.innerHTML = '';
  var wrap = qel('div', 'cat-section');
  wrap.style.marginBottom = '0';
  wrap.appendChild(grid);
  res.appendChild(wrap);
  res.classList.remove('hidden');
}

function clearSearch() {
  $('searchInput').value = '';
  doSearch('');
}

// ─── Tab sync on scroll ───────────────────────────────────────────────────────
window.addEventListener('scroll', function() {
  if ($('searchInput').value.trim()) return;
  var secs = document.querySelectorAll('[data-sec]');
  var active = null;
  secs.forEach(function(sec) { if (sec.getBoundingClientRect().top <= 130) active = sec.getAttribute('data-sec'); });
  if (active) {
    document.querySelectorAll('.cat-tab').forEach(function(t) {
      t.classList.toggle('active', t.getAttribute('data-catid') === active);
    });
  }
}, { passive: true });

// ─── Boot ─────────────────────────────────────────────────────────────────────
// نحمّل الثيم أولاً ثم بيانات الصفحة بالتوازي
loadTheme().then(function() {
  loadSettings();
});
