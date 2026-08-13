import 'dart:async';
import 'dart:js' as js;
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/models/category_model.dart';
import '../../../core/models/menu_item_model.dart';
import '../../../core/models/order_model.dart';
import '../../../core/models/promo_banner_model.dart';
import '../../../core/models/user_model.dart';
import '../../../core/models/app_theme_settings.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/cart_provider.dart';
import '../../../core/providers/order_type_provider.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../core/providers/app_theme_provider.dart';
import '../../../core/services/auth_service.dart';
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
  final _searchFocusNode = FocusNode();
  final _catBarScroll = ScrollController();
  final Map<String, GlobalKey> _sectionKeys = {};
  String? _highlightedCatId;
  bool _suppressScrollDetection = false;
  bool _showInstallBanner = false;
  bool _isIosInstallable = false;
  bool _installBannerDismissed = false;
  UserRole? _quickLoginRole;

  Future<void> _quickLogin(UserRole role) async {
    if (_quickLoginRole != null) return;
    setState(() => _quickLoginRole = role);
    try {
      final user = await AuthService.quickPreviewLogin(role);
      await ref.read(authProvider.notifier).login(user);
      if (!mounted) return;
      switch (role) {
        case UserRole.kitchen:
          context.go('/kitchen');
          break;
        case UserRole.driver:
          context.go('/driver');
          break;
        case UserRole.admin:
        case UserRole.customer:
          context.go('/admin');
          break;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('خطأ في الدخول: $e'),
          backgroundColor: AppColors.error,
        ));
      }
    } finally {
      if (mounted) setState(() => _quickLoginRole = null);
    }
  }

  void _showQuickLoginSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              'دخول تجريبي لفريق العمل',
              style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 15),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            _QuickLoginTile(
              icon: Icons.restaurant,
              label: 'المطبخ',
              onTap: () {
                Navigator.pop(context);
                _quickLogin(UserRole.kitchen);
              },
            ),
            _QuickLoginTile(
              icon: Icons.delivery_dining,
              label: 'المندوب',
              onTap: () {
                Navigator.pop(context);
                _quickLogin(UserRole.driver);
              },
            ),
            _QuickLoginTile(
              icon: Icons.admin_panel_settings_outlined,
              label: 'الإدارة',
              onTap: () {
                Navigator.pop(context);
                _quickLogin(UserRole.admin);
              },
            ),
          ],
        ),
      ),
    );
  }

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
      final iosInstallable =
          js.context.callMethod('isIosSafariInstallable', []) == true;
      if (mounted &&
          (ready != _showInstallBanner || iosInstallable != _isIosInstallable)) {
        setState(() {
          _showInstallBanner = ready;
          _isIosInstallable = iosInstallable;
        });
      }
    } catch (_) {}
  }

  Future<void> _triggerInstall() async {
    try {
      js.context.callMethod('showPwaInstallPrompt', []);
    } catch (_) {}
    setState(() => _installBannerDismissed = true);
  }

  void _showIosInstallInstructions() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('تثبيت التطبيق',
            style: TextStyle(color: AppColors.textPrimary, fontSize: 17)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'لتثبيت التطبيق على شاشتك الرئيسية:',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            const _IosStep(number: '1', text: 'اضغط زر المشاركة ⬆️ في شريط المتصفح'),
            const SizedBox(height: 8),
            const _IosStep(number: '2', text: 'اختر "إضافة إلى الشاشة الرئيسية"'),
            const SizedBox(height: 8),
            const _IosStep(number: '3', text: 'اضغط "إضافة" للتأكيد'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
    setState(() => _installBannerDismissed = true);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _catBarScroll.dispose();
    super.dispose();
  }

  // زر "بحث" في التنقل السفلي — يمرّر لأعلى ثم يركّز على حقل البحث
  void _focusSearch() {
    _selectCategory(null);
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _searchFocusNode.requestFocus();
    });
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

  // نقر على بانر مرتبط بفئة أو صنف — ينقل للقسم المناسب في القائمة (نفس منطق حبات الفئات)
  void _handleBannerTap(PromoBannerModel banner, List<MenuItemModel> allItems) {
    if (banner.linkType == BannerLinkType.category && banner.linkId != null) {
      _selectCategory(banner.linkId);
    } else if (banner.linkType == BannerLinkType.item && banner.linkId != null) {
      final matches = allItems.where((i) => i.id == banner.linkId);
      if (matches.isNotEmpty) _selectCategory(matches.first.categoryId);
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
    final bannersAsync = ref.watch(activeBannersStreamProvider);
    final searchQuery = ref.watch(searchQueryProvider);
    final displayStyle = ref.watch(appThemeProvider).menuDisplayStyle;

    final categories = categoriesAsync.valueOrNull ?? [];
    final allItems = allItemsAsync.valueOrNull ?? [];
    final banners = bannersAsync.valueOrNull ?? [];
    final bestSellers = allItems.where((i) => i.isBestSeller).toList();

    // أول تحميل فقط (لا بيانات مخزّنة بعد) — نعرض هيكلاً نابضاً بدل فراغ مفاجئ
    final isInitialLoading = (categoriesAsync.isLoading && !categoriesAsync.hasValue) ||
        (allItemsAsync.isLoading && !allItemsAsync.hasValue);

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
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(22)),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(54),
          child: _OrderTypeSelector(
            deliveryEnabled: settings.deliveryEnabled,
            selected: ref.watch(orderTypeProvider),
            onChanged: (t) => ref.read(orderTypeProvider.notifier).state = t,
          ),
        ),
        // دخول مباشر سريع لفريق العمل (مطبخ/مندوب/إدارة) — لمرحلة المعاينة فقط
        // أيقونة واحدة تفتح قائمة، بدل ثلاث أيقونات ثابتة قد تتجاوز عرض الشاشات الضيقة
        leading: _StaffQuickIcon(
          icon: Icons.people_alt_outlined,
          tooltip: 'دخول تجريبي لفريق العمل',
          isLoading: _quickLoginRole != null,
          onTap: () => _showQuickLoginSheet(context),
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
                  style: TextStyle(
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
                    style: TextStyle(
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
                  icon: Icon(Icons.shopping_bag_outlined,
                      color: AppColors.textPrimary),
                ),
                if (cartCount > 0)
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Container(
                      width: 17,
                      height: 17,
                      decoration: BoxDecoration(
                        color: AppColors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '$cartCount',
                          style: TextStyle(
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
          if (!_installBannerDismissed && (_showInstallBanner || _isIosInstallable))
            SliverToBoxAdapter(
              child: _InstallBanner(
                isIos: _isIosInstallable && !_showInstallBanner,
                onInstall: _isIosInstallable && !_showInstallBanner
                    ? _showIosInstallInstructions
                    : _triggerInstall,
                onDismiss: () => setState(() => _installBannerDismissed = true),
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
                    gradient: LinearGradient(
                      colors: [AppColors.manjawiDark, AppColors.manjawi],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.receipt_long,
                          color: Colors.white, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'طلبك الحالي: ${activeOrder.status.label}',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Icon(Icons.chevron_left,
                          color: Colors.white, size: 20),
                    ],
                  ),
                ),
              ),
            ),

          // بانر عروض متحرك يديره الأدمن — أو الغلاف الثابت كـ fallback عند عدم وجود بانرات نشطة
          SliverToBoxAdapter(
            child: _PromoCarousel(
              banners: banners,
              fallbackImageUrl: coverImageUrl,
              screenWidth: screenWidth,
              onBannerTap: (b) => _handleBannerTap(b, allItems),
            ).animate().fadeIn(duration: 380.ms).slideY(begin: -0.04, curve: Curves.easeOut),
          ),

          // قسم الأكثر مبيعاً — وضع العرض العادي فقط، وعند وجود أصناف مميزة
          if (searchQuery.isEmpty && bestSellers.isNotEmpty)
            SliverToBoxAdapter(
              child: _BestSellersSection(items: bestSellers)
                  .animate()
                  .fadeIn(duration: 380.ms, delay: 80.ms)
                  .slideY(begin: 0.05, curve: Curves.easeOut),
            ),

          // Sticky search bar + category chips — stay at top after cover scrolls away
          SliverPersistentHeader(
            pinned: true,
            delegate: _StickyBarDelegate(
              height: 136,
              child: _SearchCategoryBar(
                searchController: _searchController,
                searchFocusNode: _searchFocusNode,
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
          if (isInitialLoading) ...[
            const SliverToBoxAdapter(child: _MenuSkeletonLoader()),
          ] else if (searchQuery.isNotEmpty) ...[
            // Search mode: flat filtered list
            if (filteredItems.isEmpty)
              const SliverToBoxAdapter(child: _EmptyState())
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                sliver: _itemsSliver(filteredItems, displayStyle),
              ),
          ] else ...[
            // Normal mode: grouped by category with section headers
            for (final cat in categories)
              ..._buildCategorySection(cat, allItems, displayStyle),
            if (allItems.isEmpty)
              const SliverToBoxAdapter(child: _EmptyState()),
          ],

          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),

      floatingActionButton: _CartFab(
        count: cartCount,
        onTap: () => context.push('/cart'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _NotchedNavBar(
        hasActiveOrder: activeOrder != null,
        onMenuTap: () => _selectCategory(null),
        onSearchTap: _focusSearch,
        onOrdersTap: activeOrder != null
            ? () => context.push('/track/${activeOrder.id}')
            : null,
        onProfileTap: () => context.push('/profile'),
      ),
    );
  }

  // بنية العرض المشتركة بين وضع البحث ووضع الفئات: قائمة أو شبكة حسب إعداد الأدمن
  Widget _itemsSliver(List<MenuItemModel> items, MenuDisplayStyle style) {
    if (style == MenuDisplayStyle.grid) {
      return SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 0.72,
        ),
        delegate: SliverChildBuilderDelegate(
          (_, i) => MenuItemGridCard(item: items[i]),
          childCount: items.length,
        ),
      );
    }
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (_, i) => Padding(
          padding: const EdgeInsets.only(bottom: 1),
          child: MenuItemListCard(item: items[i]),
        ),
        childCount: items.length,
      ),
    );
  }

  // Returns a header sliver + items sliver for one category
  List<Widget> _buildCategorySection(
      CategoryModel cat, List<MenuItemModel> allItems, MenuDisplayStyle displayStyle) {
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
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        sliver: _itemsSliver(catItems, displayStyle),
      ),
    ];
  }
}

// ── تنقل سفلي بفتحة دائرية (Notch) وزر سلة مرتفع في المنتصف ────────────────────
// فكرة مختلفة عن الشريط المسطح المعتاد: البار نفسه "يحتضن" زر السلة العائم
// بدل مجرد وضع أيقونة إضافية بين البقية.

class _NotchedNavBar extends StatelessWidget {
  final bool hasActiveOrder;
  final VoidCallback onMenuTap;
  final VoidCallback onSearchTap;
  final VoidCallback? onOrdersTap;
  final VoidCallback onProfileTap;

  const _NotchedNavBar({
    required this.hasActiveOrder,
    required this.onMenuTap,
    required this.onSearchTap,
    required this.onOrdersTap,
    required this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: AppColors.surface,
      shape: const CircularNotchedRectangle(),
      notchMargin: 10,
      elevation: 14,
      padding: EdgeInsets.zero,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 58,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavIcon(icon: Icons.restaurant_menu_rounded, label: 'القائمة', active: true, onTap: onMenuTap),
              _NavIcon(icon: Icons.search_rounded, label: 'بحث', active: false, onTap: onSearchTap),
              const SizedBox(width: 48), // مساحة الفتحة لزر السلة العائم
              _NavIcon(
                icon: Icons.receipt_long_rounded,
                label: 'طلبي',
                active: false,
                onTap: onOrdersTap,
                enabled: hasActiveOrder,
              ),
              _NavIcon(icon: Icons.person_rounded, label: 'حسابي', active: false, onTap: onProfileTap),
            ],
          ),
        ),
      ),
    );
  }
}

// زر السلة العائم — يستقر داخل فتحة الشريط السفلي بدل أن يكون أيقونة عادية بينها
class _CartFab extends StatelessWidget {
  final int count;
  final VoidCallback onTap;
  const _CartFab({required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.surface, width: 4),
          boxShadow: [
            BoxShadow(
              color: AppColors.purple.withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            const Icon(Icons.shopping_bag_rounded, color: Colors.white, size: 25),
            if (count > 0)
              Positioned(
                top: -4,
                right: -4,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                  child: Container(
                    key: ValueKey(count),
                    padding: const EdgeInsets.all(3),
                    constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.red,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.surface, width: 2),
                    ),
                    child: Text('$count',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
          ],
        ),
      ),
    ).animate().scale(duration: 450.ms, curve: Curves.elasticOut);
  }
}

class _NavIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback? onTap;
  final bool enabled;

  const _NavIcon({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final color = !enabled
        ? AppColors.textHint.withValues(alpha: 0.35)
        : active
            ? AppColors.purple
            : AppColors.textHint;
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 3),
            Text(label,
                style: TextStyle(
                    color: color, fontSize: 10.5, fontWeight: active ? FontWeight.bold : FontWeight.normal)),
          ],
        ),
      ),
    );
  }
}

// ── أيقونة دخول سريع لفريق العمل (معاينة) ─────────────────────────────────────

class _StaffQuickIcon extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final bool isLoading;
  final VoidCallback onTap;

  const _StaffQuickIcon({
    required this.icon,
    required this.tooltip,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: isLoading ? null : onTap,
      tooltip: tooltip,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
      icon: isLoading
          ? SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.textHint.withOpacity(0.5),
              ),
            )
          : Icon(icon, size: 20, color: AppColors.textHint.withOpacity(0.45)),
    );
  }
}

class _QuickLoginTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _QuickLoginTile({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: AppColors.purple),
      title: Text(label, style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }
}

// ── محدد طريقة الاستلام (توصيل/استلام) ─────────────────────────────────────────

class _OrderTypeSelector extends StatelessWidget {
  final bool deliveryEnabled;
  final OrderType selected;
  final ValueChanged<OrderType> onChanged;

  const _OrderTypeSelector({
    required this.deliveryEnabled,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (!deliveryEnabled) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.storefront, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text('استلام من المطعم فقط',
                  style: TextStyle(
                      color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Expanded(
              child: _OrderTypePill(
                icon: Icons.delivery_dining,
                label: 'توصيل',
                active: selected == OrderType.delivery,
                onTap: () => onChanged(OrderType.delivery),
              ),
            ),
            Expanded(
              child: _OrderTypePill(
                icon: Icons.storefront,
                label: 'استلام',
                active: selected == OrderType.pickup,
                onTap: () => onChanged(OrderType.pickup),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderTypePill extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _OrderTypePill({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          gradient: active ? AppColors.primaryGradient : null,
          borderRadius: BorderRadius.circular(10),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: AppColors.purple.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: active ? Colors.white : AppColors.textSecondary),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: active ? Colors.white : AppColors.textSecondary,
                fontSize: 13,
                fontWeight: active ? FontWeight.bold : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Sticky search + category bar ──────────────────────────────────────────────

class _SearchCategoryBar extends StatelessWidget {
  final TextEditingController searchController;
  final FocusNode? searchFocusNode;
  final ScrollController catBarScroll;
  final List<CategoryModel> categories;
  final String? highlightedCatId;
  final void Function(String?) onCategoryTap;
  final void Function(String) onSearchChanged;
  final VoidCallback onClearSearch;

  const _SearchCategoryBar({
    required this.searchController,
    this.searchFocusNode,
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
            focusNode: searchFocusNode,
            style:
                TextStyle(color: AppColors.textPrimary, fontSize: 14),
            decoration: InputDecoration(
              hintText: AppStrings.search,
              hintStyle:
                  TextStyle(color: AppColors.textHint, fontSize: 14),
              prefixIcon: Icon(Icons.search,
                  color: AppColors.textHint, size: 20),
              suffixIcon: searchController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.close,
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

        // فئات كأيقونات دائرية بصور (مع fallback متدرّج عند غياب الصورة) — تلاشٍ خفيف عند الحواف
        SizedBox(
          height: 80,
          child: ShaderMask(
            shaderCallback: (rect) => const LinearGradient(
              colors: [Colors.transparent, Colors.black, Colors.black, Colors.transparent],
              stops: [0.0, 0.05, 0.95, 1.0],
            ).createShader(rect),
            blendMode: BlendMode.dstIn,
            child: ListView.builder(
            controller: catBarScroll,
            scrollDirection: Axis.horizontal,
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            itemCount: categories.length + 1,
            itemBuilder: (_, i) {
              final isAll = i == 0;
              final isSelected = isAll
                  ? highlightedCatId == null
                  : highlightedCatId == categories[i - 1].id;
              final label =
                  isAll ? AppStrings.allCategories : categories[i - 1].name;
              final catId = isAll ? null : categories[i - 1].id;
              final imageUrl = isAll ? null : categories[i - 1].imageUrl;

              return GestureDetector(
                onTap: () => onCategoryTap(catId),
                child: Container(
                  width: 62,
                  margin: const EdgeInsets.only(left: 10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 48,
                        height: 48,
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? AppColors.purple
                                : Colors.transparent,
                            width: 2,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: AppColors.purple.withValues(alpha: 0.35),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: ClipOval(
                          child: imageUrl != null
                              ? Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      _CategoryIconFallback(isAll: isAll),
                                )
                              : _CategoryIconFallback(isAll: isAll),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isSelected
                              ? AppColors.purple
                              : AppColors.textSecondary,
                          fontSize: 11,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            ),
          ),
        ),
      ],
    );
  }
}

// دائرة متدرّجة بأيقونة عامة — تُستخدم عند غياب صورة الفئة أو فشل تحميلها
class _CategoryIconFallback extends StatelessWidget {
  final bool isAll;
  const _CategoryIconFallback({required this.isAll});

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(gradient: AppColors.primaryGradient),
        child: Icon(
          isAll ? Icons.apps_rounded : Icons.restaurant_menu,
          color: Colors.white,
          size: 20,
        ),
      );
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

// ── Promo carousel ──────────────────────────────────────────────────────────

class _PromoCarousel extends StatefulWidget {
  final List<PromoBannerModel> banners;
  final String? fallbackImageUrl;
  final double screenWidth;
  final void Function(PromoBannerModel banner) onBannerTap;

  const _PromoCarousel({
    required this.banners,
    required this.fallbackImageUrl,
    required this.screenWidth,
    required this.onBannerTap,
  });

  @override
  State<_PromoCarousel> createState() => _PromoCarouselState();
}

class _PromoCarouselState extends State<_PromoCarousel> {
  final _pageController = PageController();
  Timer? _timer;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _restartAutoPlay();
  }

  @override
  void didUpdateWidget(covariant _PromoCarousel old) {
    super.didUpdateWidget(old);
    if (old.banners.length != widget.banners.length) {
      _page = 0;
      _restartAutoPlay();
    }
  }

  void _restartAutoPlay() {
    _timer?.cancel();
    if (widget.banners.length < 2) return;
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!_pageController.hasClients) return;
      final next = (_page + 1) % widget.banners.length;
      _pageController.animateToPage(next,
          duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Widget _fallbackGradient(double height) => Container(
        height: height,
        decoration: BoxDecoration(gradient: AppColors.heroGradient),
        child: const Center(
          child: Icon(Icons.restaurant, color: Colors.white, size: 72),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final height = widget.screenWidth * 0.55;

    // لا بانرات نشطة — نعود لسلوك الغلاف الثابت القديم كـ fallback
    if (widget.banners.isEmpty) {
      if (widget.fallbackImageUrl == null) return const SizedBox.shrink();
      return _WavyCoverBanner(
        child: Image.network(
          widget.fallbackImageUrl!,
          width: widget.screenWidth,
          fit: BoxFit.fitWidth,
          errorBuilder: (_, __, ___) => _fallbackGradient(height),
        ),
      );
    }

    return _WavyCoverBanner(
      child: SizedBox(
        height: height,
        width: widget.screenWidth,
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: widget.banners.length,
              onPageChanged: (i) => setState(() => _page = i),
              itemBuilder: (_, i) {
                final banner = widget.banners[i];
                return GestureDetector(
                  onTap: () => widget.onBannerTap(banner),
                  child: Image.network(
                    banner.imageUrl,
                    width: widget.screenWidth,
                    height: height,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _fallbackGradient(height),
                  ),
                );
              },
            ),
            if (widget.banners.length > 1)
              Positioned(
                bottom: 10,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(widget.banners.length, (i) {
                    final active = i == _page;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: active ? 18 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(active ? 0.95 : 0.5),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    );
                  }),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Best sellers section ──────────────────────────────────────────────────────

class _BestSellersSection extends StatelessWidget {
  final List<MenuItemModel> items;
  const _BestSellersSection({required this.items});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(Icons.local_fire_department,
                    color: AppColors.manjawi, size: 18),
                const SizedBox(width: 6),
                Text(
                  'الأكثر مبيعاً',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 190,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: items.length,
              itemBuilder: (_, i) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: SizedBox(width: 140, child: MenuItemGridCard(item: items[i])),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── PWA Install Banner ────────────────────────────────────────────────────────

class _IosStep extends StatelessWidget {
  final String number;
  final String text;
  const _IosStep({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 22,
          height: 22,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.purple,
            shape: BoxShape.circle,
          ),
          child: Text(number,
              style: TextStyle(
                  color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text,
              style: TextStyle(color: AppColors.textPrimary, fontSize: 13)),
        ),
      ],
    );
  }
}

class _InstallBanner extends StatelessWidget {
  final VoidCallback onInstall;
  final VoidCallback onDismiss;
  final bool isIos;
  const _InstallBanner({
    required this.onInstall,
    required this.onDismiss,
    this.isIos = false,
  });

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
              child: Icon(Icons.install_mobile, color: Colors.white, size: 24),
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
                    isIos
                        ? 'أضفه لشاشتك الرئيسية عبر زر المشاركة'
                        : 'أضفه لشاشتك الرئيسية للوصول السريع',
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
              child: Text(isIos ? 'كيف؟' : 'تحميل',
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

// ── Skeleton loader (أول تحميل) ─────────────────────────────────────────────────

class _MenuSkeletonLoader extends StatelessWidget {
  const _MenuSkeletonLoader();

  Widget _box({double? w, double h = 14, double r = 8}) => Container(
        width: w,
        height: h,
        decoration: BoxDecoration(color: AppColors.surfaceLight, borderRadius: BorderRadius.circular(r)),
      );

  Widget _cardSkeleton() => Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: AppColors.cardBackground, borderRadius: BorderRadius.circular(18)),
        child: Row(
          children: [
            _box(w: 84, h: 84, r: 16),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _box(w: 120),
                  const SizedBox(height: 8),
                  _box(w: 180, h: 11),
                  const SizedBox(height: 10),
                  _box(w: 60, h: 16),
                ],
              ),
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        children: List.generate(5, (_) => _cardSkeleton()),
      ),
    ).animate(onPlay: (c) => c.repeat()).shimmer(
          duration: 1200.ms,
          color: AppColors.surface.withValues(alpha: 0.6),
        );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off, size: 48, color: AppColors.textHint),
          const SizedBox(height: 12),
          Text(
            AppStrings.noItemsFound,
            style: TextStyle(color: AppColors.textHint, fontSize: 15),
          ),
        ],
      ),
    );
  }
}
