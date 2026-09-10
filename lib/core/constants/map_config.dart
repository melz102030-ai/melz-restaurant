/// إعداد بلاطات الخريطة الموحّد لكل الشاشات (العميل، المندوب، لوحة التحكم).
///
/// نستخدم بلاطات CARTO Voyager: مجانية بلا مفتاح API ولا فوترة، ومظهرها
/// (ألوان الطرق، تسميات الأماكن، التدرّج) قريب جداً من خرائط جوجل — بديل
/// عملي لتجنّب تكلفة Google Maps Platform مع الحفاظ على شكل مألوف.
///
/// شرط الاستخدام الوحيد: إظهار الإسناد ([attribution]) على الخريطة.
class MapConfig {
  const MapConfig._();

  /// قالب رابط البلاطات — يستهلكه TileLayer في flutter_map مباشرة.
  static const String tileUrl =
      'https://basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png';

  /// اسم الحزمة المطلوب من flutter_map لترويسة User-Agent عند جلب البلاطات.
  static const String userAgentPackageName = 'com.melz.restaurant';

  /// نص الإسناد الواجب عرضه فوق كل خريطة (شرط رخصة CARTO + OpenStreetMap).
  static const String attribution = '© CARTO · © OpenStreetMap';
}
