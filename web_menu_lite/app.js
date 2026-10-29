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
var state = {
  categories: [],   // [{id, name, sortOrder}]
  items: [],        // [{id, name, description, price, imageUrl, categoryId, isAvailable, isBestSeller}]
  openCats: {},     // catId -> bool
};

// ─── Helpers ──────────────────────────────────────────────────────────────────
function $(id) { return document.getElementById(id); }
function el(tag, attrs, html) {
  var e = document.createElement(tag);
  if (attrs) Object.keys(attrs).forEach(function(k) {
    if (k === 'class') e.className = attrs[k];
    else if (k === 'style') e.style.cssText = attrs[k];
    else e.setAttribute(k, attrs[k]);
  });
  if (html !== undefined) e.innerHTML = html;
  return e;
}
function sar(price) {
  return price.toFixed(2) + ' ر.س';
}

// ─── Load data ────────────────────────────────────────────────────────────────
function loadAll() {
  // Settings
  db.collection('settings').doc('main').get().then(function(doc) {
    if (!doc.exists) return;
    var d = doc.data();
    var name = d.restaurantName || d.name || 'ميلز';
    $('siteName').textContent = name;
    $('siteTagline').textContent = d.tagline || d.description || '';
    $('footerName').textContent = name;
    document.title = 'منيو ' + name;

    if (d.logoUrl) {
      var img = el('img', { src: d.logoUrl, alt: name });
      $('logoWrap').innerHTML = '';
      $('logoWrap').appendChild(img);
    }
  }).catch(function() {});

  // Categories + items in parallel
  var catPromise = db.collection('categories')
    .orderBy('sortOrder')
    .get()
    .then(function(snap) {
      state.categories = snap.docs
        .map(function(d) {
          var data = d.data();
          return { id: d.id, name: data.name || '', sortOrder: data.sortOrder || 0, isVisible: data.isVisible !== false };
        })
        .filter(function(c) { return c.isVisible; });
    });

  var itemsPromise = db.collection('menuItems')
    .orderBy('sortOrder')
    .get()
    .then(function(snap) {
      state.items = snap.docs
        .map(function(d) {
          var data = d.data();
          return {
            id: d.id,
            name: data.name || '',
            description: data.description || '',
            price: (data.price || data.finalPrice || 0),
            imageUrl: data.imageUrl || null,
            categoryId: data.categoryId || '',
            isAvailable: data.isAvailable !== false,
            isBestSeller: !!data.isBestSeller,
          };
        })
        .filter(function(i) { return i.isAvailable; });
    });

  Promise.all([catPromise, itemsPromise])
    .then(function() { render(); })
    .catch(function(err) {
      $('loadingMsg').innerHTML = '<div style="font-size:32px;margin-bottom:12px">⚠️</div>تعذّر تحميل القائمة';
    });
}

// ─── Render ───────────────────────────────────────────────────────────────────
function render() {
  $('loadingMsg').classList.add('hidden');

  var cats = state.categories;
  if (!cats.length) {
    $('loadingMsg').textContent = 'القائمة فارغة حالياً';
    $('loadingMsg').classList.remove('hidden');
    return;
  }

  // Build tabs
  var tabsEl = $('catTabs');
  tabsEl.innerHTML = '';
  cats.forEach(function(cat, i) {
    var itemsInCat = state.items.filter(function(x) { return x.categoryId === cat.id; });
    if (!itemsInCat.length) return;
    var tab = el('button', { class: 'cat-tab' + (i === 0 ? ' active' : ''), 'data-catid': cat.id });
    tab.textContent = cat.name;
    tab.addEventListener('click', function() {
      document.querySelectorAll('.cat-tab').forEach(function(t) { t.classList.remove('active'); });
      tab.classList.add('active');
      scrollToCategory(cat.id);
    });
    tabsEl.appendChild(tab);
  });
  $('catTabsWrap').classList.remove('hidden');

  // Build sections
  var content = $('mainContent');
  content.innerHTML = '';
  cats.forEach(function(cat) {
    var itemsInCat = state.items.filter(function(x) { return x.categoryId === cat.id; });
    if (!itemsInCat.length) return;

    var section = el('div', { class: 'category-section', 'data-section': cat.id });

    // Header
    var header = el('div', { class: 'category-header', role: 'button', 'aria-expanded': 'false' });
    var left = el('div', { class: 'cat-header-left' });
    left.appendChild(el('div', { class: 'cat-dot' }));
    var nameEl = el('span', { class: 'cat-name' }, cat.name);
    var countEl = el('span', { class: 'cat-count' }, itemsInCat.length.toString());
    left.appendChild(nameEl);
    left.appendChild(countEl);
    var arrow = el('svg', { class: 'cat-arrow', width: '20', height: '20', viewBox: '0 0 24 24', fill: 'none', stroke: 'currentColor', 'stroke-width': '2.5' });
    arrow.innerHTML = '<polyline points="6 9 12 15 18 9"/>';
    header.appendChild(left);
    header.appendChild(arrow);

    // Panel
    var panel = el('div', { class: 'items-panel', 'data-panel': cat.id });
    var grid = el('div', { class: 'items-grid' });
    itemsInCat.forEach(function(item) {
      grid.appendChild(buildItemCard(item));
    });
    panel.appendChild(grid);

    header.addEventListener('click', function() { toggleCategory(cat.id, header, panel); });

    section.appendChild(header);
    section.appendChild(panel);
    content.appendChild(section);
  });

  content.classList.remove('hidden');

  // Open first category by default
  var first = cats.find(function(c) { return state.items.some(function(i) { return i.categoryId === c.id; }); });
  if (first) {
    var fh = content.querySelector('[data-section="' + first.id + '"] .category-header');
    var fp = content.querySelector('[data-panel="' + first.id + '"]');
    if (fh && fp) openCategory(first.id, fh, fp);
  }
}

function buildItemCard(item) {
  var card = el('div', { class: 'item-card', role: 'button', 'aria-label': item.name });
  card.addEventListener('click', function() { openModal(item); });

  // Image
  var imgWrap = el('div', { class: 'item-img-wrap' });
  if (item.imageUrl) {
    var img = el('img', { class: 'item-img', src: item.imageUrl, alt: item.name, loading: 'lazy' });
    imgWrap.appendChild(img);
  } else {
    imgWrap.appendChild(el('div', { class: 'item-img-placeholder' }, '🍽️'));
  }
  if (item.isBestSeller) {
    imgWrap.appendChild(el('span', { class: 'item-badge' }, '⭐ الأكثر طلباً'));
  }
  card.appendChild(imgWrap);

  // Info
  var info = el('div', { class: 'item-info' });
  info.appendChild(el('div', { class: 'item-name' }, escHtml(item.name)));
  info.appendChild(el('div', { class: 'item-price' }, sar(item.price)));
  card.appendChild(info);

  return card;
}

// ─── Category toggle ──────────────────────────────────────────────────────────
function openCategory(catId, header, panel) {
  state.openCats[catId] = true;
  header.classList.add('open');
  header.setAttribute('aria-expanded', 'true');
  panel.classList.add('open');
  // Smooth height animation
  panel.style.maxHeight = panel.scrollHeight + 'px';
}

function closeCategory(catId, header, panel) {
  state.openCats[catId] = false;
  header.classList.remove('open');
  header.setAttribute('aria-expanded', 'false');
  panel.classList.remove('open');
  panel.style.maxHeight = '';
}

function toggleCategory(catId, header, panel) {
  if (state.openCats[catId]) {
    closeCategory(catId, header, panel);
  } else {
    openCategory(catId, header, panel);
  }
}

function scrollToCategory(catId) {
  var section = document.querySelector('[data-section="' + catId + '"]');
  if (!section) return;
  var header = section.querySelector('.category-header');
  var panel  = section.querySelector('[data-panel="' + catId + '"]');
  if (header && panel && !state.openCats[catId]) {
    openCategory(catId, header, panel);
  }
  setTimeout(function() {
    section.scrollIntoView({ behavior: 'smooth', block: 'start' });
  }, 50);
}

// ─── Modal ────────────────────────────────────────────────────────────────────
function openModal(item) {
  $('modalTitle').textContent = item.name;
  $('modalDesc').textContent = item.description || '';
  $('modalPrice').textContent = sar(item.price);

  if (item.isBestSeller) $('modalBest').classList.remove('hidden');
  else $('modalBest').classList.add('hidden');

  var imgWrap = $('modalImgWrap');
  imgWrap.innerHTML = '';
  if (item.imageUrl) {
    var img = el('img', { class: 'modal-img', src: item.imageUrl, alt: item.name });
    imgWrap.appendChild(img);
  } else {
    imgWrap.appendChild(el('div', { class: 'modal-img-placeholder' }, '🍽️'));
  }

  $('modalBackdrop').classList.add('open');
  document.body.style.overflow = 'hidden';
}

function closeModal(e) {
  if (e && e.target !== $('modalBackdrop')) return;
  closeModalDirect();
}

function closeModalDirect() {
  $('modalBackdrop').classList.remove('open');
  document.body.style.overflow = '';
}

// Close on ESC
document.addEventListener('keydown', function(e) { if (e.key === 'Escape') closeModalDirect(); });

// ─── Search ───────────────────────────────────────────────────────────────────
var searchTimer = null;

$('searchInput').addEventListener('input', function() {
  clearTimeout(searchTimer);
  searchTimer = setTimeout(function() { doSearch($('searchInput').value.trim()); }, 180);
});

function doSearch(q) {
  var clearBtn = $('searchClear');
  if (!q) {
    clearBtn.classList.add('hidden');
    $('mainContent').classList.remove('hidden');
    $('catTabsWrap').classList.remove('hidden');
    $('searchResults').classList.add('hidden');
    $('noResults').classList.add('hidden');
    return;
  }
  clearBtn.classList.remove('hidden');
  $('mainContent').classList.add('hidden');
  $('catTabsWrap').classList.add('hidden');

  var lower = q.toLowerCase();
  var matches = state.items.filter(function(i) {
    return i.name.toLowerCase().indexOf(lower) >= 0 ||
           (i.description && i.description.toLowerCase().indexOf(lower) >= 0);
  });

  var resEl = $('searchResults');
  if (!matches.length) {
    resEl.classList.add('hidden');
    $('noResultsQuery').textContent = q;
    $('noResults').classList.remove('hidden');
    return;
  }
  $('noResults').classList.add('hidden');

  var grid = el('div', { class: 'items-grid' });
  matches.forEach(function(item) { grid.appendChild(buildItemCard(item)); });
  resEl.innerHTML = '';
  resEl.appendChild(grid);
  resEl.classList.remove('hidden');
}

function clearSearch() {
  $('searchInput').value = '';
  doSearch('');
}

// ─── Escape HTML ──────────────────────────────────────────────────────────────
function escHtml(str) {
  return String(str).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
}

// ─── Tab highlight on scroll ──────────────────────────────────────────────────
window.addEventListener('scroll', function() {
  if ($('searchInput').value.trim()) return;
  var sections = document.querySelectorAll('[data-section]');
  var bestId = null;
  sections.forEach(function(s) {
    var rect = s.getBoundingClientRect();
    if (rect.top <= 160) bestId = s.getAttribute('data-section');
  });
  if (bestId) {
    document.querySelectorAll('.cat-tab').forEach(function(t) {
      t.classList.toggle('active', t.getAttribute('data-catid') === bestId);
    });
  }
}, { passive: true });

// ─── Boot ─────────────────────────────────────────────────────────────────────
loadAll();
