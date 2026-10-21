import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'firebase_options.dart';
import 'app_kitchen.dart';

/// نقطة دخول منفصلة تماماً تُبنى كحزمة ويب خاصة بها (بدون أي علاقة بحزمة
/// main.dart الكاملة) — راجع lib/app_kitchen.dart. تُبنى عبر:
///   flutter build web -t lib/main_kitchen.dart -o build/kitchen --release
/// وتُنشر على مسار/نطاق فرعي منفصل (راجع .github/workflows/build-web.yml)
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await initializeDateFormatting('ar', null);

  runApp(
    const ProviderScope(
      child: MelzKitchenApp(),
    ),
  );
}
