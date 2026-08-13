import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/user_model.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/services/auth_service.dart';
import '../../../shared/widgets/animated_photo_collage.dart';
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

class _LoginSheetContent extends ConsumerStatefulWidget {
  final ValueChanged<UserModel> onSuccess;
  const _LoginSheetContent({required this.onSuccess});

  @override
  ConsumerState<_LoginSheetContent> createState() => _LoginSheetContentState();
}

class _LoginSheetContentState extends ConsumerState<_LoginSheetContent> {
  bool _quickLoading = false;

  Future<void> _quickCustomerLogin() async {
    if (_quickLoading) return;
    setState(() => _quickLoading = true);
    try {
      final user = await AuthService.quickPreviewLogin(UserRole.customer);
      await ref.read(authProvider.notifier).login(user);
      if (!mounted) return;
      widget.onSuccess(user);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('خطأ: $e'),
        backgroundColor: AppColors.error,
      ));
    } finally {
      if (mounted) setState(() => _quickLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: Container(
        constraints:
            BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
        color: AppColors.surface,
        child: Stack(
          children: [
            const Positioned.fill(child: AnimatedPhotoCollageBackground()),
            Positioned.fill(child: CollageScrim(color: AppColors.surface)),
            SingleChildScrollView(
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
                  PhonePasswordForm(onSuccess: widget.onSuccess, compact: true),
                  const SizedBox(height: 16),
                  _QuickCustomerPreviewButton(
                    isLoading: _quickLoading,
                    onTap: _quickCustomerLogin,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── دخول سريع كعميل بدون بيانات — لمرحلة المعاينة فقط ───────────────────────
class _QuickCustomerPreviewButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onTap;
  const _QuickCustomerPreviewButton({required this.isLoading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: isLoading ? null : onTap,
      icon: isLoading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.amber),
            )
          : Icon(Icons.flash_on, size: 18, color: Colors.amber),
      label: const Text('معاينة سريعة — دخول كعميل مباشرة'),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.amber.shade800,
        side: BorderSide(color: Colors.amber.withValues(alpha: 0.5)),
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
