import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

// ينفّذ عملية غير متزامنة (حذف/تفعيل...) ويعرض رسالة خطأ عبر SnackBar إن
// فشلت، بدل تجاهل الفشل بصمت كما كان معمولاً به في عدة أزرار بلوحة الإدارة
Future<void> runOrShowError(BuildContext context, Future<void> Function() action) async {
  try {
    await action();
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString().replaceAll('Exception: ', '')),
        backgroundColor: AppColors.error,
      ));
    }
  }
}
