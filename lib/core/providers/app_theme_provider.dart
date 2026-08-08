import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_theme_settings.dart';
import '../services/app_theme_service.dart';

final appThemeStreamProvider = StreamProvider<AppThemeSettings>((ref) {
  return AppThemeService.streamTheme();
});

final appThemeProvider = Provider<AppThemeSettings>((ref) {
  return ref.watch(appThemeStreamProvider).maybeWhen(
        data: (t) => t,
        orElse: () => const AppThemeSettings(),
      );
});
