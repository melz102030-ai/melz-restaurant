import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/cart_provider.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../shared/widgets/gradient_container.dart';
import '../../../core/models/order_model.dart';
import '../providers/menu_provider.dart';
import '../providers/orders_provider.dart';
import '../widgets/menu_item_card.dart';

class CustomerHomeScreen extends ConsumerStatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  ConsumerState<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends ConsumerState<CustomerHomeScreen> {
  final _searchController = TextEditingController();
  int _currentTab = 0;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider);
    final settings = ref.watch(settingsProvider);
    final cartCount = ref.watch(cartItemCountProvider);
    final activeOrder = ref.watch(activeOrderProvider);

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppColors.surface,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(gradient: AppColors.heroGradient),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'مرحباً، ${user?.name ?? 'ضيف'} 👋',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  settings.restaurantName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Cart button
                          Stack(
                            children: [
                              IconButton(
                                onPressed: () => context.push('/cart'),
                                icon: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.shopping_cart_outlined,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              if (cartCount > 0)
                                Positioned(
                                  right: 6,
                                  top: 6,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: AppColors.red,
                                      shape: BoxShape.circle,
                                    ),
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
                            ],
                          ),
                          // Profile
                          IconButton(
                            onPressed: () => context.push('/profile'),
                            icon: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.person_outline,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Open/closed status
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: settings.isOpen
                              ? Colors.green.withOpacity(0.2)
                              : Colors.red.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: settings.isOpen ? Colors.green : Colors.red,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              settings.isOpen ? Icons.circle : Icons.circle_outlined,
                              size: 8,
                              color: settings.isOpen ? Colors.green : Colors.red,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              settings.isOpen
                                  ? '${AppStrings.isOpen} · ${settings.estimatedPrepTime} دقيقة'
                                  : AppStrings.isClosed,
                              style: TextStyle(
                                color: settings.isOpen ? Colors.green : Colors.red,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            title: const Text('ميلز'),
            titleTextStyle: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            actions: [
              IconButton(
                onPressed: () => context.push('/cart'),
                icon: Badge(
                  isLabelVisible: cartCount > 0,
                  label: Text('$cartCount'),
                  backgroundColor: AppColors.red,
                  child: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
                ),
              ),
            ],
          ),
        ],
        body: Column(
          children: [
            // Active order banner
            if (activeOrder != null)
              GestureDetector(
                onTap: () => context.push('/track/${activeOrder.id}'),
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.manjawiDark, AppColors.manjawi],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.manjawi.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.delivery_dining, color: Colors.white, size: 32),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'طلبك في الطريق!',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              activeOrder.status.label,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
                    ],
                  ),
                ).animate().slideX(begin: -1, duration: 400.ms),
              ),

            // Search bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  hintText: AppStrings.search,
                  prefixIcon: Icon(Icons.search),
                  suffixIcon: Icon(Icons.tune),
                ),
                onChanged: (v) =>
                    ref.read(searchQueryProvider.notifier).state = v,
              ),
            ),

            // Categories
            _CategoryBar(),

            // Menu Items Grid
            Expanded(
              child: _MenuGrid(),
            ),
          ],
        ),
      ),
      floatingActionButton: cartCount > 0
          ? FloatingActionButton.extended(
              onPressed: () => context.push('/cart'),
              backgroundColor: AppColors.manjawi,
              icon: const Icon(Icons.shopping_cart),
              label: Text('السلة ($cartCount)'),
            ).animate().slideY(begin: 2, duration: 300.ms)
          : null,
    );
  }
}

class _CategoryBar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesStreamProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);

    return categoriesAsync.when(
      data: (categories) {
        final active = categories.where((c) => c.isActive).toList();
        return SizedBox(
          height: 52,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: active.length + 1,
            itemBuilder: (_, i) {
              if (i == 0) {
                return Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: ChoiceChip(
                    label: const Text(AppStrings.allCategories),
                    selected: selectedCategory == null,
                    onSelected: (_) =>
                        ref.read(selectedCategoryProvider.notifier).state = null,
                    selectedColor: AppColors.purple,
                    labelStyle: TextStyle(
                      color: selectedCategory == null
                          ? Colors.white
                          : AppColors.textSecondary,
                    ),
                  ),
                );
              }
              final cat = active[i - 1];
              final isSelected = selectedCategory == cat.id;
              return Padding(
                padding: const EdgeInsets.only(left: 8),
                child: ChoiceChip(
                  avatar: cat.icon != null ? Text(cat.icon!) : null,
                  label: Text(cat.name),
                  selected: isSelected,
                  onSelected: (_) => ref.read(selectedCategoryProvider.notifier).state =
                      isSelected ? null : cat.id,
                  selectedColor: AppColors.purple,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              );
            },
          ),
        );
      },
      loading: () => const SizedBox(height: 52),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _MenuGrid extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(filteredMenuProvider);
    final isWide = MediaQuery.of(context).size.width > 768;

    if (items.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.restaurant_menu, size: 64, color: AppColors.textHint),
            SizedBox(height: 16),
            Text(
              AppStrings.noItemsFound,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isWide ? 4 : 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) => MenuItemCard(item: items[i], index: i),
    );
  }
}
