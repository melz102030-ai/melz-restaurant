import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/promo_banner_model.dart';

class PromoBannerService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const String _colBanners = 'promo_banners';

  static Stream<List<PromoBannerModel>> streamBanners() {
    return _db
        .collection(_colBanners)
        .orderBy('sortOrder')
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => PromoBannerModel.fromMap(d.data(), d.id)).toList());
  }

  // فلترة النشط في Dart (تجنّب composite index)، بنفس نمط streamMenuItems
  static Stream<List<PromoBannerModel>> streamActiveBanners() {
    return streamBanners().map((b) => b.where((x) => x.isActive).toList());
  }

  static Future<String> addBanner(PromoBannerModel banner) async {
    final ref = _db.collection(_colBanners).doc();
    await ref.set(banner.toMap());
    return ref.id;
  }

  static Future<void> updateBanner(PromoBannerModel banner) async {
    await _db.collection(_colBanners).doc(banner.id).update(banner.toMap());
  }

  static Future<void> deleteBanner(String bannerId) async {
    await _db.collection(_colBanners).doc(bannerId).delete();
  }

  static Future<void> toggleBannerActive(String bannerId, bool active) async {
    await _db.collection(_colBanners).doc(bannerId).update({'isActive': active});
  }

  static Future<void> reorderBanners(List<PromoBannerModel> banners) async {
    final batch = _db.batch();
    for (int i = 0; i < banners.length; i++) {
      batch.update(_db.collection(_colBanners).doc(banners[i].id), {'sortOrder': i});
    }
    await batch.commit();
  }
}
