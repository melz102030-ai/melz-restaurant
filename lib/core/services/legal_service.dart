import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/legal_document_model.dart';

// النص الأولي يضعه الخادم عند النشر (.github/scripts/seed-legal.mjs)، ويعدّله الأدمن من لوحة التحكم
abstract class LegalService {
  static const privacyId = 'privacy_policy';
  static const termsId = 'terms_conditions';

  static const titles = {
    privacyId: 'سياسة الخصوصية',
    termsId: 'الشروط والأحكام',
  };

  static CollectionReference get _ref => FirebaseFirestore.instance.collection('legal');

  static Stream<LegalDocumentModel?> streamDocument(String id) {
    return _ref.doc(id).snapshots().map(
          (doc) => doc.exists ? LegalDocumentModel.fromFirestore(doc) : null,
        );
  }

  static Future<void> saveDocument(LegalDocumentModel doc) => _ref.doc(doc.id).set(doc.toMap());
}
