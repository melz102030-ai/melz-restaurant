package woyou.aidlservice.jiuiv5;

// واجهة رسمية ثابتة لخدمة طابعة Sunmi الداخلية — نسخة طبق الأصل من واجهة
// SDK الرسمية (لا نستخدم أي دالة منها فعلياً، نمرّر null دائماً، لكن
// وجودها هنا لازم ليبقى ترتيب الدوال في IWoyouService.aidl متطابقاً تماماً
// مع الخدمة الحقيقية المثبَّتة على الجهاز — ترتيب الإعلان هنا يحدِّد رقم
// العملية الداخلية (transaction id) لكل دالة، ولو اختلف الترتيب عن
// الخدمة الفعلية ستُستدعى دالة أخرى خطأً دون أي رسالة خطأ واضحة)
interface ICallback {
    oneway void onRunResult(boolean isSuccess);
    oneway void onReturnString(String result);
    oneway void onRaiseException(int code, String msg);
}
