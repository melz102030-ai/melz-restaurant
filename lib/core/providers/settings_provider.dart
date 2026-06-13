import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/settings_model.dart';
import '../services/settings_service.dart';

final settingsStreamProvider = StreamProvider<RestaurantSettings>((ref) {
  return SettingsService.streamSettings();
});

final settingsProvider = Provider<RestaurantSettings>((ref) {
  return ref.watch(settingsStreamProvider).maybeWhen(
        data: (s) => s,
        orElse: () => const RestaurantSettings(),
      );
});
