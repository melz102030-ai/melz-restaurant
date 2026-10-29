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
import 'features/customer/screens/customer_home_screen.dart';
import 'features/customer/screens/cart_screen.dart';
import 'features/customer/screens/item_detail_screen.dart';
import 'features/customer/screens/order_tracking_screen.dart';
import 'features/customer/screens/order_history_screen.dart';
import 'features/customer/screens/profile_screen.dart';
import 'features/customer/screens/support_screen.dart';
import 'features/customer/screens/support_ticket_screen.dart';
import 'features/admin/screens/admin_shell.dart';
import 'features/admin/screens/admin_dashboard.dart';
import 'features/admin/screens/menu_management_screen.dart';
import 'features/admin/screens/admin_orders_screen.dart';
import 'features/admin/screens/admin_reports_screen.dart';
import 'features/admin/screens/admin_settings_screen.dart';
import 'features/admin/screens/admin_users_screen.dart';
import 'features/admin/screens/admin_drivers_screen.dart';
import 'features/admin/screens/admin_delivery_zones_screen.dart';
import 'features/admin/screens/admin_working_hours_screen.dart';
import 'features/admin/screens/admin_appearance_screen.dart';
import 'features/admin/screens/admin_popup_ads_screen.dart';
import 'features/admin/screens/admin_banners_screen.dart';
import 'features/admin/screens/admin_splash_screen.dart';
import 'features/admin/screens/admin_support_screen.dart';
import 'features/admin/screens/admin_support_ticket_screen.dart';
import 'features/driver/screens/driver_screen.dart';
import 'shared/utils/kitchen_redirect.dart';
import 'features/game/heart_dodge_game_screen.dart';

final _rootKey = GlobalKey<NavigatorState>();
final _adminKey = GlobalKey<NavigatorState>();

// يُعيد تشغيل تقييم redirect عند تغيّر حالة تسجيل الدخول فعلياً، بدل إعادة
// بناء GoRouter بالكامل من الصفر في كل build — إعادة البناء كانت تصفّر مكدّس
// التنقّل بالكامل وتعيد المستخدم إلى الصفحة الرئيسية لدوره عند أي تغيّر طفيف
// وغير متعلّق بالتنقّل (كإعادة بناء المزوّد أثناء عملية غير مرتبطة إطلاقاً)
class _AuthRefreshNotifier extends ChangeNotifier {
  _AuthRefreshNotifier(Ref ref) {
    ref.listen<UserModel?>(authProvider, (_, __) => notifyListeners());
  }
}

final _routerProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = _AuthRefreshNotifier(ref);
  ref.onDispose(refreshNotifier.dispose);

  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: _getInitialRoute(ref.read(authProvider)),
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final user = ref.read(authProvider);
      final loc = state.matchedLocation;
      final isStaffAuthRoute = loc == '/staff-login';
      final isAdminRoute = loc.startsWith('/admin');
      final isDriverRoute = loc.startsWith('/driver');
      // لا يوجد نظام تسجيل دخول للعملاء إطلاقاً — كل مسارات العميل متاحة
      // دائماً سواء زائراً أو بجلسة ضيف (تُنشأ تلقائياً فقط لحظة إرسال أول
      // طلب)؛ مفيدة أيضاً لأي موظف (أدمن/مندوب) يفتح رابط تتبع أو ملفه الشخصي
      final isSharedCustomerRoute = loc.startsWith('/home') ||
          loc.startsWith('/cart') ||
          loc.startsWith('/item') ||
          loc.startsWith('/track') ||
          loc.startsWith('/profile') ||
          loc.startsWith('/orders') ||
          loc.startsWith('/support') ||
          loc.startsWith('/game');

      if (user == null) {
        if (isStaffAuthRoute || isSharedCustomerRoute) return null;
        if (isAdminRoute || isDriverRoute) return '/staff-login';
        return '/home';
      }

      // دور "مطبخ" لا مكان له داخل تطبيق فلاتر إطلاقاً — تحويل فوري خارجي
      // لنسخة kitchen-lite الخفيفة بغض النظر عن المسار الحالي
      if (user.role == UserRole.kitchen) {
        redirectToKitchenLite();
        return null;
      }

      if (isStaffAuthRoute) {
        return _getHomeRoute(user.role);
      }

      // Role-based redirect — كل دور يُحصر ضمن قسمه الخاص، إلا المسارات
      // المشتركة أعلاه
      if (user.role == UserRole.admin && !isAdminRoute && !isSharedCustomerRoute) {
        return '/admin';
      }
      if (user.role == UserRole.driver && !isDriverRoute && !isSharedCustomerRoute) {
        return '/driver';
      }

      return null;
    },
    routes: [
      // Auth
      GoRoute(
        path: '/staff-login',
        builder: (_, __) => const StaffLoginScreen(),
      ),

      // Customer
      GoRoute(
        path: '/home',
        builder: (_, __) => const CustomerHomeScreen(),
      ),
      GoRoute(
        path: '/cart',
        builder: (_, __) => const CartScreen(),
      ),
      GoRoute(
        path: '/item/:itemId',
        builder: (_, state) =>
            ItemDetailScreen(itemId: state.pathParameters['itemId']!),
      ),
      GoRoute(
        path: '/track/:orderId',
        builder: (_, state) =>
            OrderTrackingScreen(orderId: state.pathParameters['orderId']!),
      ),
      GoRoute(
        path: '/orders',
        builder: (_, __) => const OrderHistoryScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (_, __) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/support',
        builder: (_, __) => const SupportScreen(),
      ),
      GoRoute(
        path: '/support/:ticketId',
        builder: (_, state) =>
            SupportTicketScreen(ticketId: state.pathParameters['ticketId']!),
      ),
      GoRoute(
        path: '/game/:orderId',
        builder: (_, state) =>
            HeartDodgeGameScreen(orderId: state.pathParameters['orderId']!),
      ),

      // Admin - Shell route with sidebar
      ShellRoute(
        navigatorKey: _adminKey,
        builder: (_, __, child) => AdminShell(child: child),
        routes: [
          GoRoute(
            path: '/admin',
            builder: (_, __) => const AdminDashboard(),
          ),
          GoRoute(
            path: '/admin/menu',
            builder: (_, __) => const MenuManagementScreen(),
          ),
          GoRoute(
            path: '/admin/orders',
            builder: (_, __) => const AdminOrdersScreen(),
          ),
          GoRoute(
            path: '/admin/reports',
            builder: (_, __) => const AdminReportsScreen(),
          ),
          GoRoute(
            path: '/admin/users',
            builder: (_, __) => const AdminUsersScreen(),
          ),
          GoRoute(
            path: '/admin/settings',
            builder: (_, __) => const AdminSettingsScreen(),
          ),
          GoRoute(
            path: '/admin/drivers',
            builder: (_, __) => const AdminDriversScreen(),
          ),
          GoRoute(
            path: '/admin/delivery-zones',
            builder: (_, __) => const AdminDeliveryZonesScreen(),
          ),
          GoRoute(
            path: '/admin/working-hours',
            builder: (_, __) => const AdminWorkingHoursScreen(),
          ),
          GoRoute(
            path: '/admin/appearance',
            builder: (_, __) => const AdminAppearanceScreen(),
          ),
          GoRoute(
            path: '/admin/popup-ads',
            builder: (_, __) => const AdminPopupAdsScreen(),
          ),
          GoRoute(
            path: '/admin/banners',
            builder: (_, __) => const AdminBannersScreen(),
          ),
          GoRoute(
            path: '/admin/splash',
            builder: (_, __) => const AdminSplashScreen(),
          ),
          GoRoute(
            path: '/admin/support',
            builder: (_, __) => const AdminSupportScreen(),
          ),
          GoRoute(
            path: '/admin/support/:ticketId',
            builder: (_, state) =>
                AdminSupportTicketScreen(ticketId: state.pathParameters['ticketId']!),
          ),
        ],
      ),

      // Driver
      GoRoute(
        path: '/driver',
        builder: (_, __) => const DriverScreen(),
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
              onPressed: () => context.go('/home'),
              child: const Text('العودة'),
            ),
          ],
        ),
      ),
    ),
  );
});

String _getInitialRoute(UserModel? user) {
  // الرابط الجذر "/" يُظهر دائماً واجهة العميل — الأدمن يُوجَّه لـ /admin
  // فقط بعد تسجيل الدخول عبر /staff-login، لا عند فتح الموقع مباشرة
  if (user?.role == UserRole.kitchen) {
    redirectToKitchenLite();
  }
  return '/home';
}

String _getHomeRoute(UserRole role) {
  switch (role) {
    case UserRole.admin:
      return '/admin';
    case UserRole.kitchen:
      return '/home'; // يُعاد توجيهه فعلياً عبر redirectToKitchenLite أعلاه
    case UserRole.driver:
      return '/driver';
    case UserRole.customer:
      return '/home';
  }
}

class MelzApp extends ConsumerWidget {
  const MelzApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSettings = ref.watch(appThemeProvider);
    final router = ref.watch(_routerProvider);

    // يحدّث القيم الساكنة في AppColors من إعدادات الأدمن قبل أي رسم للواجهة
    AppColors.applyTheme(themeSettings);

    return MaterialApp.router(
      // مفتاح مرتبط بإعدادات المظهر فقط (وليس بالمصادقة أو التنقّل) — أي تغيير
      // من لوحة الأدمن يعيد بناء الشجرة البصرية فوراً حتى تنعكس الألوان/الخط
      // على كل الواجهات دفعة واحدة، لكن كائن GoRouter نفسه (routerConfig)
      // يبقى نفس الكائن المستقر عبر _routerProvider فلا يُفقَد مكدّس التنقّل
      key: ValueKey(themeSettings.toMap().toString()),
      title: 'Meals',
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
