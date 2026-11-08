import 'package:cloud_firestore/cloud_firestore.dart';

/// مسح سجل الطلبات الماضية نهائياً، لمن له صلاحية «مسح سجل الطلبات»
/// (راجع firestore.rules). لا يمس القائمة ولا الإعدادات ولا الموظفين ولا الدعم.
class HistoryCleanupService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const int _batchSize = 400;

  // يعدّ الطلبات المكتملة فعلاً (تُسلَّم أو تُلغى) — هي فقط ما سيُحذف
  static Future<int> countOrders() async {
    final result = await _db
        .collection('orders')
        .where('status', whereIn: ['delivered', 'cancelled'])
        .count()
        .get();
    return result.count ?? 0;
  }

  /// يعيد عدد الطلبات الممسوحة. ملخصات التقارير تُبنى من الطلبات، فتُمسح معها
  /// حتى لا تبقى في التقارير أرقام بلا طلبات.
  /// الطلبات النشطة (pending/preparing/...) لا تُمسح حتى لا يتلف طلب جارٍ.
  static Future<int> clearOrders({void Function(int deleted)? onProgress}) async {
    final deleted = await _clear('orders', onProgress,
        filter: (q) => q.where('status', whereIn: ['delivered', 'cancelled']));
    await _clear('daily_summaries', null);
    return deleted;
  }

  static Future<int> _clear(
    String name,
    void Function(int deleted)? onProgress, {
    Query<Map<String, dynamic>> Function(CollectionReference<Map<String, dynamic>> q)? filter,
  }) async {
    var deleted = 0;
    while (true) {
      Query<Map<String, dynamic>> q = _db.collection(name);
      if (filter != null) q = filter(_db.collection(name));
      final snap = await q.limit(_batchSize).get();
      if (snap.docs.isEmpty) break;
      final batch = _db.batch();
      for (final doc in snap.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      deleted += snap.docs.length;
      onProgress?.call(deleted);
    }
    return deleted;
  }
}
