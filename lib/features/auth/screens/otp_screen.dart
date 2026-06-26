import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/models/user_model.dart';
import '../../../shared/widgets/app_button.dart';

class OtpScreen extends ConsumerStatefulWidget {
  final String phone;
  const OtpScreen({super.key, required this.phone});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  bool _isLoading = false;
  bool _isSending = false;
  int _resendSeconds = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    super.dispose();
  }

  void _startTimer() {
    _resendSeconds = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      if (_resendSeconds <= 0) {
        t.cancel();
      } else {
        setState(() => _resendSeconds--);
      }
    });
  }

  Future<void> _resendOtp() async {
    setState(() => _isSending = true);
    try {
      await AuthService.sendOtp(widget.phone);
      _startTimer();
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_firebaseError(e.code)),
        backgroundColor: AppColors.error,
      ));
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  Future<void> _verify() async {
    final code = _controllers.map((c) => c.text).join();
    if (code.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('أدخل رمز التحقق كاملاً')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final user = await AuthService.verifyOtp(code);
      await ref.read(authProvider.notifier).login(user);
      if (!mounted) return;
      _navigateByRole(user.role);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_firebaseError(e.code)),
        backgroundColor: AppColors.error,
      ));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('خطأ: $e'),
        backgroundColor: AppColors.error,
      ));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _navigateByRole(UserRole role) {
    switch (role) {
      case UserRole.admin:   context.go('/admin');   break;
      case UserRole.kitchen: context.go('/kitchen'); break;
      case UserRole.customer: context.go('/home');   break;
    }
  }

  void _onDigitEntered(int index, String value) {
    if (value.length == 6) {
      for (int i = 0; i < 6; i++) _controllers[i].text = value[i];
      _verify();
      return;
    }
    if (value.isNotEmpty && index < 5) { _focusNodes[index + 1].requestFocus(); }
    if (value.isEmpty && index > 0)    { _focusNodes[index - 1].requestFocus(); }
  }

  String _firebaseError(String code) {
    switch (code) {
      case 'invalid-verification-code': return 'رمز التحقق غير صحيح';
      case 'session-expired':           return 'انتهت صلاحية الرمز، أعد الإرسال';
      case 'too-many-requests':         return 'طلبات كثيرة، حاول لاحقاً';
      default:                          return 'خطأ: $code';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.purple.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.purple.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: const Icon(Icons.sms_outlined,
                      color: AppColors.purple, size: 40),
                ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),

                const SizedBox(height: 24),

                Text(
                  AppStrings.verifyOtp,
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ).animate().fadeIn(),

                const SizedBox(height: 12),

                const Text(
                  'تم إرسال رمز التحقق عبر SMS إلى',
                  style: TextStyle(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 100.ms),

                const SizedBox(height: 4),

                Text(
                  widget.phone,
                  style: const TextStyle(
                    color: AppColors.purple,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    letterSpacing: 1,
                  ),
                ).animate().fadeIn(delay: 200.ms),

                const SizedBox(height: 40),

                // OTP boxes - forced LTR so digits appear left-to-right
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(6, (i) {
                      return Container(
                        width: 48,
                        height: 56,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        child: TextFormField(
                          controller: _controllers[i],
                          focusNode: _focusNodes[i],
                          textAlign: TextAlign.center,
                          textDirection: TextDirection.ltr,
                          keyboardType: TextInputType.number,
                          maxLength: 1,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(6),
                          ],
                          decoration: InputDecoration(
                            counterText: '',
                            filled: true,
                            fillColor: AppColors.surfaceLight,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppColors.purple, width: 2),
                            ),
                          ),
                          onChanged: (v) => _onDigitEntered(i, v),
                        ),
                      );
                    }),
                  ),
                ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),

                const SizedBox(height: 32),

                AppButton(
                  label: AppStrings.verifyOtp,
                  onPressed: _verify,
                  isLoading: _isLoading,
                  icon: Icons.check_circle,
                  width: double.infinity,
                ).animate().fadeIn(delay: 400.ms),

                const SizedBox(height: 24),

                // Resend timer
                if (_resendSeconds > 0)
                  Text(
                    'إعادة الإرسال بعد $_resendSeconds ثانية',
                    style: const TextStyle(color: AppColors.textHint),
                  )
                else
                  TextButton.icon(
                    onPressed: _isSending ? null : _resendOtp,
                    icon: _isSending
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.refresh),
                    label: const Text(AppStrings.resendOtp),
                    style: TextButton.styleFrom(
                        foregroundColor: AppColors.purple),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
