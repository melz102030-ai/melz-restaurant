import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/models/user_model.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/authentica_service.dart';
import '../../../shared/utils/kitchen_redirect.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/gradient_container.dart';
import '../widgets/otp_verify_sheet.dart';

class StaffLoginScreen extends ConsumerStatefulWidget {
  const StaffLoginScreen({super.key});

  @override
  ConsumerState<StaffLoginScreen> createState() => _StaffLoginScreenState();
}

class _StaffLoginScreenState extends ConsumerState<StaffLoginScreen> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final phone = _phoneController.text.trim();
      final password = _passwordController.text.trim();

      final user = await AuthService.loginStaff(phone, password);

      // إرسال OTP كطبقة تحقق ثانية — أي فشل هنا يُلغي جلسة Firebase أيضاً
      int retryAfter;
      try {
        retryAfter = await AuthenticaService.sendOtp(phone);
      } catch (_) {
        await FirebaseAuth.instance.signOut();
        rethrow;
      }
      if (!mounted) return;

      final otpCode = await showOtpVerifySheet(context, phone: phone, initialRetryAfter: retryAfter);
      if (!mounted) return;

      if (otpCode == null) {
        await FirebaseAuth.instance.signOut();
        return;
      }

      await ref.read(authProvider.notifier).login(user);
      if (!mounted) return;

      switch (user.role) {
        case UserRole.admin:
          context.go('/admin');
          break;
        case UserRole.kitchen:
          redirectToKitchenLite();
          break;
        case UserRole.driver:
          context.go('/driver');
          break;
        case UserRole.customer:
          context.go('/home');
          break;
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AuthService.phonePasswordError(e.code)),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          // الدخول من رابط الإدارة مباشرة (/a/) لا يترك صفحة سابقة للرجوع إليها
          onPressed: () => context.canPop() ? context.pop() : context.go('/home'),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: GradientContainer(
                    borderRadius: 20,
                    padding: const EdgeInsets.all(20),
                    child: Icon(
                      Icons.admin_panel_settings,
                      size: 48,
                      color: Colors.white,
                    ),
                  ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
                ),
                const SizedBox(height: 32),

                Text(
                  'دخول فريق العمل',
                  style: Theme.of(context).textTheme.headlineMedium,
                ).animate().fadeIn(),

                const SizedBox(height: 8),
                Text(
                  'هذه الصفحة مخصصة للإدارة وفريق المطبخ فقط',
                  style: TextStyle(color: AppColors.textSecondary),
                ).animate().fadeIn(delay: 100.ms),

                const SizedBox(height: 40),

                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _phoneController,
                        autofocus: true,
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                        style: TextStyle(color: AppColors.textPrimary),
                        decoration: const InputDecoration(
                          labelText: 'رقم الجوال',
                          prefixIcon: Icon(Icons.phone),
                          hintText: '+966XXXXXXXXX',
                        ),
                        validator: (v) => v == null || v.isEmpty ? 'أدخل رقم الجوال' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _isLoading ? null : _login(),
                        style: TextStyle(color: AppColors.textPrimary),
                        decoration: InputDecoration(
                          labelText: 'كلمة المرور',
                          prefixIcon: Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () =>
                                setState(() => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                        validator: (v) => v == null || v.isEmpty ? 'أدخل كلمة المرور' : null,
                      ),
                      const SizedBox(height: 32),
                      AppButton(
                        label: 'دخول',
                        onPressed: _login,
                        isLoading: _isLoading,
                        icon: Icons.login,
                        width: double.infinity,
                      ).animate().fadeIn(delay: 200.ms),
                      const SizedBox(height: 16),
                      Center(
                        child: TextButton(
                          onPressed: () => showForgotPasswordSheet(context),
                          child: Text(
                            'نسيت كلمة المرور؟',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── ورقة استعادة كلمة المرور ─────────────────────────────────────────────────

Future<void> showForgotPasswordSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _ForgotPasswordSheet(),
  );
}

class _ForgotPasswordSheet extends StatefulWidget {
  const _ForgotPasswordSheet();
  @override
  State<_ForgotPasswordSheet> createState() => _ForgotPasswordSheetState();
}

class _ForgotPasswordSheetState extends State<_ForgotPasswordSheet> {
  // 0 = إدخال الجوال، 1 = كلمة مرور جديدة (بعد تحقق OTP)
  int _step = 0;
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _pass2Ctrl = TextEditingController();
  bool _obscure1 = true;
  bool _obscure2 = true;
  bool _isBusy = false;
  String? _error;
  String? _verifiedPhone;
  String? _verifiedOtp;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    _pass2Ctrl.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    final phone = _phoneCtrl.text.trim();
    if (phone.isEmpty) return;
    setState(() { _isBusy = true; _error = null; });
    int retryAfter;
    try {
      retryAfter = await AuthenticaService.sendOtp(phone);
    } catch (e) {
      if (mounted) setState(() { _error = e.toString().replaceAll('Exception: ', ''); _isBusy = false; });
      return;
    }
    if (!mounted) return;
    setState(() => _isBusy = false);

    // عرض ورقة OTP والانتظار حتى يتحقق المستخدم
    final otpCode = await showOtpVerifySheet(context, phone: phone, initialRetryAfter: retryAfter);
    if (!mounted || otpCode == null) return;

    setState(() {
      _verifiedPhone = AuthenticaService.normalizePhone(phone);
      _verifiedOtp = otpCode;
      _step = 1;
    });
  }

  Future<void> _resetPassword() async {
    final pass = _passCtrl.text.trim();
    final pass2 = _pass2Ctrl.text.trim();
    if (pass.length < 6) {
      setState(() => _error = 'كلمة المرور يجب أن تكون 6 أحرف على الأقل');
      return;
    }
    if (pass != pass2) {
      setState(() => _error = 'كلمتا المرور غير متطابقتين');
      return;
    }
    setState(() { _isBusy = true; _error = null; });
    try {
      await AuthService.resetPasswordByOtp(
        phone: _verifiedPhone!,
        otp: _verifiedOtp!,
        newPassword: pass,
      );
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('تم تعيين كلمة المرور الجديدة — سجّل دخولك الآن'),
        backgroundColor: Colors.green,
      ));
    } catch (e) {
      if (mounted) setState(() { _error = e.toString().replaceAll('Exception: ', ''); _isBusy = false; });
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
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36, height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(color: AppColors.surfaceLight, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            Text(
              _step == 0 ? 'استعادة كلمة المرور' : 'كلمة مرور جديدة',
              style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 4),
            Text(
              _step == 0
                  ? 'أدخل رقم جوالك المسجّل لاستلام رمز التحقق'
                  : 'تم التحقق — اختر كلمة مرور جديدة',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 20),

            if (_step == 0) ...[
              TextField(
                controller: _phoneCtrl,
                autofocus: true,
                keyboardType: TextInputType.phone,
                inputFormatters: [LengthLimitingTextInputFormatter(20)],
                style: TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'رقم الجوال',
                  hintText: '05XXXXXXXX',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
              ),
            ] else ...[
              TextField(
                controller: _passCtrl,
                autofocus: true,
                obscureText: _obscure1,
                style: TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  labelText: 'كلمة المرور الجديدة',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_obscure1 ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _obscure1 = !_obscure1),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _pass2Ctrl,
                obscureText: _obscure2,
                style: TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  labelText: 'تأكيد كلمة المرور',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_obscure2 ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _obscure2 = !_obscure2),
                  ),
                ),
              ),
            ],

            if (_error != null) ...[
              const SizedBox(height: 10),
              Text(_error!, style: TextStyle(color: AppColors.error, fontSize: 13), textAlign: TextAlign.center),
            ],

            const SizedBox(height: 20),
            AppButton(
              label: _step == 0 ? 'إرسال رمز التحقق' : 'تعيين كلمة المرور',
              icon: _step == 0 ? Icons.sms_outlined : Icons.check,
              width: double.infinity,
              onPressed: _step == 0 ? _sendOtp : _resetPassword,
              isLoading: _isBusy,
            ),
          ],
        ),
      ),
    );
  }
}
