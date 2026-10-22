// سكربت خدمة بسيط — غرضه الوحيد تلبية شرط "قابلية التثبيت" في كروم
// (تثبيت كتطبيق حقيقي على الشاشة الرئيسية). لا يخزّن أي شيء ولا يتدخل في
// أي طلب شبكة — مجرد تمرير مباشر (pass-through).
self.addEventListener('fetch', function (event) {
  event.respondWith(fetch(event.request));
});
