import 'package:flutter_test/flutter_test.dart';
import 'package:melz_restaurant/core/models/closing_report.dart';
import 'package:melz_restaurant/core/models/order_model.dart';

OrderModel _order(
  double total,
  OrderStatus status, {
  PaymentMethod method = PaymentMethod.cash,
  PaymentStatus payment = PaymentStatus.pending,
}) {
  final now = DateTime(2026, 11, 3);
  return OrderModel(
    id: 'x',
    customerId: 'c',
    customerName: 'عميل',
    customerPhone: '05',
    items: const [],
    subtotal: total,
    deliveryFee: 0,
    total: total,
    status: status,
    createdAt: now,
    updatedAt: now,
    paymentMethod: method,
    paymentStatus: payment,
  );
}

void main() {
  test('النقد يُحسب عند التسليم فقط، والملغى خارج الدرج', () {
    final r = ClosingReport.fromOrders([
      _order(20, OrderStatus.delivered),
      _order(30, OrderStatus.delivered),
      _order(15, OrderStatus.preparing),
      _order(50, OrderStatus.cancelled),
    ]);
    expect(r.totalOrders, 4);
    expect(r.cashCount, 2);
    expect(r.cashTotal, 50);
    expect(r.deliveredTotal, 50);
    expect(r.openCount, 1);
    expect(r.openTotal, 15);
    expect(r.cancelledCount, 1);
    expect(r.cancelledTotal, 50);
  });

  test('التحويل البنكي: مؤكد وينتظر مراجعة، والملغى خارجهما', () {
    final r = ClosingReport.fromOrders([
      _order(40, OrderStatus.delivered,
          method: PaymentMethod.manualBankTransfer, payment: PaymentStatus.paid),
      _order(25, OrderStatus.confirmed, method: PaymentMethod.manualBankTransfer),
      _order(99, OrderStatus.cancelled, method: PaymentMethod.manualBankTransfer),
    ]);
    expect(r.transferConfirmedCount, 1);
    expect(r.transferConfirmedTotal, 40);
    expect(r.transferPendingCount, 1);
    expect(r.transferPendingTotal, 25);
    expect(r.cashTotal, 0);
  });

  test('الدفع الإلكتروني يُحسب إذا كان مدفوعاً فقط', () {
    final r = ClosingReport.fromOrders([
      _order(60, OrderStatus.delivered, method: PaymentMethod.mada, payment: PaymentStatus.paid),
      _order(70, OrderStatus.pending, method: PaymentMethod.card),
    ]);
    expect(r.electronicCount, 1);
    expect(r.electronicTotal, 60);
  });

  test('يوم بلا طلبات', () {
    final r = ClosingReport.fromOrders(const []);
    expect(r.totalOrders, 0);
    expect(r.cashTotal, 0);
  });
}
