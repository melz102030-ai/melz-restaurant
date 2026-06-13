import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/settings_model.dart';

class SettingsService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const String _docPath = 'settings/restaurant';

  static Stream<RestaurantSettings> streamSettings() {
    return _db.doc(_docPath).snapshots().map((snap) {
      if (!snap.exists || snap.data() == null) {
        return const RestaurantSettings();
      }
      return RestaurantSettings.fromMap(snap.data()!);
    });
  }

  static Future<RestaurantSettings> getSettings() async {
    final snap = await _db.doc(_docPath).get();
    if (!snap.exists || snap.data() == null) {
      return const RestaurantSettings();
    }
    return RestaurantSettings.fromMap(snap.data()!);
  }

  static Future<void> updateSettings(RestaurantSettings settings) async {
    await _db.doc(_docPath).set(settings.toMap(), SetOptions(merge: true));
  }

  static Future<void> toggleRestaurantOpen(bool isOpen) async {
    await _db.doc(_docPath).set({'isOpen': isOpen}, SetOptions(merge: true));
  }
}
