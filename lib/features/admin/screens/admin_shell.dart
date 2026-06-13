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
  int _selectedIndex = 0;

  static const _navItems = [
    (icon: Icons.dashboard, label: 'لوحة التحكم', route: '/admin'),
    (icon: Icons.restaurant_menu, label: 'القائمة', route: '/admin/menu'),
    (icon: Icons.receipt_long, label: 'الطلبات', route: '/admin/orders'),
    (icon: Icons.bar_chart, label: 'التقارير', route: '/admin/reports'),
    (icon: Icons.people, label: 'المستخدمون', route: '/admin/users'),
    (icon: Icons.settings, label: 'الإعدادات', route: '/admin/settings'),
  ];

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 768;
    final user = ref.watch(authProvider);

    if (isWide) {
      return Scaffold(
        body: Row(
          children: [
            // Sidebar
            Container(
              width: 220,
              color: AppColors.surface,
              child: Column(
                children: [
                  // Logo
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
                    decoration: const BoxDecoration(
                      gradient: AppColors.primaryGradient,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'ميلز',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user?.name ?? 'الإدارة',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView(
                      children: _navItems.asMap().entries.map((e) {
                        final i = e.key;
                        final item = e.value;
                        final isSelected = _selectedIndex == i;
                        return ListTile(
                          leading: Icon(
                            item.icon,
                            color: isSelected ? AppColors.purple : AppColors.textHint,
                          ),
                          title: Text(
                            item.label,
                            style: TextStyle(
                              color: isSelected ? AppColors.purple : AppColors.textSecondary,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          selected: isSelected,
                          selectedTileColor: AppColors.purple.withOpacity(0.1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          onTap: () {
                            setState(() => _selectedIndex = i);
                            context.go(item.route);
                          },
                        );
                      }).toList(),
                    ),
                  ),
                  // Logout
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: ListTile(
                      leading: const Icon(Icons.logout, color: AppColors.error),
                      title: const Text(
                        'تسجيل الخروج',
                        style: TextStyle(color: AppColors.error),
                      ),
                      onTap: () async {
                        await ref.read(authProvider.notifier).logout();
                        if (context.mounted) context.go('/login');
                      },
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(child: widget.child),
          ],
        ),
      );
    }

    // Mobile bottom nav
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.purple.withOpacity(0.2),
        onDestinationSelected: (i) {
          setState(() => _selectedIndex = i);
          context.go(_navItems[i].route);
        },
        destinations: _navItems.map((item) {
          return NavigationDestination(
            icon: Icon(item.icon),
            label: item.label,
          );
        }).toList(),
      ),
    );
  }
}
