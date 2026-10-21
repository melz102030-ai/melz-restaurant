import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/constants/app_colors.dart';
import 'core/models/user_model.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/app_theme_provider.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/screens/staff_login_screen.dart';
import 'features/kitchen/screens/kitchen_screen.dart';
import 'features/kitchen/screens/kitchen_availability_screen.dart';

/// نسخة خفيفة جداً من التطبيق — شاشة المطبخ فقط، بلا أي شيء آخر (عميل،
/// أدمن، مندوب، لعبة، خرائط). مخصَّصة لأجهزة ضعيفة الإمكانيات (كأجهزة
/// الكاشير المحمولة برام محدودة جداً) حيث تطبيق الويب الكامل ثقيل جداً.
/// نفس الميزات تماماً لشاشة المطبخ نفسها — فقط بدون تحميل بقية التطبيق.
/// راجع lib/main_kitchen.dart لنقطة الدخول المقابلة لهذا الملف.

final _rootKey = GlobalKey<NavigatorState>();

class _AuthRefreshNotifier extends ChangeNotifier {
  _AuthRefreshNotifier(Ref ref) {
    ref.listen<UserModel?>(authProvider, (_, __) => notifyListeners());
  }
}

final _kitchenRouterProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = _AuthRefreshNotifier(ref);
  ref.onDispose(refreshNotifier.dispose);

  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: '/kitchen',
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final user = ref.read(authProvider);
      final loc = state.matchedLocation;
      final isAuthRoute = loc == '/login' || loc == '/staff-login';

      // غير مسجَّل دخول (أو خرج للتو): يُحوَّل دائماً لشاشة دخول الموظفين،
      // بغض النظر عن المسار المطلوب (حتى لو '/login' القادم من منطق
      // تسجيل الخروج المشترك في kitchen_screen.dart)
      if (user == null) {
        return loc == '/staff-login' ? null : '/staff-login';
      }

      // هذه النسخة مخصَّصة للمطبخ حصراً — أي دور آخر (حتى لو حساب صحيح)
      // لا مكان له هنا، يُعاد لشاشة الدخول بدل عرض خطأ "صفحة غير موجودة"
      if (user.role != UserRole.kitchen) {
        return '/staff-login';
      }

      if (isAuthRoute) return '/kitchen';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const StaffLoginScreen()),
      GoRoute(path: '/staff-login', builder: (_, __) => const StaffLoginScreen()),
      GoRoute(path: '/kitchen', builder: (_, __) => const KitchenScreen()),
      GoRoute(
        path: '/kitchen/availability',
        builder: (_, __) => const KitchenAvailabilityScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text('صفحة غير موجودة: ${state.error}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/kitchen'),
              child: const Text('العودة'),
            ),
          ],
        ),
      ),
    ),
  );
});

class MelzKitchenApp extends ConsumerWidget {
  const MelzKitchenApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSettings = ref.watch(appThemeProvider);
    final router = ref.watch(_kitchenRouterProvider);

    AppColors.applyTheme(themeSettings);

    return MaterialApp.router(
      key: ValueKey(themeSettings.toMap().toString()),
      title: 'مطبخ Meals',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.buildTheme(themeSettings),
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: router,
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
    );
  }
}
