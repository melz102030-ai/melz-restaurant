import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/menu_item_model.dart';
import '../models/order_model.dart';
import '../models/option_group_model.dart';

const _cartStorageKey = 'saved_cart_v1';

class CartItem {
  final MenuItemModel item;
  final int quantity;
  final List<SelectedOptionGroup> selectedOptions;
  final String? note;

  const CartItem({
    required this.item,
    required this.quantity,
    this.selectedOptions = const [],
    this.note,
  });

  // نفس الصنف بنفس الخيارات لكن ملاحظات مختلفة = عنصران منفصلان في السلة
  String get cartKey {
    final optStr = selectedOptions.isEmpty
        ? ''
        : '_' + selectedOptions.map((g) => '${g.groupId}:${g.selectedIds.join(',')}').join('|');
    final noteStr = (note != null && note!.isNotEmpty) ? '_n:$note' : '';
    return '${item.id}$optStr$noteStr';
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
      CartItem(item: item, quantity: quantity ?? this.quantity, selectedOptions: selectedOptions, note: note);

  Map<String, dynamic> _toLocalJson() => {
        'itemId': item.id,
        'item': item.toMap(),
        'quantity': quantity,
        'selectedOptions': selectedOptions
            .map((g) => {
                  'groupId': g.groupId,
                  'groupName': g.groupName,
                  'selectedIds': g.selectedIds,
                  'selectedNames': g.selectedNames,
                  'totalExtra': g.totalExtra,
                })
            .toList(),
        if (note != null && note!.isNotEmpty) 'note': note,
      };

  static CartItem? _fromLocalJson(Map<String, dynamic> json) {
    try {
      final itemId = json['itemId'] as String;
      final item = MenuItemModel.fromMap(
          Map<String, dynamic>.from(json['item'] as Map), itemId);
      final options = ((json['selectedOptions'] as List?) ?? [])
          .map((o) {
            final m = Map<String, dynamic>.from(o as Map);
            return SelectedOptionGroup(
              groupId: m['groupId'] as String,
              groupName: m['groupName'] as String,
              selectedIds: List<String>.from(m['selectedIds'] ?? const []),
              selectedNames: List<String>.from(m['selectedNames'] ?? const []),
              totalExtra: (m['totalExtra'] as num).toDouble(),
            );
          })
          .toList();
      return CartItem(
        item: item,
        quantity: json['quantity'] as int,
        selectedOptions: options,
        note: json['note'] as String?,
      );
    } catch (_) {
      return null;
    }
  }
}

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]) {
    _restore();
  }

  Future<void> _restore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_cartStorageKey);
      if (raw == null || raw.isEmpty) return;
      final list = jsonDecode(raw) as List;
      final restored = list
          .map((e) => CartItem._fromLocalJson(Map<String, dynamic>.from(e as Map)))
          .whereType<CartItem>()
          .toList();
      if (restored.isNotEmpty) state = restored;
    } catch (_) {
      // تخزين تالف — تُبدأ سلة فارغة بدل تعطّل التطبيق
    }
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (state.isEmpty) {
        await prefs.remove(_cartStorageKey);
      } else {
        await prefs.setString(
            _cartStorageKey, jsonEncode(state.map((c) => c._toLocalJson()).toList()));
      }
    } catch (_) {}
  }

  void addItem(MenuItemModel item, [List<SelectedOptionGroup> options = const [], String? note]) {
    final entry = CartItem(item: item, quantity: 1, selectedOptions: options, note: note);
    final idx = state.indexWhere((c) => c.cartKey == entry.cartKey);
    if (idx >= 0) {
      state = [
        ...state.sublist(0, idx),
        state[idx].copyWith(quantity: state[idx].quantity + 1),
        ...state.sublist(idx + 1),
      ];
    } else {
      state = [...state, entry];
    }
    _persist();
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
    _persist();
  }

  void deleteItem(String cartKey) {
    state = state.where((c) => c.cartKey != cartKey).toList();
    _persist();
  }

  void clear() {
    state = [];
    _persist();
  }

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
          note: c.note,
        )).toList();
  }

  // محذوف — cartKey الآن داخل CartItem مباشرة
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
  final items = ref.watch(cartProvider).fold(0.0, (s, c) => s + c.total);
  // نستورد مجموع التركيبات هنا لتجنب الاعتماد المتبادل بين الـ providers
  // (combo_cart_provider يستورد order_model فقط ولا يعتمد على cart_provider)
  return items;
});

final cartItemCountProvider = Provider<int>((ref) {
  return ref.watch(cartProvider).fold(0, (s, c) => s + c.quantity);
});

// ملاحظة الطلب العامة — تبقى محفوظة أثناء التنقل بين الشاشات
final cartOrderNoteProvider = StateProvider<String>((ref) => '');
