import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/combo_model.dart';
import '../../../core/models/menu_item_model.dart';
import '../../../core/models/option_group_model.dart';
import '../../../core/models/order_model.dart';
import '../../../core/providers/cart_provider.dart';
import '../../../core/providers/combo_cart_provider.dart';
import '../providers/menu_provider.dart';

/// نتيجة إعادة أصناف طلب إلى السلة
class OrderToCartResult {
  final int added;
  final List<String> skippedNames;
  const OrderToCartResult(this.added, this.skippedNames);
}

/// يعيد أصناف طلب سابق إلى السلة بأسعار القائمة الحالية: الخيارات تُطابق بالاسم،
/// والوجبة المختارة على الصنف تعود معه، والوجبة المستقلة تعود بصنفها المختار.
/// [skipIds] أصناف لا تُعاد (مثل ما أبلغ المطبخ بنفاده)، وما لم يعد متوفراً يُتخطى.
Future<OrderToCartResult> addOrderToCart(
  WidgetRef ref,
  OrderModel order, {
  Set<String> skipIds = const {},
}) async {
  final catalog = await ref.read(menuItemsStreamProvider(null).future);
  final combos = ref.read(activeCombosProvider).valueOrNull ?? const <ComboModel>[];
  final cart = ref.read(cartProvider.notifier);
  final comboCart = ref.read(comboCartProvider.notifier);
  MenuItemModel? liveItem(String id) =>
      catalog.where((m) => m.id == id && m.isAvailable).firstOrNull;

  var added = 0;
  final skipped = <String>[];
  final items = order.items;

  for (var i = 0; i < items.length; i++) {
    final oi = items[i];

    // وجبة مستقلة: سطر رأس ثم أصنافها بسعر صفر (↳)
    if (oi.menuItemId.startsWith('combo_')) {
      final subs = <OrderItem>[];
      while (i + 1 < items.length && items[i + 1].name.startsWith('↳ ')) {
        subs.add(items[++i]);
      }
      final combo = combos.where((c) => 'combo_${c.id}' == oi.menuItemId).firstOrNull;
      final blocked = subs.any((s) => skipIds.contains(s.menuItemId) || liveItem(s.menuItemId) == null);
      if (combo == null || blocked) {
        skipped.add(oi.name);
        continue;
      }
      final chosen = subs
          .map((s) => s.menuItemId)
          .where((id) => combo.optionItemIds.contains(id))
          .firstOrNull;
      final subItems = [
        ...combo.items.map((r) => liveItem(r.itemId)).whereType<MenuItemModel>(),
        if (chosen != null && liveItem(chosen) != null) liveItem(chosen)!,
      ];
      for (var q = 0; q < oi.quantity; q++) {
        comboCart.add(ComboCartEntry(
          combo: combo,
          subSelections: subItems.map((m) => ComboSubSelection(item: m)).toList(),
        ));
      }
      added++;
      continue;
    }
    if (oi.name.startsWith('↳ ')) continue;

    final current = skipIds.contains(oi.menuItemId) ? null : liveItem(oi.menuItemId);
    if (current == null) {
      skipped.add(oi.name);
      continue;
    }

    final selectedGroups = <SelectedOptionGroup>[];
    CartCombo? meal;
    for (final opt in oi.selectedOptions) {
      final group = current.optionGroups.where((g) => g.name == opt.groupName).firstOrNull;
      if (group == null) {
        // ليست مجموعة خيارات: وجبة مختارة على الصنف باسمها
        meal ??= _mealFor(current, opt, combos, catalog);
        continue;
      }
      // الأسماء قد تحمل عدداً ("×2 جبن"، والأقدم "جبن ×2"). صنف لا يُحتسب سعره
      // يُحفظ عدد خياراته مضروباً في كمية الصنف، فيُقسم هنا لتفادي مضاعفته
      final qtyByName = <String, int>{};
      for (final n in opt.selectedNames) {
        final m = RegExp(r'^×(\d+) (.*)$').firstMatch(n);
        final old = RegExp(r'^(.*) ×(\d+)$').firstMatch(n);
        if (m != null) {
          final perUnit = current.excludeBasePrice ? oi.quantity : 1;
          qtyByName[m.group(2)!] = int.parse(m.group(1)!) ~/ perUnit;
        } else if (old != null) {
          qtyByName[old.group(1)!] = int.parse(old.group(2)!);
        } else {
          qtyByName[n] = 1;
        }
      }
      final matched =
          group.availableOptions.where((o) => qtyByName.containsKey(o.name)).toList();
      if (matched.isEmpty) continue;
      int q(ItemOption o) => group.allowQuantity ? qtyByName[o.name]! : 1;
      selectedGroups.add(SelectedOptionGroup(
        groupId: group.id,
        groupName: group.name,
        selectedIds: matched.map((o) => q(o) > 1 ? '${o.id}*${q(o)}' : o.id).toList(),
        selectedNames: matched
            .map((o) => group.allowQuantity || current.excludeBasePrice ? '×${q(o)} ${o.name}' : o.name)
            .toList(),
        totalExtra: matched.fold(0.0, (s, o) => s + o.priceAdjustment * q(o)),
      ));
    }

    for (var q = 0; q < oi.quantity; q++) {
      cart.addItem(current, selectedGroups, oi.note, meal);
    }
    added++;
  }
  return OrderToCartResult(added, skipped);
}

CartCombo? _mealFor(
  MenuItemModel item,
  OrderItemOption opt,
  List<ComboModel> combos,
  List<MenuItemModel> catalog,
) {
  final combo = combos
      .where((c) => c.name == opt.groupName && c.linkedItemIds.contains(item.id))
      .firstOrNull;
  if (combo == null) return null;
  String? nameOf(String id) =>
      catalog.where((m) => m.id == id && m.isAvailable).firstOrNull?.name;
  final optionId = combo.optionItemIds
      .where((id) => opt.selectedNames.contains(nameOf(id)))
      .firstOrNull;
  if (combo.optionItemIds.isNotEmpty && optionId == null) return null;
  if (combo.items.any((r) => nameOf(r.itemId) == null)) return null;
  return CartCombo(
    comboId: combo.id,
    name: combo.name,
    price: combo.price,
    optionItemId: optionId,
    contents: [if (optionId != null) nameOf(optionId)!],
  );
}
