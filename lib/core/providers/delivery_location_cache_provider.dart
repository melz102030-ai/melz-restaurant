import 'package:flutter_riverpod/flutter_riverpod.dart';

class CachedLatLng {
  final double lat;
  final double lng;
  const CachedLatLng(this.lat, this.lng);
}

// موقع العميل المكتشف تلقائياً عند اختيار "توصيل" من الشاشة الرئيسية — يُعاد
// استخدامه في شاشة اختيار موقع التوصيل بدل طلب الإذن وجلب GPS من جديد.
final cachedDeliveryLocationProvider = StateProvider<CachedLatLng?>((ref) => null);
