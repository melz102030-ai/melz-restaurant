import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'firebase_options.dart';
import 'app.dart';
import 'core/constants/app_config.dart';
import 'core/providers/auth_provider.dart';
import 'core/services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (kE2E) {
    FirebaseFirestore.instance.useFirestoreEmulator('127.0.0.1', 8080);
    await FirebaseAuth.instance.useAuthEmulator('127.0.0.1', 9099);
    SemanticsBinding.instance.ensureSemantics();
  }

  await initializeDateFormatting('ar', null);

  // نُحمِّل جلسة المستخدم قبل بدء التطبيق تماماً حتى يعرف GoRouter
  // المسار الصحيح من اللحظة الأولى — بدون هذا كان authProvider يبدأ
  // بـ null فيعرض GoRouter الشاشة الخاطئة ريثما تكتمل استعادة الجلسة
  final initialUser = await AuthService.loadSession();

  // زوار بلا جلسة: نوقّع Firebase مجهولاً حتى تعمل Firestore rules
  if (initialUser == null && FirebaseAuth.instance.currentUser == null) {
    try {
      await FirebaseAuth.instance.signInAnonymously();
    } catch (_) {}
  }

  runApp(
    ProviderScope(
      overrides: [
        authProvider.overrideWith((_) => AuthNotifier(initialUser)),
      ],
      child: const MelzApp(),
    ),
  );
}
