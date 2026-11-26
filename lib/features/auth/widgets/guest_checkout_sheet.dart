import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/user_model.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/authentica_service.dart';
import '../../../shared/widgets/app_button.dart';
import 'otp_verify_sheet.dart';

/// دخول العميل برقم جواله (جوال ثم رمز تحقق) — يُعيد المستخدم بعد الدخول، أو null عند الإلغاء.
Future<UserModel?> showCustomerLoginSheet(BuildContext context) async {
  final result = await showModalBottomSheet<Object?>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _GuestCheckoutSheetContent(),
  );
  return result is UserModel ? result : null;
}

/// تعديل رقم التواصل للعميل المسجّل، بلا رمز تحقق.
Future<String?> showGuestCheckoutSheet(
  BuildContext context, {
  required String initialPhone,
}) async {
  final result = await showModalBottomSheet<Object?>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _GuestCheckoutSheetContent(initialPhone: initialPhone),
  );
  return result is String ? result : null;
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

    UserModel? user;
    await showOtpVerifySheet(
      context,
      phone: phone,
      initialRetryAfter: retryAfter,
      verifier: (code) async {
        user = await AuthService.customerLogin(phone: phone, otp: code);
        return user != null;
      },
    );
    if (!mounted) return;
    if (user != null) Navigator.pop(context, user);
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
                label: _isEditing ? 'حفظ' : 'متابعة',
                icon: _isEditing ? Icons.check : Icons.arrow_forward,
                width: double.infinity,
                onPressed: _submit,
                isLoading: _isSendingOtp,
              ),
              if (!_isEditing) ...[
                const SizedBox(height: 14),
                Center(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    children: [
                      Text(
                        'بالمتابعة أنت توافق على ',
                        style: TextStyle(color: AppColors.textHint, fontSize: 11),
                      ),
                      GestureDetector(
                        onTap: () => context.push('/legal/terms_conditions'),
                        child: Text(
                          'الشروط والأحكام',
                          style: TextStyle(color: AppColors.purple, fontSize: 11, decoration: TextDecoration.underline),
                        ),
                      ),
                      Text(
                        ' و',
                        style: TextStyle(color: AppColors.textHint, fontSize: 11),
                      ),
                      GestureDetector(
                        onTap: () => context.push('/legal/privacy_policy'),
                        child: Text(
                          'سياسة الخصوصية',
                          style: TextStyle(color: AppColors.purple, fontSize: 11, decoration: TextDecoration.underline),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
