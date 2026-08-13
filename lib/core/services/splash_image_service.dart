import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/splash_image_model.dart';

// إدارة صور خلفية شاشة التحميل الأولى (الكولاج المتحرك في web/index.html).
// ملاحظة: index.html يقرأ هذه المجموعة مباشرة عبر Firestore REST قبل تحميل
// Flutter، لذا يجب أن تبقى قواعد Firestore تسمح بالقراءة العامة لمجموعة
// splash_images (بنفس صلاحيات categories/menu_items الحالية).
class SplashImageService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const String _col = 'splash_images';

  static Stream<List<SplashImageModel>> streamImages() {
    return _db
        .collection(_col)
        .orderBy('sortOrder')
        .snapshots()
        .map((snap) => snap.docs.map((d) => SplashImageModel.fromMap(d.data(), d.id)).toList());
  }

  static Future<String> addImage(String imageUrl, int sortOrder) async {
    final ref = _db.collection(_col).doc();
    await ref.set(SplashImageModel(id: ref.id, imageUrl: imageUrl, sortOrder: sortOrder).toMap());
    return ref.id;
  }

  static Future<void> deleteImage(String id) async {
    await _db.collection(_col).doc(id).delete();
  }

  static Future<void> toggleActive(String id, bool active) async {
    await _db.collection(_col).doc(id).update({'isActive': active});
  }

  static Future<void> reorder(List<SplashImageModel> images) async {
    final batch = _db.batch();
    for (int i = 0; i < images.length; i++) {
      batch.update(_db.collection(_col).doc(images[i].id), {'sortOrder': i});
    }
    await batch.commit();
  }
}
