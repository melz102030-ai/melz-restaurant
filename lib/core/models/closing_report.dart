import 'order_model.dart';

// ملخص إغلاق يوم عمل واحد حسب طريقة الدفع — ما يُفترض وجوده في الدرج وما ينتظر
// مراجعة. كل طلب غير ملغى يدخل بند دفع واحد، حتى يطابق المجموع ما حُصِّل فعلاً.
class ClosingReport {
  final int totalOrders;
  final int deliveredCount;
  final double deliveredTotal;
  final int cashCount;
  final double cashTotal;
  final int transferConfirmedCount;
  final double transferConfirmedTotal;
  final int transferPendingCount;
  final double transferPendingTotal;
  final int electronicCount;
  final double electronicTotal;
  final int cancelledCount;
  final double cancelledTotal;
  // طلبات لم تكتمل بعد، فأرقام اليوم ليست نهائية ما دامت موجودة
  final int openCount;
  final double openTotal;

  const ClosingReport({
    required this.totalOrders,
    required this.deliveredCount,
    required this.deliveredTotal,
    required this.cashCount,
    required this.cashTotal,
    required this.transferConfirmedCount,
    required this.transferConfirmedTotal,
    required this.transferPendingCount,
    required this.transferPendingTotal,
    required this.electronicCount,
    required this.electronicTotal,
    required this.cancelledCount,
    required this.cancelledTotal,
    required this.openCount,
    required this.openTotal,
  });

  factory ClosingReport.fromOrders(List<OrderModel> orders) {
    var deliveredCount = 0, cashCount = 0, transferConfirmedCount = 0;
    var transferPendingCount = 0, electronicCount = 0, cancelledCount = 0, openCount = 0;
    var deliveredTotal = 0.0, cashTotal = 0.0, transferConfirmedTotal = 0.0;
    var transferPendingTotal = 0.0, electronicTotal = 0.0, cancelledTotal = 0.0, openTotal = 0.0;

    for (final o in orders) {
      if (o.status == OrderStatus.cancelled) {
        cancelledCount++;
        cancelledTotal += o.total;
        continue;
      }
      final isDelivered = o.status == OrderStatus.delivered;
      if (isDelivered) {
        deliveredCount++;
        deliveredTotal += o.total;
      } else {
        openCount++;
        openTotal += o.total;
      }

      switch (o.paymentMethod) {
        case PaymentMethod.cash:
          // النقد يدخل الدرج عند التسليم فقط
          if (isDelivered) {
            cashCount++;
            cashTotal += o.total;
          }
        case PaymentMethod.manualBankTransfer:
          if (o.paymentStatus == PaymentStatus.paid) {
            transferConfirmedCount++;
            transferConfirmedTotal += o.total;
          } else {
            transferPendingCount++;
            transferPendingTotal += o.total;
          }
        case PaymentMethod.card:
        case PaymentMethod.applePay:
        case PaymentMethod.mada:
        case PaymentMethod.leanBankTransfer:
          if (o.paymentStatus == PaymentStatus.paid) {
            electronicCount++;
            electronicTotal += o.total;
          }
      }
    }

    return ClosingReport(
      totalOrders: orders.length,
      deliveredCount: deliveredCount,
      deliveredTotal: deliveredTotal,
      cashCount: cashCount,
      cashTotal: cashTotal,
      transferConfirmedCount: transferConfirmedCount,
      transferConfirmedTotal: transferConfirmedTotal,
      transferPendingCount: transferPendingCount,
      transferPendingTotal: transferPendingTotal,
      electronicCount: electronicCount,
      electronicTotal: electronicTotal,
      cancelledCount: cancelledCount,
      cancelledTotal: cancelledTotal,
      openCount: openCount,
      openTotal: openTotal,
    );
  }
}
