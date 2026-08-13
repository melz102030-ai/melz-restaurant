import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../models/order_model.dart';
import '../services/auth_service.dart';
import '../services/order_service.dart';

final allDriversProvider = StreamProvider<List<UserModel>>((ref) {
  return AuthService.streamDrivers();
});

// دعوات تعيين بانتظار ردّ المندوب (قبول/رفض) — قد تصل من لحظة وصول الطلب للمطبخ
final driverInvitationsProvider =
    StreamProvider.family<List<OrderModel>, String>((ref, driverId) {
  return OrderService.streamDriverInvitations(driverId);
});

// الطلبات النشطة التي وافق عليها المندوب (جاهزة للاستلام أو في الطريق) — لوحة المندوب
final driverActiveOrdersProvider =
    StreamProvider.family<List<OrderModel>, String>((ref, driverId) {
  return OrderService.streamDriverOrders(driverId);
});

// أول طلب في طابور المندوب (الأقدم إسناداً) يُعتبر الطلب الحالي، والبقية طابور انتظار
final currentDriverOrderProvider =
    Provider.family<OrderModel?, String>((ref, driverId) {
  final orders = ref.watch(driverActiveOrdersProvider(driverId)).valueOrNull ?? [];
  return orders.isEmpty ? null : orders.first;
});

final queuedDriverOrdersProvider =
    Provider.family<List<OrderModel>, String>((ref, driverId) {
  final orders = ref.watch(driverActiveOrdersProvider(driverId)).valueOrNull ?? [];
  return orders.length > 1 ? orders.sublist(1) : const [];
});
