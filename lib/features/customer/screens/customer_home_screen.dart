import 'dart:js' as js;
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/models/category_model.dart';
import '../../../core/models/menu_item_model.dart';
import '../../../core/models/order_model.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/cart_provider.dart';
import '../../../core/providers/settings_provider.dart';
import '../providers/menu_provider.dart';
import '../providers/orders_provider.dart';
import '../widgets/menu_item_card.dart';

class CustomerHomeScreen extends ConsumerStatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  ConsumerState<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends ConsumerState<CustomerHomeScreen> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  final _catBarScroll = ScrollController();
  final Map<String, GlobalKey> _sectionKeys = {};
  String? _highlightedCatId;
  bool _suppressScrollDetection = false;
  bool _showInstallBanner = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // تحقق من توفر زر التثبيت بعد تحميل الصفحة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkInstallPrompt();
      Future.delayed(const Duration(seconds: 4), _checkInstallPrompt);
    });
  }

  void _checkInstallPrompt() {
    try {
      final ready = js.context['_pwaInstallReady'] == true;
      if (mounted && ready != _showInstallBanner) {
        setState(() => _showInstallBanner = ready);
      }
    } catch (_) {}
  }

  Future<void> _triggerInstall() async {
    try {
      js.context.callMethod('showPwaInstallPrompt', []);
    } catch (_) {}
    setState(() => _showInstallBanner = false);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _catBarScroll.dispose();
    super.dispose();
  }

  // Detect which category section is currently in the upper viewport
  void _onScroll() {
    if (_suppressScrollDetection) return;
    if (ref.read(searchQueryProvider).isNotEmpty) return;

    String? visible;
    double best = -double.infinity;

    for (final entry in _sectionKeys.entries) {
      final ctx = entry.value.currentContext;
      if (ctx == null) continue;
      final box = ctx.findRenderObject() as RenderBox?;
      if (box == null) continue;
      final dy = box.localToGlobal(Offset.zero).dy;
      // The section whose header most recently crossed the top zone
      if (dy <= 160 && dy > best) {
        best = dy;
        visible = entry.key;
      }
    }

    if (visible != null && visible != _highlightedCatId) {
      setState(() => _highlightedCatId = visible);
      _scrollCatChipIntoView(visible);
    }
  }

  // Animate the horizontal category bar to show the active chip
  void _scrollCatChipIntoView(String catId) {
    if (!_catBarScroll.hasClients) return;
    final cats = ref.read(categoriesStreamProvider).valueOrNull ?? [];
    final idx = cats.indexWhere((c) => c.id == catId);
    if (idx < 0) return;
    // Estimate chip width + gap; +1 for the "الكل" chip at start
    const chipW = 110.0;
    final offset = (idx + 1) * chipW;
    _catBarScroll.animateTo(
      offset.clamp(0.0, _catBarScroll.position.maxScrollExtent),
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
    );
  }

  // Handle tapping a category chip — scroll the main list to that section
  void _selectCategory(String? catId) {
    setState(() => _highlightedCatId = catId);
    _suppressScrollDetection = true;

    if (catId == null) {
      // "الكل" tapped — scroll to top
      _scrollController
          .animateTo(0,
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeInOut)
          .then((_) => _suppressScrollDetection = false);
      return;
    }

    final key = _sectionKeys[catId];
    if (key?.currentContext != null) {
      Scrollable.ensureVisible(
        key!.currentContext!,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        alignment: 0.0,
      ).then((_) {
        Future.delayed(
            const Duration(milliseconds: 450),
            () => _suppressScrollDetection = false);
      });
    } else {
      _suppressScrollDetection = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider);
    final settingsAsync = ref.watch(settingsStreamProvider);
    final settings = ref.watch(settingsProvider);
    final logoUrl = settingsAsync.valueOrNull?.logoUrl;
    final coverUrl = settingsAsync.valueOrNull?.coverUrl;
    final cartCount = ref.watch(cartItemCountProvider);
    final activeOrder = ref.watch(activeOrderProvider);

    final categoriesAsync = ref.watch(categoriesStreamProvider);
    final allItemsAsync = ref.watch(menuItemsStreamProvider(null));
    final searchQuery = ref.watch(searchQueryProvider);

    final categories = categoriesAsync.valueOrNull ?? [];
    final allItems = allItemsAsync.valueOrNull ?? [];

    // Filter items by search query (flat list, no grouping during search)
    final filteredItems = searchQuery.isEmpty
        ? allItems
        : allItems
            .where((i) =>
                i.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
                i.description.toLowerCase().contains(searchQuery.toLowerCase()))
            .toList();

    final screenWidth = MediaQuery.of(context).size.width;
    final coverImageUrl = coverUrl ?? logoUrl;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: false,
        // مدخل خفي لفريق العمل (مطبخ/إدارة) — أيقونة فقط بلا نص
        leading: IconButton(
          icon: Icon(Icons.admin_panel_settings_outlined,
              size: 20, color: AppColors.textHint.withOpacity(0.35)),
          onPressed: () => context.push('/staff-login'),
        ),
        title: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: settings.effectivelyOpen
                    ? AppColors.success
                    : AppColors.error,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  settings.effectivelyOpen ? 'مفتوح الآن' : 'مغلق حالياً',
                  style: TextStyle(
                    color: settings.effectivelyOpen
                        ? AppColors.success
                        : AppColors.error,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  settings.effectivelyOpen
                      ? 'يغلق ${settings.closeTimeLabel}'
                      : 'يفتح ${settings.openTimeLabel}',
                  style: const TextStyle(
                    color: AppColors.textHint,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          if (user != null)
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: IconButton(
                onPressed: () => context.push('/profile'),
                icon: CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.purpleDark,
                  child: Text(
                    user.name.isNotEmpty ? user.name[0] : 'ع',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  onPressed: () => context.push('/cart'),
                  icon: const Icon(Icons.shopping_bag_outlined,
                      color: AppColors.textPrimary),
                ),
                if (cartCount > 0)
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Container(
                      width: 17,
                      height: 17,
                      decoration: const BoxDecoration(
                        color: AppColors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '$cartCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          // بانر تثبيت التطبيق (PWA)
          if (_showInstallBanner)
            SliverToBoxAdapter(
              child: _InstallBanner(
                onInstall: _triggerInstall,
                onDismiss: () => setState(() => _showInstallBanner = false),
              ),
            ),

          // Active order banner (scrolls away with content)
          if (activeOrder != null)
            SliverToBoxAdapter(
              child: GestureDetector(
                onTap: () => context.push('/track/${activeOrder.id}'),
                child: Container(
                  margin: const EdgeInsets.fromLTRB(12, 10, 12, 0),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.manjawiDark, AppColors.manjawi],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.receipt_long,
                          color: Colors.white, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'طلبك الحالي: ${activeOrder.status.label}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const Icon(Icons.chevron_left,
                          color: Colors.white, size: 20),
                    ],
                  ),
                ),
              ),
            ),

          // Cover / logo banner — scrolls away when user scrolls down
          if (coverImageUrl != null)
            SliverToBoxAdapter(
              child: _WavyCoverBanner(
                child: Image.network(
                  coverImageUrl,
                  width: screenWidth,
                  fit: BoxFit.fitWidth,
                  errorBuilder: (_, __, ___) => Container(
                    height: screenWidth * 0.55,
                    decoration: const BoxDecoration(
                        gradient: AppColors.heroGradient),
                    child: const Center(
                      child: Icon(Icons.restaurant,
                          color: Colors.white, size: 72),
                    ),
                  ),
                ),
              ),
            ),

          // Sticky search bar + category chips — stay at top after cover scrolls away
          SliverPersistentHeader(
            pinned: true,
            delegate: _StickyBarDelegate(
              height: 100,
              child: _SearchCategoryBar(
                searchController: _searchController,
                catBarScroll: _catBarScroll,
                categories: categories,
                highlightedCatId: _highlightedCatId,
                onCategoryTap: _selectCategory,
                onSearchChanged: (v) {
                  ref.read(searchQueryProvider.notifier).state = v;
                  setState(() {});
                },
                onClearSearch: () {
                  _searchController.clear();
                  ref.read(searchQueryProvider.notifier).state = '';
                  setState(() {});
                },
              ),
            ),
          ),

          // ── Menu content ─────────────────────────────────────────────────────
          if (searchQuery.isNotEmpty) ...[
            // Search mode: flat filtered list
            if (filteredItems.isEmpty)
              const SliverToBoxAdapter(child: _EmptyState())
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => Padding(
                      padding: const EdgeInsets.only(bottom: 1),
                      child: MenuItemListCard(item: filteredItems[i]),
                    ),
                    childCount: filteredItems.length,
                  ),
                ),
              ),
          ] else ...[
            // Normal mode: grouped by category with section headers
            for (final cat in categories)
              ..._buildCategorySection(cat, allItems),
            if (allItems.isEmpty)
              const SliverToBoxAdapter(child: _EmptyState()),
          ],

          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),

      bottomNavigationBar: cartCount > 0
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: GestureDetector(
                  onTap: () => context.push('/cart'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 14),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.purple.withValues(alpha: 0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '$cartCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'عرض السلة',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Consumer(builder: (_, ref, __) {
                          final total = ref.watch(cartTotalProvider);
                          return Text(
                            '${total.toStringAsFixed(0)} ${AppStrings.sar}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ),
            )
          : null,
    );
  }

  // Returns a header sliver + items sliver for one category
  List<Widget> _buildCategorySection(
      CategoryModel cat, List<MenuItemModel> allItems) {
    final catItems = allItems.where((i) => i.categoryId == cat.id).toList();
    if (catItems.isEmpty) return const [];

    // Create the GlobalKey once and reuse across rebuilds
    _sectionKeys[cat.id] ??= GlobalKey();

    return [
      SliverToBoxAdapter(
        child: Container(
          key: _sectionKeys[cat.id],
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
          child: Text(
            cat.name,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (_, i) => Padding(
              padding: const EdgeInsets.only(bottom: 1),
              child: MenuItemListCard(item: catItems[i]),
            ),
            childCount: catItems.length,
          ),
        ),
      ),
    ];
  }
}

// ── Sticky search + category bar ──────────────────────────────────────────────

class _SearchCategoryBar extends StatelessWidget {
  final TextEditingController searchController;
  final ScrollController catBarScroll;
  final List<CategoryModel> categories;
  final String? highlightedCatId;
  final void Function(String?) onCategoryTap;
  final void Function(String) onSearchChanged;
  final VoidCallback onClearSearch;

  const _SearchCategoryBar({
    required this.searchController,
    required this.catBarScroll,
    required this.categories,
    required this.highlightedCatId,
    required this.onCategoryTap,
    required this.onSearchChanged,
    required this.onClearSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Search field
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
          child: TextField(
            controller: searchController,
            style:
                const TextStyle(color: AppColors.textPrimary, fontSize: 14),
            decoration: InputDecoration(
              hintText: AppStrings.search,
              hintStyle:
                  const TextStyle(color: AppColors.textHint, fontSize: 14),
              prefixIcon: const Icon(Icons.search,
                  color: AppColors.textHint, size: 20),
              suffixIcon: searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close,
                          color: AppColors.textHint, size: 18),
                      onPressed: onClearSearch,
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              isDense: true,
            ),
            onChanged: onSearchChanged,
          ),
        ),

        // Horizontal category chips
        SizedBox(
          height: 44,
          child: ListView.builder(
            controller: catBarScroll,
            scrollDirection: Axis.horizontal,
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            itemCount: categories.length + 1,
            itemBuilder: (_, i) {
              final isAll = i == 0;
              final isSelected = isAll
                  ? highlightedCatId == null
                  : highlightedCatId == categories[i - 1].id;
              final label =
                  isAll ? AppStrings.allCategories : categories[i - 1].name;
              final catId = isAll ? null : categories[i - 1].id;

              return GestureDetector(
                onTap: () => onCategoryTap(catId),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(left: 8),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.purple
                        : AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : AppColors.textSecondary,
                      fontSize: 13,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ── Sticky header delegate ─────────────────────────────────────────────────────

class _StickyBarDelegate extends SliverPersistentHeaderDelegate {
  final double height;
  final Widget child;

  const _StickyBarDelegate({required this.height, required this.child});

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Material(
      color: AppColors.background,
      elevation: overlapsContent ? 1 : 0,
      shadowColor: AppColors.purple.withValues(alpha: 0.08),
      child: child,
    );
  }

  @override
  bool shouldRebuild(_StickyBarDelegate old) =>
      old.child != child || old.height != height;
}

// ── PWA Install Banner ────────────────────────────────────────────────────────

class _InstallBanner extends StatelessWidget {
  final VoidCallback onInstall;
  final VoidCallback onDismiss;
  const _InstallBanner({required this.onInstall, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 10, 12, 0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4A0080), Color(0xFF800040)],
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.purple.withOpacity(0.35),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.install_mobile, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'حمّل تطبيق Meals',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'أضفه لشاشتك الرئيسية للوصول السريع',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: onInstall,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.purple,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              child: const Text('تحميل',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            ),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: onDismiss,
              child: Icon(Icons.close, color: Colors.white.withOpacity(0.7), size: 18),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Wavy lines header overlay ─────────────────────────────────────────────────

class _WavyCoverBanner extends StatefulWidget {
  final Widget child;
  const _WavyCoverBanner({required this.child});

  @override
  State<_WavyCoverBanner> createState() => _WavyCoverBannerState();
}

class _WavyCoverBannerState extends State<_WavyCoverBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    // 16ms just triggers repaint; real positions come from DateTime.now()
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _ctrl,
            builder: (_, __) => CustomPaint(painter: _WavyLinesPainter()),
          ),
        ),
      ],
    );
  }
}

class _WavyLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final t = DateTime.now().millisecondsSinceEpoch / 1000.0;

    void drawWave(double yFrac, double amp, double freq, double speed,
        double opacity, double strokeW, double dir) {
      final paint = Paint()
        ..color = Colors.white.withOpacity(opacity)
        ..strokeWidth = strokeW
        ..style = PaintingStyle.stroke
        ..isAntiAlias = true;

      final baseY = size.height * yFrac;
      final offset = t * speed * dir;

      final path = Path();
      path.moveTo(0, baseY + amp * math.sin(offset * freq));
      for (double x = 3; x <= size.width; x += 3) {
        path.lineTo(x, baseY + amp * math.sin((x + offset) * freq));
      }
      canvas.drawPath(path, paint);
    }

    drawWave(0.10, 13, 0.011, 58,  0.18, 1.8,  1);
    drawWave(0.23,  8, 0.015, 72,  0.13, 1.2, -1);
    drawWave(0.37, 15, 0.009, 44,  0.21, 2.0,  1);
    drawWave(0.50, 10, 0.013, 66,  0.15, 1.5, -1);
    drawWave(0.63, 12, 0.010, 51,  0.17, 1.8,  1);
    drawWave(0.77,  7, 0.017, 78,  0.12, 1.2, -1);
    drawWave(0.90, 14, 0.012, 62,  0.20, 2.0,  1);
  }

  @override
  bool shouldRepaint(_WavyLinesPainter old) => true;
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 60),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off, size: 48, color: AppColors.textHint),
          SizedBox(height: 12),
          Text(
            AppStrings.noItemsFound,
            style: TextStyle(color: AppColors.textHint, fontSize: 15),
          ),
        ],
      ),
    );
  }
}
