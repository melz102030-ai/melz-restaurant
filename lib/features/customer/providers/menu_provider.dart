import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/category_model.dart';
import '../../../core/models/menu_item_model.dart';
import '../../../core/services/menu_service.dart';

final categoriesStreamProvider = StreamProvider<List<CategoryModel>>((ref) {
  return MenuService.streamCategories();
});

final menuItemsStreamProvider = StreamProvider.family<List<MenuItemModel>, String?>((ref, categoryId) {
  return MenuService.streamAvailableItems(categoryId: categoryId);
});

final selectedCategoryProvider = StateProvider<String?>((ref) => null);

final searchQueryProvider = StateProvider<String>((ref) => '');

final filteredMenuProvider = Provider<List<MenuItemModel>>((ref) {
  final categoryId = ref.watch(selectedCategoryProvider);
  final query = ref.watch(searchQueryProvider).toLowerCase();

  final itemsAsync = ref.watch(menuItemsStreamProvider(categoryId));
  final items = itemsAsync.maybeWhen(data: (d) => d, orElse: () => <MenuItemModel>[]);

  if (query.isEmpty) return items;
  return items.where((item) =>
    item.name.toLowerCase().contains(query) ||
    item.description.toLowerCase().contains(query)
  ).toList();
});
