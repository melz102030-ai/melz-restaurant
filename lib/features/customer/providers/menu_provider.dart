import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/category_model.dart';
import '../../../core/models/menu_item_model.dart';
import '../../../core/models/option_template_model.dart';
import '../../../core/services/menu_service.dart';

final categoriesStreamProvider = StreamProvider<List<CategoryModel>>((ref) {
  return MenuService.streamCategories()
      .map((cats) => cats.where((c) => c.isActive).toList());
});

final menuItemsStreamProvider =
    StreamProvider.family<List<MenuItemModel>, String?>((ref, categoryId) {
  // stream all items ordered by sortOrder, filter in Dart to avoid composite index
  return MenuService.streamMenuItems().map((items) => items
      .where((i) =>
          i.isAvailable &&
          (categoryId == null || i.categoryId == categoryId))
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
