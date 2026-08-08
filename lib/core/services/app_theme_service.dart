import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_theme_settings.dart';

class AppThemeService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const String _docPath = 'settings/theme';

  static Stream<AppThemeSettings> streamTheme() {
    return _db.doc(_docPath).snapshots().map((snap) {
      if (!snap.exists || snap.data() == null) {
        return const AppThemeSettings();
      }
      return AppThemeSettings.fromMap(snap.data()!);
    });
  }

  static Future<AppThemeSettings> getTheme() async {
    final snap = await _db.doc(_docPath).get();
    if (!snap.exists || snap.data() == null) {
      return const AppThemeSettings();
    }
    return AppThemeSettings.fromMap(snap.data()!);
  }

  static Future<void> updateTheme(AppThemeSettings settings) async {
    await _db.doc(_docPath).set(settings.toMap(), SetOptions(merge: true));
  }
}
