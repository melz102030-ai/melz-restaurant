import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/popup_ad_model.dart';
import '../services/popup_ad_service.dart';

// الإعلان النشط الذي يُعرض للعميل عند الدخول
final activePopupAdProvider = StreamProvider<PopupAdModel?>((ref) {
  return PopupAdService.streamActiveAd();
});

// كل الإعلانات — لوحة تحكم الأدمن
final adminPopupAdsProvider = StreamProvider<List<PopupAdModel>>((ref) {
  return PopupAdService.streamAds();
});
