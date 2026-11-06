import 'package:cloud_firestore/cloud_firestore.dart';

/// مسح سجل الطلبات الماضية نهائياً، لمن له صلاحية «مسح سجل الطلبات»
/// (راجع firestore.rules). لا يمس القائمة ولا الإعدادات ولا الموظفين ولا الدعم.
class HistoryCleanupService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const int _batchSize = 400;

  static Future<int> countOrders() async {
    final result = await _db.collection('orders').count().get();
    return result.count ?? 0;
  }

  /// يعيد عدد الطلبات الممسوحة. ملخصات التقارير تُبنى من الطلبات، فتُمسح معها
  /// حتى لا تبقى في التقارير أرقام بلا طلبات.
  static Future<int> clearOrders({void Function(int deleted)? onProgress}) async {
    final deleted = await _clear('orders', onProgress);
    await _clear('daily_summaries', null);
    return deleted;
  }

  static Future<int> _clear(String name, void Function(int deleted)? onProgress) async {
    var deleted = 0;
    while (true) {
      final snap = await _db.collection(name).limit(_batchSize).get();
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
