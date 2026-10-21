// سكربت خدمة بسيط جداً — غرضه الوحيد تلبية شرط "قابلية التثبيت" في كروم
// (بعض إصدارات كروم القديمة تتطلب service worker مسجَّلاً مع معالج fetch
// حتى تعرض زر "تثبيت التطبيق" الحقيقي بدل اختصار صفحة عادي فقط). لا يخزّن
// أي شيء ولا يتدخل في أي طلب شبكة — مجرد تمرير مباشر (pass-through).
self.addEventListener('fetch', function (event) {
  event.respondWith(fetch(event.request));
});
