import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/category_model.dart';
import '../../../core/models/menu_item_model.dart';
import '../../../core/models/option_template_model.dart';
import '../../../core/models/promo_banner_model.dart';
import '../../../core/services/menu_service.dart';
import '../../../core/services/promo_banner_service.dart';

final categoriesStreamProvider = StreamProvider<List<CategoryModel>>((ref) {
  return MenuService.streamCategories()
      .map((cats) => cats.where((c) => c.isActive).toList());
});

final menuItemsStreamProvider =
    StreamProvider.family<List<MenuItemModel>, String?>((ref, categoryId) {
  // stream all items ordered by sortOrder, filter in Dart to avoid composite index
  // (sold-out items stay in the list — the UI greys them out instead of hiding them)
  return MenuService.streamMenuItems().map((items) => items
      .where((i) => categoryId == null || i.categoryId == categoryId)
      .toList());
});

// Admin providers — Firestore مباشرة بدون بيانات محلية
final adminMenuItemsProvider = StreamProvider<List<MenuItemModel>>((ref) {
  return MenuService.streamMenuItems();
});

final adminCategoriesProvider = StreamProvider<List<CategoryModel>>((ref) {
  return MenuService.streamCategories();
});

final adminOptionTemplatesProvider = StreamProvider<List<OptionTemplateModel>>((ref) {
  return MenuService.streamOptionTemplates();
});

// بانرات العروض — نشطة فقط (للعميل) وكاملة (للأدمن)
final activeBannersStreamProvider = StreamProvider<List<PromoBannerModel>>((ref) {
  return PromoBannerService.streamActiveBanners();
});

final adminBannersProvider = StreamProvider<List<PromoBannerModel>>((ref) {
  return PromoBannerService.streamBanners();
});

// صنف واحد بمعرّفه — لصفحة تفاصيل الصنف الكاملة، بلا استعلام Firestore إضافي
// (يعتمد على نفس تدفّق menuItemsStreamProvider(null) المستخدم أصلاً في القائمة)
final menuItemByIdProvider = Provider.family<MenuItemModel?, String>((ref, id) {
  final items = ref.watch(menuItemsStreamProvider(null)).valueOrNull ?? const [];
  for (final item in items) {
    if (item.id == id) return item;
  }
  return null;
});

final selectedCategoryProvider = StateProvider<String?>((ref) => null);

final searchQueryProvider = StateProvider<String>((ref) => '');

final filteredMenuProvider = Provider<List<MenuItemModel>>((ref) {
  final categoryId = ref.watch(selectedCategoryProvider);
  final query = ref.watch(searchQueryProvider).toLowerCase();
  final itemsAsync = ref.watch(menuItemsStreamProvider(categoryId));
  final items = itemsAsync.maybeWhen(data: (d) => d, orElse: () => <MenuItemModel>[]);
  if (query.isEmpty) return items;
  return items
      .where((item) =>
          item.name.toLowerCase().contains(query) ||
          item.description.toLowerCase().contains(query))
      .toList();
});
