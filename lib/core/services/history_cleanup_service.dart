import 'package:cloud_firestore/cloud_firestore.dart';

/// أجزاء السجل التي يمكن مسحها. القائمة والإعدادات والموظفون وأرقام الطلبات
/// لا تُمس أبداً.
enum HistoryPart { orders, support, verifiedPhones }

/// مسح سجل التجارب نهائياً، لمن له صلاحية «مسح السجل» (راجع firestore.rules)
class HistoryCleanupService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const int _batchSize = 400;

  // ملخصات التقارير تُبنى من الطلبات، فتُمسح معها حتى لا تبقى أرقام بلا طلبات
  static const Map<HistoryPart, List<String>> _collections = {
    HistoryPart.orders: ['orders', 'daily_summaries'],
    HistoryPart.support: ['support_tickets'],
    HistoryPart.verifiedPhones: ['verified_phones'],
  };

  static Future<int> count(HistoryPart part) async {
    final result = await _db.collection(_collections[part]!.first).count().get();
    return result.count ?? 0;
  }

  /// يعيد عدد ما مُسح من الجزء الأساسي لكل قسم (الطلبات، التذاكر، الأرقام)
  static Future<int> clear(Set<HistoryPart> parts, {void Function(int deleted)? onProgress}) async {
    var deleted = 0;
    for (final part in HistoryPart.values.where(parts.contains)) {
      final collections = _collections[part]!;
      for (final name in collections) {
        while (true) {
          final snap = await _db.collection(name).limit(_batchSize).get();
          if (snap.docs.isEmpty) break;
          final batch = _db.batch();
          for (final doc in snap.docs) {
            batch.delete(doc.reference);
          }
          await batch.commit();
          if (name == collections.first) {
            deleted += snap.docs.length;
            onProgress?.call(deleted);
          }
        }
      }
    }
    return deleted;
  }
}
