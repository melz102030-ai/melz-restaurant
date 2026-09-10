import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/order_model.dart';

// طريقة الاستلام المختارة من الشاشة الرئيسية — تُستخدم كقيمة ابتدائية في شاشة السلة
// الافتراضي "استلام من المطعم" — العميل يبدّل لـ"توصيل" صراحةً عند رغبته
final orderTypeProvider = StateProvider<OrderType>((ref) => OrderType.pickup);
