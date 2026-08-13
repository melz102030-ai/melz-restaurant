import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/order_model.dart';

// طريقة الاستلام المختارة من الشاشة الرئيسية — تُستخدم كقيمة ابتدائية في شاشة السلة
final orderTypeProvider = StateProvider<OrderType>((ref) => OrderType.delivery);
