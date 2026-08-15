import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

// ينفّذ عملية غير متزامنة (حذف/تفعيل...) ويعرض رسالة خطأ عبر SnackBar إن
// فشلت، بدل تجاهل الفشل بصمت كما كان معمولاً به في عدة أزرار بلوحة الإدارة.
// successMessage اختياري — يُستخدم لعمليات غير متكررة كالحذف (حيث التأكيد
// الصريح مفيد)، ويُترك فارغاً لعمليات متكررة كالتفعيل/التعطيل (لها بالفعل
// تغذية راجعة فورية عبر تغيّر المفتاح نفسه، فرسالة إضافية في كل مرة إزعاج لا فائدة منه)
Future<void> runOrShowError(
  BuildContext context,
  Future<void> Function() action, {
  String? successMessage,
}) async {
  try {
    await action();
    if (successMessage != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(successMessage),
        backgroundColor: AppColors.success,
      ));
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString().replaceAll('Exception: ', '')),
        backgroundColor: AppColors.error,
      ));
    }
  }
}
