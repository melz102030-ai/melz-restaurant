import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/category_model.dart';
import '../../../core/models/menu_item_model.dart';
import '../../../core/services/menu_service.dart';
import '../../../core/data/local_menu_data.dart';

final categoriesStreamProvider = StreamProvider<List<CategoryModel>>((ref) async* {
  // يظهر البيانات المحلية فوراً بدون انتظار
  yield LocalMenuData.categories;
  try {
    await for (final cats in MenuService.streamCategories()
        .timeout(const Duration(seconds: 6))) {
      if (cats.isNotEmpty) yield cats;
    }
  } catch (_) {}
});

final menuItemsStreamProvider =
    StreamProvider.family<List<MenuItemModel>, String?>((ref, categoryId) async* {
  // يظهر البيانات المحلية فوراً
  yield LocalMenuData.itemsByCategory(categoryId);
  try {
    await for (final items in MenuService.streamAvailableItems(categoryId: categoryId)
        .timeout(const Duration(seconds: 6))) {
      if (items.isNotEmpty) yield items;
    }
  } catch (_) {}
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
