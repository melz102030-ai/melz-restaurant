import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/menu_item_model.dart';
import '../models/order_model.dart';
import '../models/option_group_model.dart';

const _cartStorageKey = 'saved_cart_v1';

/// وجبة مضافة على الصنف (بطاطس ومشروب...)، تظهر في السلة والفاتورة كأنها من
/// خياراته وتزيد سعره. الخادم يتحقق منها ويحسب سعرها من جديد
class CartCombo {
  final String comboId;
  final String name;
  final double price;
  final String? optionItemId;
  final List<String> contents;

  const CartCombo({
    required this.comboId,
    required this.name,
    required this.price,
    this.optionItemId,
    this.contents = const [],
  });

  String get key => optionItemId == null ? comboId : '$comboId:$optionItemId';

  String get summary => contents.isEmpty ? name : '$name: ${contents.join('، ')}';

  OrderItemOption toOrderOption() =>
      OrderItemOption(groupName: name, selectedNames: contents, extra: price);

  Map<String, dynamic> toJson() => {
        'comboId': comboId,
        'name': name,
        'price': price,
        if (optionItemId != null) 'optionItemId': optionItemId,
        'contents': contents,
      };

  static CartCombo? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final m = Map<String, dynamic>.from(raw);
    return CartCombo(
      comboId: m['comboId'] as String,
      name: m['name'] as String,
      price: (m['price'] as num).toDouble(),
      optionItemId: m['optionItemId'] as String?,
      contents: List<String>.from(m['contents'] ?? const []),
    );
  }
}

class CartItem {
  final MenuItemModel item;
  final int quantity;
  final List<SelectedOptionGroup> selectedOptions;
  final String? note;
  final CartCombo? combo;

  const CartItem({
    required this.item,
    required this.quantity,
    this.selectedOptions = const [],
    this.note,
    this.combo,
  });

  // نفس الصنف بنفس الخيارات لكن ملاحظات مختلفة = عنصران منفصلان في السلة
  String get cartKey {
    final optStr = selectedOptions.isEmpty
        ? ''
        : '_' + selectedOptions.map((g) => '${g.groupId}:${g.selectedIds.join(',')}').join('|');
    final noteStr = (note != null && note!.isNotEmpty) ? '_n:$note' : '';
    final comboStr = combo == null ? '' : '_c:${combo!.key}';
    return '${item.id}$optStr$comboStr$noteStr';
  }

  double get optionsExtra =>
      selectedOptions.fold(0.0, (s, g) => s + g.totalExtra) + (combo?.price ?? 0);

  // مجموع عدد الخيارات المختارة — selectedIds بصيغة "id" أو "id*3"
  int get totalOptionsQuantity =>
      quantity *
      selectedOptions.expand((g) => g.selectedIds).fold<int>(0, (sum, id) {
        final star = id.lastIndexOf('*');
        return sum + (star < 0 ? 1 : int.tryParse(id.substring(star + 1)) ?? 1);
      });

  // الكمية الظاهرة للعميل: صنف لا يُحتسب سعره كميته مجموع خياراته (٨ صوصات لا ١)
  int get shownQuantity =>
      item.excludeBasePrice && selectedOptions.isNotEmpty ? totalOptionsQuantity : quantity;

  // خيار واحد بكل سطر مع عدده الفعلي، حتى لو أُضيفت نفس التركيبة أكثر من مرة
  List<String> get optionLines => [
        for (final g in selectedOptions)
          for (var i = 0; i < g.selectedNames.length && i < g.selectedIds.length; i++)
            _optionLine(g.selectedIds[i], g.selectedNames[i]),
        if (combo != null) combo!.summary,
      ];

  String _optionLine(String id, String name) {
    final star = id.lastIndexOf('*');
    final count = star < 0 ? 1 : int.tryParse(id.substring(star + 1)) ?? 1;
    final total = count * quantity;
    // السلة المحفوظة قد تحمل الصيغة الأقدم "صوص ×5" فيُزال الرقم من الطرفين
    final baseName = name.replaceAll(RegExp(r'^×\d+ | ×\d+$'), '');
    return '×$total $baseName';
  }

  double get unitPrice => item.chargedBasePrice + optionsExtra;
  double get total => unitPrice * quantity;

  String get optionsSummary => [
        ...selectedOptions.where((g) => g.selectedNames.isNotEmpty).map((g) => g.summary),
        if (combo != null) combo!.summary,
      ].join(' · ');

  // ما يُرسل للخادم عند إنشاء الطلب — معرّفات وكميات فقط بلا أي سعر
  Map<String, dynamic> toOrderRequest() => {
        'itemId': item.id,
        'quantity': quantity,
        'options': selectedOptions
            .map((g) => {'groupId': g.groupId, 'selectedIds': g.selectedIds})
            .toList(),
        if (note != null && note!.isNotEmpty) 'note': note,
        if (combo != null) 'comboId': combo!.comboId,
        if (combo?.optionItemId != null) 'comboOptionItemId': combo!.optionItemId,
      };

  // يعيد بناء العنصر من بيانات الصنف الحية بأسعارها الحالية، ويعيد null إن لم
  // تعد خياراته صالحة (خيار حُذف أو توقف، أو مجموعة إجبارية أُضيفت بعد إضافته)
  CartItem? _rebuiltFrom(MenuItemModel live) {
    final groups = <SelectedOptionGroup>[];
    for (final sel in selectedOptions) {
      final group = live.optionGroups.where((g) => g.id == sel.groupId).firstOrNull;
      if (group == null) return null;
      var extra = 0.0;
      final names = <String>[];
      for (final raw in sel.selectedIds) {
        final star = raw.lastIndexOf('*');
        final id = star < 0 ? raw : raw.substring(0, star);
        final count = star < 0 ? 1 : int.tryParse(raw.substring(star + 1)) ?? 1;
        final opt = group.options.where((o) => o.id == id && o.isAvailable).firstOrNull;
        if (opt == null || (count > 1 && !group.allowQuantity)) return null;
        extra += opt.priceAdjustment * count;
        names.add(group.allowQuantity || live.excludeBasePrice ? '×$count ${opt.name}' : opt.name);
      }
      groups.add(SelectedOptionGroup(
        groupId: group.id,
        groupName: group.name,
        selectedIds: sel.selectedIds,
        selectedNames: names,
        totalExtra: extra,
      ));
    }
    final missingRequired = live.optionGroups
        .any((g) => g.required && !groups.any((s) => s.groupId == g.id));
    if (missingRequired) return null;
    return CartItem(item: live, quantity: quantity, selectedOptions: groups, note: note, combo: combo);
  }

  CartItem copyWith({int? quantity}) => CartItem(
      item: item,
      quantity: quantity ?? this.quantity,
      selectedOptions: selectedOptions,
      note: note,
      combo: combo);

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
        if (combo != null) 'combo': combo!.toJson(),
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
        combo: CartCombo.fromJson(json['combo']),
      );
    } catch (_) {
      return null;
    }
  }
}

// نتيجة مطابقة السلة مع القائمة الحية، لإبلاغ العميل بما تغيّر
class CartSyncResult {
  final List<String> removedNames;
  final bool pricesChanged;
  const CartSyncResult({required this.removedNames, required this.pricesChanged});
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

  void addItem(MenuItemModel item,
      [List<SelectedOptionGroup> options = const [], String? note, CartCombo? combo]) {
    final entry =
        CartItem(item: item, quantity: 1, selectedOptions: options, note: note, combo: combo);
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

  // السلة محفوظة في الجهاز بنسخة من الصنف، فتُطابَق مع القائمة الحية عند فتحها:
  // تُحدَّث الأسعار ويُحذف ما توقف، حتى لا يرى العميل سعراً قديماً أو صنفاً نفد
  CartSyncResult syncWithMenu(List<MenuItemModel> menu) {
    final byId = {for (final m in menu) m.id: m};
    final synced = <CartItem>[];
    final removed = <String>[];
    var changed = false;
    for (final entry in state) {
      final live = byId[entry.item.id];
      final rebuilt = live == null || !live.isAvailable ? null : entry._rebuiltFrom(live);
      if (rebuilt == null) {
        removed.add(entry.item.name);
        continue;
      }
      if ((rebuilt.total - entry.total).abs() > 0.001) changed = true;
      synced.add(rebuilt);
    }
    state = synced;
    _persist();
    return CartSyncResult(removedNames: removed, pricesChanged: changed);
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
      state.where((c) => c.item.id == itemId).fold(0, (s, c) => s + c.shownQuantity);

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
              .toList()
            ..addAll([if (c.combo != null) c.combo!.toOrderOption()]),
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
  return ref.watch(cartProvider).fold(0, (s, c) => s + c.shownQuantity);
});

// ملاحظة الطلب العامة — تبقى محفوظة أثناء التنقل بين الشاشات
final cartOrderNoteProvider = StateProvider<String>((ref) => '');
