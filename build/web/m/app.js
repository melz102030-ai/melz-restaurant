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
var s = { cats: [], items: [], menuLoaded: false };

// ─── Helpers ──────────────────────────────────────────────────────────────────
function $(id) { return document.getElementById(id); }
function qel(tag, cls) { var e = document.createElement(tag); if (cls) e.className = cls; return e; }
function sar(p) { return p.toFixed(2) + ' ر.س'; }
function esc(str) {
  return String(str || '')
    .replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
}

// ─── Theme ────────────────────────────────────────────────────────────────────
function argbToHex(n) {
  if (!n && n !== 0) return null;
  var r = (n >> 16) & 0xFF, g = (n >> 8) & 0xFF, b = n & 0xFF;
  return '#' + [r,g,b].map(function(c){ return c.toString(16).padStart(2,'0'); }).join('');
}
function hexAlpha(hex, a) {
  if (!hex) return 'transparent';
  var c = parseInt(hex.slice(1),16);
  return 'rgba('+((c>>16)&255)+','+((c>>8)&255)+','+(c&255)+','+a+')';
}
var FONT_MAP = {
  'Cairo':'Cairo','Tajawal':'Tajawal','Almarai':'Almarai','Changa':'Changa',
  'ElMessiri':'El+Messiri','El Messiri':'El+Messiri',
  'Markazi Text':'Markazi+Text','MarkaziText':'Markazi+Text',
  'Reem Kufi':'Reem+Kufi','ReemKufi':'Reem+Kufi',
  'IBM Plex Sans Arabic':'IBM+Plex+Sans+Arabic','IBMPlexSansArabic':'IBM+Plex+Sans+Arabic',
};

function loadTheme() {
  return db.doc('settings/theme').get().then(function(doc) {
    var d = doc.exists ? doc.data() : {};
    var primary   = argbToHex(d.primaryColor)    || '#6A0DAD';
    var secondary = argbToHex(d.secondaryColor)  || '#800040';
    var bg        = argbToHex(d.backgroundColor) || '#F5EEDC';
    var card      = argbToHex(d.cardColor)        || '#FFFFFF';
    var textCol   = argbToHex(d.textColor)        || '#1A0030';
    var font      = d.fontFamily || 'Cairo';

    var r = document.documentElement;
    r.style.setProperty('--primary',  primary);
    r.style.setProperty('--secondary',secondary);
    r.style.setProperty('--bg',       bg);
    r.style.setProperty('--card',     card);
    r.style.setProperty('--text',     textCol);
    r.style.setProperty('--text2',    hexAlpha(textCol, .6));
    r.style.setProperty('--text3',    hexAlpha(textCol, .35));
    r.style.setProperty('--p10',      hexAlpha(primary, .1));
    r.style.setProperty('--p20',      hexAlpha(primary, .2));
    r.style.setProperty('--border',   hexAlpha(primary, .15));
    r.style.setProperty('--shadow-p', '0 6px 24px '+hexAlpha(primary,.25));
    r.style.setProperty('--font',     "'"+font+"', sans-serif");

    var m = $('metaTheme'); if (m) m.setAttribute('content', primary);

    var gfName = FONT_MAP[font] || font.replace(/ /g,'+');
    var lk = document.createElement('link');
    lk.id='gfont-link'; lk.rel='stylesheet';
    lk.href='https://fonts.googleapis.com/css2?family='+gfName+':wght@400;600;700;800;900&display=swap';
    document.head.appendChild(lk);
  }).catch(function(){});
}

// ─── Views ────────────────────────────────────────────────────────────────────
function showMenu() {
  $('landing').classList.remove('active');
  $('menu').classList.add('active');
  window.scrollTo(0,0);
  if (!s.menuLoaded) loadMenu();
}
function showLanding() {
  $('menu').classList.remove('active');
  $('landing').classList.add('active');
  window.scrollTo(0,0);
}

// ─── Load settings ────────────────────────────────────────────────────────────
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
      img.src = d.logoUrl; img.alt = name;
      $('logoInner').innerHTML = '';
      $('logoInner').appendChild(img);
    }
    if (d.googleMapsUrl)   { $('btnMaps').href = d.googleMapsUrl;     $('btnMaps').classList.remove('dim'); }
    if (d.googleReviewUrl) { $('btnReview').href = d.googleReviewUrl; $('btnReview').classList.remove('dim'); }
  }).catch(function(){});
}

// ─── Load menu ────────────────────────────────────────────────────────────────
function loadMenu() {
  s.menuLoaded = true;
  var catP = db.collection('categories').orderBy('sortOrder').get().then(function(snap) {
    s.cats = snap.docs
      .map(function(d){ var x=d.data(); return {id:d.id,name:x.name||'',isActive:x.isActive!==false}; })
      .filter(function(c){ return c.isActive; });
  });
  var itemP = db.collection('menu_items').orderBy('sortOrder').get().then(function(snap) {
    s.items = snap.docs
      .map(function(d){
        var x=d.data();
        return {
          id:d.id, name:x.name||'', description:x.description||'',
          price:parseFloat(x.price||x.finalPrice||0),
          imageUrl:x.imageUrl||null, categoryId:x.categoryId||'',
          isAvailable:x.isAvailable!==false, isBestSeller:!!x.isBestSeller,
        };
      })
      .filter(function(i){ return i.isAvailable; });
  });
  Promise.all([catP,itemP]).then(renderMenu).catch(function(){
    $('menuLoading').innerHTML = '<div style="font-size:26px;margin-bottom:10px">⚠️</div>تعذّر تحميل القائمة';
  });
}

// ─── Render menu ──────────────────────────────────────────────────────────────
// IntersectionObserver لظهور الكروت عند التمرير
var observer = new IntersectionObserver(function(entries) {
  entries.forEach(function(entry) {
    if (entry.isIntersecting) {
      entry.target.classList.add('visible');
      observer.unobserve(entry.target);
    }
  });
}, { threshold: 0.08, rootMargin: '0px 0px -20px 0px' });

function renderMenu() {
  $('menuLoading').classList.add('hidden');
  var content = $('menuContent');
  content.innerHTML = '';

  s.cats.forEach(function(cat) {
    var catItems = s.items.filter(function(x){ return x.categoryId === cat.id; });
    if (!catItems.length) return;

    // عنوان القسم
    var label = qel('div','cat-label');
    label.innerHTML =
      '<div class="cat-label-dot"></div>'+
      '<span class="cat-label-name">'+esc(cat.name)+'</span>'+
      '<div class="cat-label-line"></div>'+
      '<span class="cat-label-count">'+catItems.length+'</span>';
    content.appendChild(label);

    // كروت الأصناف
    catItems.forEach(function(item, idx) {
      var card = buildCard(item, idx);
      content.appendChild(card);
      observer.observe(card);
    });
  });

  content.classList.remove('hidden');
}

function buildCard(item, idx) {
  var card = qel('div','item-card');
  // تأخير بسيط حسب ترتيب الصنف لتأثير متتالٍ أنيق
  var delay = Math.min(idx * 40, 400);
  card.style.transitionDelay = delay + 'ms';
  card.addEventListener('click', function(){ openModal(item); });

  // صورة
  var imgWrap = qel('div','item-img-wrap');
  if (item.imageUrl) {
    var img = document.createElement('img');
    img.className = 'item-img'; img.src = item.imageUrl; img.alt = item.name; img.loading = 'lazy';
    imgWrap.appendChild(img);
  } else {
    imgWrap.appendChild(qel('div','item-img-ph'));
  }
  card.appendChild(imgWrap);

  // معلومات
  var info = qel('div','item-info');
  var nameEl = qel('div','item-name'); nameEl.textContent = item.name; info.appendChild(nameEl);
  if (item.description) {
    var desc = qel('div','item-desc'); desc.textContent = item.description; info.appendChild(desc);
  }
  var footer = qel('div','item-footer');
  var price = qel('span','item-price'); price.textContent = sar(item.price); footer.appendChild(price);
  if (item.isBestSeller) {
    var best = qel('span','item-best'); best.textContent = '⭐ الأكثر طلباً'; footer.appendChild(best);
  }
  info.appendChild(footer);
  card.appendChild(info);
  return card;
}

// ─── Modal ────────────────────────────────────────────────────────────────────
function openModal(item) {
  $('mdName').textContent = item.name;
  $('mdDesc').textContent = item.description;
  $('mdPrice').textContent = sar(item.price);
  item.isBestSeller ? $('mdBest').classList.remove('hidden') : $('mdBest').classList.add('hidden');

  var wrap = $('mdImg'); wrap.innerHTML = '';
  if (item.imageUrl) {
    var img = document.createElement('img');
    img.className='modal-img'; img.src=item.imageUrl; img.alt=item.name;
    wrap.appendChild(img);
  } else {
    wrap.appendChild(qel('div','modal-img-ph'));
  }
  $('modalBd').classList.add('open');
  document.body.style.overflow = 'hidden';
}
function closeMd(e) { if (e.target===$('modalBd')) closeMdNow(); }
function closeMdNow() { $('modalBd').classList.remove('open'); document.body.style.overflow=''; }
document.addEventListener('keydown', function(e){ if(e.key==='Escape') closeMdNow(); });

// ─── Boot ─────────────────────────────────────────────────────────────────────
loadTheme().then(loadSettings);
