/// مفاتيح الصلاحيات — تُستخدم كأسماء للحقول في Firestore وكمعرِّفات داخلية
abstract class Perm {
  static const String orders     = 'orders';      // الطلبات
  static const String menu       = 'menu';         // القائمة
  static const String users      = 'users';        // الأعضاء والمناديب
  static const String reports    = 'reports';      // التقارير
  static const String settings   = 'settings';     // الإعدادات العامة
  static const String delivery   = 'delivery';     // مناطق التوصيل
  static const String workHours  = 'workHours';    // ساعات العمل
  static const String appearance = 'appearance';   // المظهر والألوان
  static const String content    = 'content';      // البانرات / الإعلانات / الكولاج
  static const String support    = 'support';      // الدعم الفني
  static const String kitchen    = 'kitchen';      // الوصول لواجهة المطبخ

  static const List<String> all = [
    orders, menu, users, reports, settings,
    delivery, workHours, appearance, content, support, kitchen,
  ];

  static const Map<String, String> labels = {
    orders:     'الطلبات',
    menu:       'إدارة القائمة',
    users:      'الأعضاء والمناديب',
    reports:    'التقارير',
    settings:   'الإعدادات العامة',
    delivery:   'مناطق التوصيل',
    workHours:  'ساعات العمل',
    appearance: 'المظهر والألوان',
    content:    'البانرات والإعلانات',
    support:    'الدعم الفني',
    kitchen:    'وصول واجهة المطبخ',
  };

  /// صلاحيات الأدمن الجديد الافتراضية — محدودة ويُفتح المطلوب يدوياً
  static const Map<String, bool> defaultAdmin = {
    orders:     true,
    menu:       false,
    users:      false,
    reports:    false,
    settings:   false,
    delivery:   false,
    workHours:  false,
    appearance: false,
    content:    false,
    support:    false,
    kitchen:    false,
  };
}
