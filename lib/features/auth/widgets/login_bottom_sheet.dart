import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/user_model.dart';
import 'phone_password_form.dart';

/// نافذة منبثقة مختصرة لتسجيل الدخول/إنشاء حساب — تُستخدم عند إتمام الطلب
/// بدلاً من الانتقال لصفحة منفصلة. تُرجع true عند نجاح تسجيل الدخول.
Future<bool> showLoginBottomSheet(BuildContext context) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _LoginSheetContent(
      onSuccess: (_) => Navigator.pop(ctx, true),
    ),
  );
  return result ?? false;
}

class _LoginSheetContent extends StatelessWidget {
  final ValueChanged<UserModel> onSuccess;
  const _LoginSheetContent({required this.onSuccess});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints:
          BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          20,
          14,
          20,
          20 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            PhonePasswordForm(onSuccess: onSuccess, compact: true),
          ],
        ),
      ),
    );
  }
}
