// نتيجة اختيار موقع التوصيل. منفصلة عن شاشة الخريطة، لأن الشاشة تُحمَّل عند الحاجة فقط
class DeliveryLocationResult {
  final double lat;
  final double lng;
  final String? addressNote;
  const DeliveryLocationResult({
    required this.lat,
    required this.lng,
    this.addressNote,
  });
}
