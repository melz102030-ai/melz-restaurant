import 'package:flutter_test/flutter_test.dart';
import 'package:melz_restaurant/core/models/closing_report.dart';
import 'package:melz_restaurant/core/models/order_model.dart';
import 'package:melz_restaurant/core/models/orders_summary.dart';

OrderItem _item(String id, String name, int quantity, {double price = 10}) => OrderItem(
      menuItemId: id,
      name: name,
      price: price,
      quantity: quantity,
      selectedOptions: const [],
    );

OrderModel _order({
  required double total,
  double deliveryFee = 0,
  OrderStatus status = OrderStatus.delivered,
  List<OrderItem> items = const [],
  DateTime? at,
  PaymentMethod method = PaymentMethod.manualBankTransfer,
  PaymentStatus payment = PaymentStatus.paid,
}) {
  final time = at ?? DateTime(2026, 11, 3);
  return OrderModel(
    id: 'x',
    customerId: 'c',
    customerName: 'عميل',
    customerPhone: '05',
    items: items,
    subtotal: total - deliveryFee,
    deliveryFee: deliveryFee,
    total: total,
    status: status,
    createdAt: time,
    updatedAt: time,
    paymentMethod: method,
    paymentStatus: payment,
  );
}

void main() {
  test('الإيرادات مفصولة عن رسوم التوصيل، ومن المسلَّم فقط', () {
    final s = summarizeOrders([
      _order(total: 60, deliveryFee: 10),
      _order(total: 40),
      _order(total: 500, status: OrderStatus.cancelled),
      _order(total: 300, status: OrderStatus.preparing),
    ]);
    expect(s['totalRevenue'], 100);
    expect(s['deliveryFees'], 10);
    expect(s['salesTotal'], 90);
    expect(s['totalOrders'], 4);
    expect(s['completedOrders'], 2);
    expect(s['cancelledOrders'], 1);
  });

  test('الأكثر مبيعاً يجمع بالمعرّف ويعرض أحدث اسم، بدون أصناف التركيبة الداخلية', () {
    final s = summarizeOrders([
      _order(total: 10, at: DateTime(2026, 11, 1), items: [_item('b', 'برجر قديم', 2)]),
      _order(total: 10, at: DateTime(2026, 11, 3), items: [_item('b', 'برجر', 3)]),
      _order(total: 30, at: DateTime(2026, 11, 2), items: [
        _item('combo_c1', 'تركيبة: وجبة', 1, price: 30),
        _item('b', '↳ برجر قديم', 1, price: 0),
      ]),
    ]);
    expect(s['topItems'], [
      {'name': 'برجر', 'count': 5},
      {'name': 'تركيبة: وجبة', 'count': 1},
    ]);
  });

  test('ملخصات الأيام المحفوظة تعطي نفس نتيجة قراءة كل الطلبات', () {
    final orders = [
      _order(total: 60, deliveryFee: 10, at: DateTime(2026, 11, 1), items: [_item('b', 'برجر قديم', 2)]),
      _order(total: 40, at: DateTime(2026, 11, 2), items: [_item('b', 'برجر', 3)]),
      _order(total: 500, status: OrderStatus.cancelled, at: DateTime(2026, 11, 2)),
      _order(total: 300, status: OrderStatus.preparing, at: DateTime(2026, 11, 3)),
    ];
    final days = summarizeByDay(orders, (at) => '${at.day}');
    expect(days.length, 3);

    // كما لو حُفظت في Firestore ثم قُرئت
    final merged = DaySummary();
    for (final day in days.values) {
      merged.merge(DaySummary.fromMap(day.toMap()));
    }
    expect(merged.toReport(), summarizeOrders(orders));
  });

  test('إغلاق اليوم يبين المدفوع الملغى حتى يُسترجع، ولا يدخله في المحصَّل', () {
    final r = ClosingReport.fromOrders([
      _order(total: 50, status: OrderStatus.cancelled),
      _order(total: 20, status: OrderStatus.cancelled, payment: PaymentStatus.refunded),
      _order(total: 30, status: OrderStatus.cancelled, payment: PaymentStatus.pending),
    ]);
    expect(r.refundDueCount, 1);
    expect(r.refundDueTotal, 50);
    expect(r.refundedCount, 1);
    expect(r.refundedTotal, 20);
    expect(r.transferConfirmedCount, 0);
    expect(r.cancelledCount, 3);
  });
}
