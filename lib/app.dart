import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/constants/app_colors.dart';
import 'core/models/user_model.dart';
import 'core/providers/auth_provider.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/otp_screen.dart';
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
import 'features/kitchen/screens/kitchen_screen.dart';

final _rootKey = GlobalKey<NavigatorState>();
final _adminKey = GlobalKey<NavigatorState>();

GoRouter _buildRouter(UserModel? user) {
  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: _getInitialRoute(user),
    redirect: (context, state) {
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/otp' ||
          state.matchedLocation == '/staff-login';

      if (user == null && !isAuthRoute) {
        return '/login';
      }

      if (user != null && isAuthRoute) {
        return _getHomeRoute(user.role);
      }

      // Role-based redirect
      if (user != null && !isAuthRoute) {
        final loc = state.matchedLocation;
        if (user.role == UserRole.admin && !loc.startsWith('/admin')) {
          if (!loc.startsWith('/home') && !loc.startsWith('/cart') &&
              !loc.startsWith('/track') && !loc.startsWith('/profile')) {
            return '/admin';
          }
        }
        if (user.role == UserRole.kitchen && !loc.startsWith('/kitchen')) {
          return '/kitchen';
        }
      }

      return null;
    },
    routes: [
      // Auth
      GoRoute(
        path: '/login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: '/otp',
        builder: (_, state) => OtpScreen(phone: state.extra as String),
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
        ],
      ),

      // Kitchen
      GoRoute(
        path: '/kitchen',
        builder: (_, __) => const KitchenScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.error),
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
  if (user == null) return '/login';
  return _getHomeRoute(user.role);
}

String _getHomeRoute(UserRole role) {
  switch (role) {
    case UserRole.admin:
      return '/admin';
    case UserRole.kitchen:
      return '/kitchen';
    case UserRole.customer:
      return '/home';
  }
}

class MelzApp extends ConsumerWidget {
  const MelzApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);

    return MaterialApp.router(
      title: 'ميلز',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
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
