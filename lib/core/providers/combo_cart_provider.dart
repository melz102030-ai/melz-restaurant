import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/combo_model.dart';
import '../models/menu_item_model.dart';
import '../models/option_group_model.dart';
import '../models/order_model.dart';

class ComboSubSelection {
  final MenuItemModel item;
  final List<SelectedOptionGroup> selectedOptions;

  const ComboSubSelection({required this.item, this.selectedOptions = const []});

  double get optionsExtra => selectedOptions.fold(0.0, (s, g) => s + g.totalExtra);

  String get summary {
    final opts = selectedOptions.where((g) => g.selectedNames.isNotEmpty).map((g) => g.summary).join(' · ');
    return opts.isEmpty ? item.name : '${item.name} ($opts)';
  }
}

class ComboCartEntry {
  final ComboModel combo;
  final List<ComboSubSelection> subSelections;
  final int quantity;

  const ComboCartEntry({
    required this.combo,
    required this.subSelections,
    this.quantity = 1,
  });

  String get cartKey {
    final optId = subSelections
        .where((s) => combo.optionItemIds.contains(s.item.id))
        .map((s) => s.item.id)
        .join(',');
    return optId.isEmpty ? 'combo_${combo.id}' : 'combo_${combo.id}_opt_$optId';
  }
  double get unitPrice => combo.price;
  double get total => unitPrice * quantity;

  ComboCartEntry copyWith({int? quantity}) => ComboCartEntry(
        combo: combo,
        subSelections: subSelections,
        quantity: quantity ?? this.quantity,
      );

  // التركيبة تُحوَّل لـ OrderItem واحد (الرأس بالسعر) + sub-items بسعر صفر
  // حتى يراها المطبخ والإدارة بشكل كامل
  List<OrderItem> toOrderItems() {
    final header = OrderItem(
      menuItemId: 'combo_${combo.id}',
      name: 'تركيبة: ${combo.name}',
      price: combo.price,
      quantity: quantity,
      imageUrl: combo.imageUrl,
      selectedOptions: [],
    );
    final subs = subSelections.map((s) => OrderItem(
          menuItemId: s.item.id,
          name: '↳ ${s.item.name}',
          price: 0,
          quantity: quantity,
          imageUrl: s.item.imageUrl,
          selectedOptions: s.selectedOptions
              .map((g) => OrderItemOption(
                    groupName: g.groupName,
                    selectedNames: g.selectedNames,
                    extra: g.totalExtra,
                  ))
              .toList(),
        ));
    return [header, ...subs];
  }
}

class ComboCartNotifier extends StateNotifier<List<ComboCartEntry>> {
  ComboCartNotifier() : super([]);

  void add(ComboCartEntry entry) {
    final idx = state.indexWhere((e) => e.cartKey == entry.cartKey);
    if (idx >= 0) {
      state = [
        ...state.sublist(0, idx),
        state[idx].copyWith(quantity: state[idx].quantity + 1),
        ...state.sublist(idx + 1),
      ];
    } else {
      state = [...state, entry];
    }
  }

  void remove(String cartKey) {
    final idx = state.indexWhere((e) => e.cartKey == cartKey);
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

  void delete(String cartKey) {
    state = state.where((e) => e.cartKey != cartKey).toList();
  }

  void clear() => state = [];

  int getQuantity(String comboId) {
    final entry = state.where((e) => e.combo.id == comboId).firstOrNull;
    return entry?.quantity ?? 0;
  }
}

final comboCartProvider =
    StateNotifierProvider<ComboCartNotifier, List<ComboCartEntry>>(
        (ref) => ComboCartNotifier());

final comboCartTotalProvider = Provider<double>((ref) {
  return ref.watch(comboCartProvider).fold(0.0, (s, e) => s + e.total);
});
