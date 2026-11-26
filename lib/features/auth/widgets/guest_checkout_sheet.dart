import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/authentica_service.dart';
import '../../../shared/widgets/app_button.dart';
import 'otp_verify_sheet.dart';

/// نافذة منبثقة مختصرة جداً لإتمام الطلب بلا تسجيل دخول (وضع "ضيف") —
/// اسم ورقم جوال فقط، بلا كلمة مرور ولا أي خطوة إضافية. راجع
/// AuthService.guestLogin لما يحدث خلف الكواليس بعد الإرسال.
/// تمرير الاسم والرقم الحاليين يعرضها للتعديل، بدل أول إدخال عند أول طلب.
Future<String?> showGuestCheckoutSheet(
  BuildContext context, {
  String? initialPhone,
}) {
  return showModalBottomSheet<String?>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _GuestCheckoutSheetContent(initialPhone: initialPhone),
  );
}

class _GuestCheckoutSheetContent extends StatefulWidget {
  final String? initialPhone;
  const _GuestCheckoutSheetContent({this.initialPhone});

  @override
  State<_GuestCheckoutSheetContent> createState() => _GuestCheckoutSheetContentState();
}

class _GuestCheckoutSheetContentState extends State<_GuestCheckoutSheetContent> {
  final _formKey = GlobalKey<FormState>();
  late final _phoneCtrl = TextEditingController(text: widget.initialPhone);
  bool _isSendingOtp = false;
  String? _otpError;

  bool get _isEditing => widget.initialPhone != null;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final phone = _phoneCtrl.text.trim();

    // في وضع التعديل لا نُعيد التحقق من الرقم
    if (_isEditing) {
      Navigator.pop(context, phone);
      return;
    }

    setState(() { _isSendingOtp = true; _otpError = null; });
    int retryAfter;
    try {
      retryAfter = await AuthenticaService.sendOtp(phone);
    } catch (e) {
      if (mounted) setState(() { _otpError = e.toString().replaceAll('Exception: ', ''); _isSendingOtp = false; });
      return;
    }
    if (!mounted) return;
    setState(() => _isSendingOtp = false);

    final otpCode = await showOtpVerifySheet(context, phone: phone, initialRetryAfter: retryAfter);
    if (!mounted) return;
    if (otpCode != null) {
      Navigator.pop(context, phone);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
        child: Form(
          key: _formKey,
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
              Text('رقم جوالك',
                  style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 4),
              Text(
                _isEditing
                    ? 'سيتواصل معك المطعم على هذا الرقم بخصوص طلبك'
                    : 'أدخل رقم جوالك لإتمام الطلب',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
              ),
              const SizedBox(height: 14),
              if (!_isEditing)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.purple.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.purple.withValues(alpha: 0.2)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.verified_user_outlined,
                        color: AppColors.purple, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'سيُرسَل رمز تحقق للتأكد من رقمك — لن يتكرر في طلباتك القادمة',
                        style: TextStyle(color: AppColors.purple, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _phoneCtrl,
                autofocus: true,
                keyboardType: TextInputType.phone,
                inputFormatters: [LengthLimitingTextInputFormatter(20)],
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _submit(),
                style: TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'رقم الجوال',
                  hintText: '05XXXXXXXX',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                validator: (v) {
                  final digits = (v ?? '').replaceAll(RegExp(r'\D'), '');
                  return digits.length < 9 ? 'رقم جوال غير صحيح' : null;
                },
              ),
              if (_otpError != null) ...[
                const SizedBox(height: 10),
                Text(
                  _otpError!,
                  style: TextStyle(color: AppColors.error, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 22),
              AppButton(
                label: _isEditing ? 'حفظ' : 'متابعة الطلب',
                icon: _isEditing ? Icons.check : Icons.arrow_forward,
                width: double.infinity,
                onPressed: _submit,
                isLoading: _isSendingOtp,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
