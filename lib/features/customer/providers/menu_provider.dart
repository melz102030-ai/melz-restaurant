import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/category_model.dart';
import '../../../core/models/menu_item_model.dart';
import '../../../core/services/menu_service.dart';
import '../../../core/data/local_menu_data.dart';

// يحاول Firebase أولاً، فإن فشل يرجع البيانات المحلية
final categoriesStreamProvider = StreamProvider<List<CategoryModel>>((ref) async* {
  try {
    await for (final cats in MenuService.streamCategories()) {
      if (cats.isEmpty) {
        yield LocalMenuData.categories;
      } else {
        yield cats;
      }
    }
  } catch (_) {
    yield LocalMenuData.categories;
  }
});

final menuItemsStreamProvider =
    StreamProvider.family<List<MenuItemModel>, String?>((ref, categoryId) async* {
  try {
    await for (final items in MenuService.streamAvailableItems(categoryId: categoryId)) {
      if (items.isEmpty) {
        yield LocalMenuData.itemsByCategory(categoryId);
      } else {
        yield items;
      }
    }
  } catch (_) {
    yield LocalMenuData.itemsByCategory(categoryId);
  }
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
