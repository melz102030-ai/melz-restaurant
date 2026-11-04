import 'order_model.dart';

// ملخص الطلبات لفترة: الإيرادات من المسلَّم فقط، مفصولة عن رسوم التوصيل.
// «الأكثر مبيعاً» يعد ما طلبه العميل: الصنف أو التركيبة نفسها، بدون أصنافها الداخلية،
// ويجمع بمعرّف الصنف فلا يتفرق إذا تغير اسمه، ويعرض أحدث اسم له.
Map<String, dynamic> summarizeOrders(List<OrderModel> orders) {
  var totalRevenue = 0.0;
  var deliveryFees = 0.0;
  var completedOrders = 0;
  var cancelledOrders = 0;
  final sales = <String, _ItemSales>{};

  for (final order in orders) {
    if (order.status == OrderStatus.cancelled) {
      cancelledOrders++;
      continue;
    }
    if (order.status != OrderStatus.delivered) continue;

    completedOrders++;
    totalRevenue += order.total;
    deliveryFees += order.deliveryFee;
    for (final item in order.items) {
      if (item.name.startsWith('↳')) continue;
      final key = item.menuItemId.isEmpty ? item.name : item.menuItemId;
      (sales[key] ??= _ItemSales()).add(item, order.createdAt);
    }
  }

  final ranked = sales.values.toList()..sort((a, b) => b.count.compareTo(a.count));

  return {
    'totalOrders': orders.length,
    'totalRevenue': totalRevenue,
    'salesTotal': totalRevenue - deliveryFees,
    'deliveryFees': deliveryFees,
    'completedOrders': completedOrders,
    'cancelledOrders': cancelledOrders,
    'topItems': ranked.take(5).map((s) => {'name': s.name, 'count': s.count}).toList(),
  };
}

class _ItemSales {
  String name = '';
  int count = 0;
  DateTime? _nameFrom;

  void add(OrderItem item, DateTime orderedAt) {
    count += item.shownQuantity;
    if (_nameFrom == null || orderedAt.isAfter(_nameFrom!)) {
      name = item.name;
      _nameFrom = orderedAt;
    }
  }
}
