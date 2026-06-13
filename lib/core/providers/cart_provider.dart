import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/menu_item_model.dart';
import '../models/order_model.dart';
import '../models/option_group_model.dart';

class CartItem {
  final MenuItemModel item;
  final int quantity;
  final List<SelectedOptionGroup> selectedOptions;

  const CartItem({
    required this.item,
    required this.quantity,
    this.selectedOptions = const [],
  });

  // Unique key: item id + selected option ids (so same item with different options = separate entries)
  String get cartKey {
    if (selectedOptions.isEmpty) return item.id;
    final optStr = selectedOptions
        .map((g) => '${g.groupId}:${g.selectedIds.join(',')}')
        .join('|');
    return '${item.id}_$optStr';
  }

  double get optionsExtra =>
      selectedOptions.fold(0.0, (s, g) => s + g.totalExtra);

  double get unitPrice => item.finalPrice + optionsExtra;
  double get total => unitPrice * quantity;

  String get optionsSummary => selectedOptions
      .where((g) => g.selectedNames.isNotEmpty)
      .map((g) => g.summary)
      .join(' · ');

  CartItem copyWith({int? quantity}) =>
      CartItem(item: item, quantity: quantity ?? this.quantity, selectedOptions: selectedOptions);
}

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  void addItem(MenuItemModel item, [List<SelectedOptionGroup> options = const []]) {
    final key = _keyFor(item.id, options);
    final idx = state.indexWhere((c) => c.cartKey == key);
    if (idx >= 0) {
      state = [
        ...state.sublist(0, idx),
        state[idx].copyWith(quantity: state[idx].quantity + 1),
        ...state.sublist(idx + 1),
      ];
    } else {
      state = [
        ...state,
        CartItem(item: item, quantity: 1, selectedOptions: options),
      ];
    }
  }

  void removeItem(String cartKey) {
    final idx = state.indexWhere((c) => c.cartKey == cartKey);
    if (idx < 0) return;
    if (state[idx].quantity > 1) {
      state = [
        ...state.sublist(0, idx),
        state[idx].copyWith(quantity: state[idx].quantity - 1),
        ...state.sublist(idx + 1),
      ];
    } else {
      state = [...state.sublist(0, idx), ...state.sublist(idx + 1)];
    }
  }

  void deleteItem(String cartKey) {
    state = state.where((c) => c.cartKey != cartKey).toList();
  }

  void clear() => state = [];

  int getQuantity(String itemId) =>
      state.where((c) => c.item.id == itemId).fold(0, (s, c) => s + c.quantity);

  List<OrderItem> toOrderItems() {
    return state.map((c) => OrderItem(
          menuItemId: c.item.id,
          name: c.item.name,
          price: c.unitPrice,
          quantity: c.quantity,
          imageUrl: c.item.imageUrl,
          selectedOptions: c.selectedOptions
              .map((g) => OrderItemOption(
                    groupName: g.groupName,
                    selectedNames: g.selectedNames,
                    extra: g.totalExtra,
                  ))
              .toList(),
        )).toList();
  }

  String _keyFor(String itemId, List<SelectedOptionGroup> options) {
    if (options.isEmpty) return itemId;
    final optStr = options
        .map((g) => '${g.groupId}:${g.selectedIds.join(',')}')
        .join('|');
    return '${itemId}_$optStr';
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier();
});

final cartTotalProvider = Provider<double>((ref) {
  return ref.watch(cartProvider).fold(0.0, (s, c) => s + c.total);
});

final cartItemCountProvider = Provider<int>((ref) {
  return ref.watch(cartProvider).fold(0, (s, c) => s + c.quantity);
});
