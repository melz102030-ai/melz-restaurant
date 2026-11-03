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
import 'features/admin/admin_screens.dart' deferred as admin;
import 'features/driver/screens/driver_screen.dart' deferred as driver;
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

      // جلسة الضيف (دور "عميل" تُنشأ تلقائياً عند أول طلب) لا تمنع فتح شاشة
      // دخول الموظفين — كانت تُحوِّل رابط الإدارة /a/ لواجهة العميل في أي
      // متصفح سبق أن أُرسل منه طلب
      if (isStaffAuthRoute) {
        return user.role == UserRole.customer ? null : _getHomeRoute(user.role);
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
        builder: (_, __, child) => _adminPage(() => admin.AdminShell(child: child)),
        routes: [
          GoRoute(
            path: '/admin',
            builder: (_, __) => _adminPage(() => admin.AdminDashboard()),
          ),
          GoRoute(
            path: '/admin/menu',
            builder: (_, __) => _adminPage(() => admin.MenuManagementScreen()),
          ),
          GoRoute(
            path: '/admin/orders',
            builder: (_, __) => _adminPage(() => admin.AdminOrdersScreen()),
          ),
          GoRoute(
            path: '/admin/reports',
            builder: (_, __) => _adminPage(() => admin.AdminReportsScreen()),
          ),
          GoRoute(
            path: '/admin/users',
            builder: (_, __) => _adminPage(() => admin.AdminUsersScreen()),
          ),
          GoRoute(
            path: '/admin/settings',
            builder: (_, __) => _adminPage(() => admin.AdminSettingsScreen()),
          ),
          GoRoute(
            path: '/admin/drivers',
            builder: (_, __) => _adminPage(() => admin.AdminDriversScreen()),
          ),
          GoRoute(
            path: '/admin/delivery-zones',
            builder: (_, __) => _adminPage(() => admin.AdminDeliveryZonesScreen()),
          ),
          GoRoute(
            path: '/admin/working-hours',
            builder: (_, __) => _adminPage(() => admin.AdminWorkingHoursScreen()),
          ),
          GoRoute(
            path: '/admin/appearance',
            builder: (_, __) => _adminPage(() => admin.AdminAppearanceScreen()),
          ),
          GoRoute(
            path: '/admin/popup-ads',
            builder: (_, __) => _adminPage(() => admin.AdminPopupAdsScreen()),
          ),
          GoRoute(
            path: '/admin/banners',
            builder: (_, __) => _adminPage(() => admin.AdminBannersScreen()),
          ),
          GoRoute(
            path: '/admin/splash',
            builder: (_, __) => _adminPage(() => admin.AdminSplashScreen()),
          ),
          GoRoute(
            path: '/admin/support',
            builder: (_, __) => _adminPage(() => admin.AdminSupportScreen()),
          ),
          GoRoute(
            path: '/admin/support/:ticketId',
            builder: (_, state) =>
                _adminPage(() => admin.AdminSupportTicketScreen(ticketId: state.pathParameters['ticketId']!)),
          ),
        ],
      ),

      // Driver
      GoRoute(
        path: '/driver',
        builder: (_, __) => _DeferredPage(id: 'driver', load: driver.loadLibrary, builder: () => driver.DriverScreen()),
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

Widget _adminPage(Widget Function() builder) =>
    _DeferredPage(id: 'admin', load: admin.loadLibrary, builder: builder);

// يحمّل حزمة منفصلة عند أول فتح لها ثم يعرض الشاشة مباشرة في المرات التالية.
// فشل التحميل يعني غالباً انقطاع اتصال، أو أن الصفحة مفتوحة من قبل تحديث جديد،
// وإعادة تحميل الصفحة تعالج الحالتين.
class _DeferredPage extends StatefulWidget {
  final String id;
  final Future<void> Function() load;
  final Widget Function() builder;

  const _DeferredPage({required this.id, required this.load, required this.builder});

  static final Set<String> _loaded = {};

  @override
  State<_DeferredPage> createState() => _DeferredPageState();
}

class _DeferredPageState extends State<_DeferredPage> {
  Future<void>? _loading;

  @override
  void initState() {
    super.initState();
    if (!_DeferredPage._loaded.contains(widget.id)) {
      _loading = widget.load().then((_) => _DeferredPage._loaded.add(widget.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_DeferredPage._loaded.contains(widget.id)) return widget.builder();
    return FutureBuilder<void>(
      future: _loading,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('تعذّر تحميل الصفحة'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: reloadPage,
                    child: const Text('إعادة تحميل'),
                  ),
                ],
              ),
            ),
          );
        }
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        return widget.builder();
      },
    );
  }
}

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
