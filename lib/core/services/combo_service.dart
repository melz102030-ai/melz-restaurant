import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/combo_model.dart';

class ComboService {
  static final _col = FirebaseFirestore.instance.collection('combos');

  static Stream<List<ComboModel>> streamCombos({bool activeOnly = false}) {
    return _col.snapshots().map((s) {
      final list = s.docs
          .map((d) => ComboModel.fromMap(d.data() as Map<String, dynamic>, d.id))
          .toList();
      list.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      if (activeOnly) return list.where((c) => c.isActive).toList();
      return list;
    });
  }

  static Future<void> save(ComboModel combo) async {
    final map = combo.toMap();
    if (combo.id.isEmpty) {
      await _col.add(map);
    } else {
      await _col.doc(combo.id).set(map);
    }
  }

  static Future<void> delete(String id) => _col.doc(id).delete();

  static Future<void> reorder(List<ComboModel> combos) async {
    final batch = FirebaseFirestore.instance.batch();
    for (var i = 0; i < combos.length; i++) {
      batch.update(_col.doc(combos[i].id), {'sortOrder': i});
    }
    await batch.commit();
  }
}
