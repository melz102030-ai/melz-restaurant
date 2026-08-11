import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/auth_provider.dart';

const double _railCollapsedWidth = 64;
const double _railExpandedWidth = 220;

class AdminShell extends ConsumerStatefulWidget {
  final Widget child;
  const AdminShell({super.key, required this.child});

  @override
  ConsumerState<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends ConsumerState<AdminShell> {
  // مطوية (أيقونات فقط) افتراضياً — يمكن توسيعها من زر الطي/التوسيع
  bool _expanded = false;

  static const _navItems = [
    (icon: Icons.dashboard_outlined, label: 'لوحة التحكم', route: '/admin'),
    (icon: Icons.restaurant_menu_outlined, label: 'القائمة', route: '/admin/menu'),
    (icon: Icons.receipt_long_outlined, label: 'الطلبات', route: '/admin/orders'),
    (icon: Icons.bar_chart_outlined, label: 'التقارير', route: '/admin/reports'),
    (icon: Icons.people_outline, label: 'الأعضاء', route: '/admin/users'),
    (icon: Icons.delivery_dining_outlined, label: 'المناديب', route: '/admin/drivers'),
    (icon: Icons.map_outlined, label: 'مناطق التوصيل', route: '/admin/delivery-zones'),
    (icon: Icons.palette_outlined, label: 'المظهر', route: '/admin/appearance'),
    (icon: Icons.settings_outlined, label: 'الإعدادات', route: '/admin/settings'),
  ];

  int _selectedIndexForLocation(String loc) {
    final exact = _navItems.indexWhere((item) => loc == item.route);
    if (exact != -1) return exact;
    // أفضل تطابق جزئي (لأي مسارات فرعية مستقبلية) — أطول مسار مطابق يفوز
    var bestIndex = 0;
    var bestLength = -1;
    for (var i = 0; i < _navItems.length; i++) {
      final route = _navItems[i].route;
      if (loc.startsWith(route) && route.length > bestLength) {
        bestIndex = i;
        bestLength = route.length;
      }
    }
    return bestIndex;
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider);
    final loc = GoRouterState.of(context).uri.path;
    final selectedIndex = _selectedIndexForLocation(loc);

    return Scaffold(
      body: Stack(
        children: [
          // المحتوى: يترك مساحة ثابتة بعرض اللوحة المطوية فقط، فلا يتحرك عند التوسيع
          Positioned(
            top: 0,
            bottom: 0,
            left: _railCollapsedWidth,
            right: 0,
            child: widget.child,
          ),

          // اللوحة الجانبية: تطفو فوق المحتوى (تغطيه) بدل أن تدفعه عند التوسيع
          Positioned(
            top: 0,
            bottom: 0,
            left: 0,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              width: _expanded ? _railExpandedWidth : _railCollapsedWidth,
              child: Material(
                color: AppColors.surface,
                elevation: _expanded ? 6 : 0,
                shadowColor: Colors.black.withOpacity(0.15),
                child: NavigationRail(
                  extended: _expanded,
                  backgroundColor: Colors.transparent,
                  minWidth: _railCollapsedWidth,
                  minExtendedWidth: _railExpandedWidth,
                  selectedIndex: selectedIndex,
                  useIndicator: true,
                  indicatorColor: AppColors.purple.withOpacity(0.12),
                  indicatorShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  onDestinationSelected: (i) => context.go(_navItems[i].route),
                  leading: Column(
                    children: [
                      const SizedBox(height: 6),
                      IconButton(
                        icon: Icon(_expanded ? Icons.menu_open : Icons.menu,
                            color: AppColors.purple, size: 22),
                        tooltip: _expanded ? 'طي القائمة' : 'توسيع القائمة',
                        onPressed: () => setState(() => _expanded = !_expanded),
                      ),
                      if (_expanded) ...[
                        const SizedBox(height: 4),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            user?.name ?? 'الإدارة',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                    ],
                  ),
                  trailing: Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: IconButton(
                          icon: Icon(Icons.logout, color: AppColors.error, size: 20),
                          tooltip: 'تسجيل الخروج',
                          onPressed: () async {
                            await ref.read(authProvider.notifier).logout();
                            if (context.mounted) context.go('/login');
                          },
                        ),
                      ),
                    ),
                  ),
                  destinations: _navItems
                      .map((item) => NavigationRailDestination(
                            icon: Icon(item.icon, color: AppColors.textHint, size: 22),
                            selectedIcon: Icon(item.icon, color: AppColors.purple, size: 22),
                            label: Text(item.label),
                          ))
                      .toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
