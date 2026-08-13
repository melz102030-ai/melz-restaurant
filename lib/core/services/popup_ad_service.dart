import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/popup_ad_model.dart';

class PopupAdService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const String _colAds = 'popup_ads';

  static Stream<List<PopupAdModel>> streamAds() {
    return _db
        .collection(_colAds)
        .orderBy('sortOrder')
        .snapshots()
        .map((snap) => snap.docs.map((d) => PopupAdModel.fromMap(d.data(), d.id)).toList());
  }

  // أول إعلان نشط فقط — يُعرض للعميل عند الدخول
  static Stream<PopupAdModel?> streamActiveAd() {
    return streamAds().map((ads) {
      final active = ads.where((a) => a.isActive && a.imageUrls.isNotEmpty).toList();
      return active.isEmpty ? null : active.first;
    });
  }

  static Future<String> addAd(PopupAdModel ad) async {
    final ref = _db.collection(_colAds).doc();
    await ref.set(ad.toMap());
    return ref.id;
  }

  static Future<void> updateAd(PopupAdModel ad) async {
    await _db.collection(_colAds).doc(ad.id).update(ad.toMap());
  }

  static Future<void> deleteAd(String adId) async {
    await _db.collection(_colAds).doc(adId).delete();
  }

  static Future<void> toggleAdActive(String adId, bool active) async {
    await _db.collection(_colAds).doc(adId).update({'isActive': active});
  }

  static Future<void> reorderAds(List<PopupAdModel> ads) async {
    final batch = _db.batch();
    for (int i = 0; i < ads.length; i++) {
      batch.update(_db.collection(_colAds).doc(ads[i].id), {'sortOrder': i});
    }
    await batch.commit();
  }
}
