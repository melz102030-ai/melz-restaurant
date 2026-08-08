import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/auth_provider.dart';

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
    (icon: Icons.dashboard, label: 'لوحة التحكم', route: '/admin'),
    (icon: Icons.restaurant_menu, label: 'القائمة', route: '/admin/menu'),
    (icon: Icons.receipt_long, label: 'الطلبات', route: '/admin/orders'),
    (icon: Icons.bar_chart, label: 'التقارير', route: '/admin/reports'),
    (icon: Icons.people, label: 'الأعضاء', route: '/admin/users'),
    (icon: Icons.delivery_dining, label: 'المناديب', route: '/admin/drivers'),
    (icon: Icons.map_outlined, label: 'مناطق التوصيل', route: '/admin/delivery-zones'),
    (icon: Icons.palette_outlined, label: 'المظهر', route: '/admin/appearance'),
    (icon: Icons.settings, label: 'الإعدادات', route: '/admin/settings'),
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
      body: Row(
        children: [
          NavigationRail(
            extended: _expanded,
            backgroundColor: AppColors.surface,
            minWidth: 64,
            minExtendedWidth: 220,
            selectedIndex: selectedIndex,
            onDestinationSelected: (i) => context.go(_navItems[i].route),
            leading: Column(
              children: [
                const SizedBox(height: 8),
                IconButton(
                  icon: Icon(_expanded ? Icons.menu_open : Icons.menu, color: AppColors.purple),
                  tooltip: _expanded ? 'طي القائمة' : 'توسيع القائمة',
                  onPressed: () => setState(() => _expanded = !_expanded),
                ),
                if (_expanded) ...[
                  const SizedBox(height: 6),
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
                const SizedBox(height: 12),
              ],
            ),
            trailing: Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: IconButton(
                    icon: Icon(Icons.logout, color: AppColors.error),
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
                      icon: Icon(item.icon, color: AppColors.textHint),
                      selectedIcon: Icon(item.icon, color: AppColors.purple),
                      label: Text(item.label),
                    ))
                .toList(),
          ),
          VerticalDivider(width: 1, color: AppColors.surfaceLight),
          Expanded(child: widget.child),
        ],
      ),
    );
  }
}
