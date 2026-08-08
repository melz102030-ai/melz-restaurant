import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/constants/app_colors.dart';
import 'core/models/user_model.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/app_theme_provider.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/staff_login_screen.dart';
import 'features/customer/screens/customer_home_screen.dart';
import 'features/customer/screens/cart_screen.dart';
import 'features/customer/screens/order_tracking_screen.dart';
import 'features/customer/screens/profile_screen.dart';
import 'features/admin/screens/admin_shell.dart';
import 'features/admin/screens/admin_dashboard.dart';
import 'features/admin/screens/menu_management_screen.dart';
import 'features/admin/screens/admin_orders_screen.dart';
import 'features/admin/screens/admin_reports_screen.dart';
import 'features/admin/screens/admin_settings_screen.dart';
import 'features/admin/screens/admin_users_screen.dart';
import 'features/admin/screens/admin_drivers_screen.dart';
import 'features/admin/screens/admin_delivery_zones_screen.dart';
import 'features/admin/screens/admin_appearance_screen.dart';
import 'features/kitchen/screens/kitchen_screen.dart';
import 'features/kitchen/screens/kitchen_availability_screen.dart';
import 'features/driver/screens/driver_screen.dart';
import 'features/game/heart_dodge_game_screen.dart';

final _rootKey = GlobalKey<NavigatorState>();
final _adminKey = GlobalKey<NavigatorState>();

GoRouter _buildRouter(UserModel? user) {
  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: _getInitialRoute(user),
    redirect: (context, state) {
      final loc = state.matchedLocation;
      final isAuthRoute = loc == '/login' || loc == '/staff-login';
      final isGuestAllowedRoute = loc == '/home' || loc == '/cart';
      final isAdminRoute = loc.startsWith('/admin');
      final isKitchenRoute = loc.startsWith('/kitchen');
      final isDriverRoute = loc.startsWith('/driver');

      // زوار بلا تسجيل دخول: يدخلون القائمة والسلة مباشرة للمعاينة والطلب
      if (user == null) {
        if (isAuthRoute || isGuestAllowedRoute) return null;
        if (isAdminRoute || isKitchenRoute || isDriverRoute) return '/staff-login';
        return '/login'; // مثل /profile أو /track تتطلب تسجيل دخول
      }

      if (isAuthRoute) {
        return _getHomeRoute(user.role);
      }

      // Role-based redirect
      if (user.role == UserRole.admin && !isAdminRoute) {
        if (!loc.startsWith('/home') && !loc.startsWith('/cart') &&
            !loc.startsWith('/track') && !loc.startsWith('/profile')) {
          return '/admin';
        }
      }
      if (user.role == UserRole.kitchen && !isKitchenRoute) {
        return '/kitchen';
      }
      if (user.role == UserRole.driver && !isDriverRoute) {
        return '/driver';
      }

      return null;
    },
    routes: [
      // Auth
      GoRoute(
        path: '/login',
        builder: (_, state) => LoginScreen(returnTo: state.extra as String?),
      ),
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
        path: '/track/:orderId',
        builder: (_, state) =>
            OrderTrackingScreen(orderId: state.pathParameters['orderId']!),
      ),
      GoRoute(
        path: '/profile',
        builder: (_, __) => const ProfileScreen(),
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
            path: '/admin/appearance',
            builder: (_, __) => const AdminAppearanceScreen(),
          ),
        ],
      ),

      // Kitchen
      GoRoute(
        path: '/kitchen',
        builder: (_, __) => const KitchenScreen(),
      ),
      GoRoute(
        path: '/kitchen/availability',
        builder: (_, __) => const KitchenAvailabilityScreen(),
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
              onPressed: () => context.go('/login'),
              child: const Text('العودة'),
            ),
          ],
        ),
      ),
    ),
  );
}

String _getInitialRoute(UserModel? user) {
  if (user == null) return '/home';
  return _getHomeRoute(user.role);
}

String _getHomeRoute(UserRole role) {
  switch (role) {
    case UserRole.admin:
      return '/admin';
    case UserRole.kitchen:
      return '/kitchen';
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
    final user = ref.watch(authProvider);
    final themeSettings = ref.watch(appThemeProvider);

    // يحدّث القيم الساكنة في AppColors من إعدادات الأدمن قبل أي رسم للواجهة
    AppColors.applyTheme(themeSettings);

    return MaterialApp.router(
      // مفتاح مرتبط بإعدادات المظهر: أي تغيير من لوحة الأدمن يعيد بناء الشجرة
      // بالكامل فوراً حتى تنعكس الألوان/الخط على كل الواجهات دفعة واحدة
      key: ValueKey(themeSettings.toMap().toString()),
      title: 'Meals',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.buildTheme(themeSettings),
      routerConfig: _buildRouter(user),
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
    );
  }
}
