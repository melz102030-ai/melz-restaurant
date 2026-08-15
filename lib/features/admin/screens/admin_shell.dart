import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/auth_provider.dart';

const double _railCollapsedWidth = 64;
const double _railExpandedWidth = 220;
const _railExpandedPrefKey = 'admin_rail_expanded';

typedef _NavItem = ({IconData icon, String label, String route});
typedef _NavSection = ({String? title, List<_NavItem> items});

class AdminShell extends ConsumerStatefulWidget {
  final Widget child;
  const AdminShell({super.key, required this.child});

  @override
  ConsumerState<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends ConsumerState<AdminShell> {
  // مطوية (أيقونات فقط) افتراضياً — يمكن توسيعها من زر الطي/التوسيع، ويُتذكَّر
  // اختيار الأدمن عبر الجلسات بدل العودة للطي الافتراضي في كل مرة
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    _restoreExpanded();
  }

  Future<void> _restoreExpanded() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getBool(_railExpandedPrefKey);
    if (saved != null && mounted) setState(() => _expanded = saved);
  }

  void _setExpanded(bool value) {
    setState(() => _expanded = value);
    SharedPreferences.getInstance().then((p) => p.setBool(_railExpandedPrefKey, value));
  }

  // مجمّعة تحت عناوين أقسام منطقية بدل قائمة مسطّحة واحدة — يظهر عنوان
  // القسم فقط عند التوسيع؛ في الوضع المطوي يفصل بينها خط رفيع فقط
  static const List<_NavSection> _navSections = [
    (title: null, items: [
      (icon: Icons.dashboard_outlined, label: 'لوحة التحكم', route: '/admin'),
    ]),
    (title: 'التشغيل', items: [
      (icon: Icons.receipt_long_outlined, label: 'الطلبات', route: '/admin/orders'),
      (icon: Icons.schedule_outlined, label: 'ساعات العمل', route: '/admin/working-hours'),
    ]),
    (title: 'القائمة', items: [
      (icon: Icons.restaurant_menu_outlined, label: 'القائمة', route: '/admin/menu'),
    ]),
    (title: 'المحتوى الترويجي', items: [
      (icon: Icons.view_carousel_outlined, label: 'البانرات', route: '/admin/banners'),
      (icon: Icons.campaign_outlined, label: 'الإعلانات المنبثقة', route: '/admin/popup-ads'),
      (icon: Icons.auto_awesome_outlined, label: 'كولاج شاشة البداية', route: '/admin/splash'),
    ]),
    (title: 'المظهر', items: [
      (icon: Icons.palette_outlined, label: 'المظهر', route: '/admin/appearance'),
    ]),
    (title: 'الفريق', items: [
      (icon: Icons.people_outline, label: 'الأعضاء', route: '/admin/users'),
      (icon: Icons.delivery_dining_outlined, label: 'المناديب', route: '/admin/drivers'),
    ]),
    (title: 'التوصيل', items: [
      (icon: Icons.map_outlined, label: 'مناطق التوصيل', route: '/admin/delivery-zones'),
    ]),
    (title: 'عام', items: [
      (icon: Icons.bar_chart_outlined, label: 'التقارير', route: '/admin/reports'),
      (icon: Icons.settings_outlined, label: 'الإعدادات', route: '/admin/settings'),
    ]),
  ];

  static List<_NavItem> get _flatItems =>
      _navSections.expand((s) => s.items).toList();

  String _selectedRouteForLocation(String loc) {
    final exact = _flatItems.where((item) => loc == item.route);
    if (exact.isNotEmpty) return exact.first.route;
    // أفضل تطابق جزئي (لأي مسارات فرعية) — أطول مسار مطابق يفوز
    String best = _flatItems.first.route;
    var bestLength = -1;
    for (final item in _flatItems) {
      if (loc.startsWith(item.route) && item.route.length > bestLength) {
        best = item.route;
        bestLength = item.route.length;
      }
    }
    return best;
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider);
    final loc = GoRouterState.of(context).uri.path;
    final selectedRoute = _selectedRouteForLocation(loc);

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
                child: Column(
                  children: [
                    const SizedBox(height: 6),
                    IconButton(
                      icon: Icon(_expanded ? Icons.menu_open : Icons.menu,
                          color: AppColors.purple, size: 22),
                      tooltip: _expanded ? 'طي القائمة' : 'توسيع القائمة',
                      onPressed: () => _setExpanded(!_expanded),
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
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            for (final section in _navSections)
                              _NavSectionWidget(
                                section: section,
                                expanded: _expanded,
                                selectedRoute: selectedRoute,
                                onSelect: (route) => context.go(route),
                              ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16, top: 8),
                      child: IconButton(
                        icon: Icon(Icons.logout, color: AppColors.error, size: 20),
                        tooltip: 'تسجيل الخروج',
                        onPressed: () async {
                          await ref.read(authProvider.notifier).logout();
                          if (context.mounted) context.go('/login');
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavSectionWidget extends StatelessWidget {
  final _NavSection section;
  final bool expanded;
  final String selectedRoute;
  final ValueChanged<String> onSelect;

  const _NavSectionWidget({
    required this.section,
    required this.expanded,
    required this.selectedRoute,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (section.title != null)
          expanded
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      section.title!,
                      style: TextStyle(
                        color: AppColors.textHint,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 18),
                  child: Divider(color: AppColors.surfaceLight, height: 1),
                ),
        for (final item in section.items)
          _NavRow(
            item: item,
            expanded: expanded,
            selected: item.route == selectedRoute,
            onTap: () => onSelect(item.route),
          ),
      ],
    );
  }
}

class _NavRow extends StatelessWidget {
  final _NavItem item;
  final bool expanded;
  final bool selected;
  final VoidCallback onTap;

  const _NavRow({
    required this.item,
    required this.expanded,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.purple : AppColors.textHint;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Container(
            height: 44,
            padding: EdgeInsets.symmetric(horizontal: expanded ? 12 : 0),
            alignment: expanded ? Alignment.centerRight : Alignment.center,
            decoration: BoxDecoration(
              color: selected ? AppColors.purple.withOpacity(0.12) : null,
              borderRadius: BorderRadius.circular(10),
            ),
            child: expanded
                ? Row(
                    children: [
                      Icon(item.icon, color: color, size: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item.label,
                          style: TextStyle(
                            color: selected ? AppColors.textPrimary : AppColors.textSecondary,
                            fontWeight: selected ? FontWeight.w700 : FontWeight.normal,
                            fontSize: 13.5,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  )
                : Tooltip(
                    message: item.label,
                    child: Icon(item.icon, color: color, size: 22),
                  ),
          ),
        ),
      ),
    );
  }
}
