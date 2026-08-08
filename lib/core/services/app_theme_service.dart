import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_theme_settings.dart';

class AppThemeService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const String _docPath = 'settings/theme';
  // المظهر "الافتراضي" الذي يحدّده الأدمن بنفسه (منفصل عن المظهر الحالي المطبَّق)
  static const String _defaultDocPath = 'settings/themeDefault';

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

  // يستبدل المظهر الحالي بالكامل (بدل الدمج) حتى تُمسح الحقول غير المرسلة إلى قيمها الجديدة بدقة
  static Future<void> updateTheme(AppThemeSettings settings) async {
    await _db.doc(_docPath).set(settings.toMap());
  }

  static Future<AppThemeSettings?> getDefaultTheme() async {
    final snap = await _db.doc(_defaultDocPath).get();
    if (!snap.exists || snap.data() == null) return null;
    return AppThemeSettings.fromMap(snap.data()!);
  }

  // تعيين مظهر كإفتراضي: يحل محل أي إفتراضي سابق بالكامل
  static Future<void> setDefaultTheme(AppThemeSettings settings) async {
    await _db.doc(_defaultDocPath).set(settings.toMap());
  }
}
