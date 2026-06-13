import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/models/user_model.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/gradient_container.dart';

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
  String? _devOtp; // For development only
  int _resendSeconds = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _sendOtp();
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
      if (_resendSeconds <= 0) {
        t.cancel();
      } else {
        setState(() => _resendSeconds--);
      }
    });
  }

  Future<void> _sendOtp() async {
    setState(() => _isSending = true);
    final settings = ref.read(settingsProvider);
    try {
      final otp = await AuthService.sendOtp(
        widget.phone,
        settings.whatsappNumber,
      );
      // Dev only: show OTP
      setState(() => _devOtp = otp);
      _startTimer();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  Future<void> _verify() async {
    final otp = _controllers.map((c) => c.text).join();
    if (otp.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('أدخل رمز التحقق كاملاً')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final valid = await AuthService.verifyOtp(widget.phone, otp);
      if (!valid) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('رمز التحقق غير صحيح أو منتهي الصلاحية'),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }

      final user = await AuthService.getOrCreateUser(widget.phone);
      await ref.read(authProvider.notifier).login(user);

      if (!mounted) return;
      _navigateByRole(user.role);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _navigateByRole(UserRole role) {
    switch (role) {
      case UserRole.admin:
        context.go('/admin');
        break;
      case UserRole.kitchen:
        context.go('/kitchen');
        break;
      case UserRole.customer:
        context.go('/home');
        break;
    }
  }

  void _onDigitEntered(int index, String value) {
    if (value.length == 6) {
      // Handle paste
      for (int i = 0; i < 6; i++) {
        _controllers[i].text = value[i];
      }
      _verify();
      return;
    }
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
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
                // WhatsApp icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFF25D366).withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF25D366).withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.chat,
                    color: Color(0xFF25D366),
                    size: 40,
                  ),
                ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),

                const SizedBox(height: 24),

                Text(
                  AppStrings.verifyOtp,
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ).animate().fadeIn(),

                const SizedBox(height: 12),

                Text(
                  'تم إرسال رمز التحقق عبر واتساب إلى',
                  style: const TextStyle(color: AppColors.textSecondary),
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

                const SizedBox(height: 32),

                // Dev OTP display
                if (_devOtp != null)
                  GlassMorphCard(
                    borderColor: AppColors.warning.withOpacity(0.3),
                    child: Column(
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.developer_mode, color: AppColors.warning, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'وضع التطوير - رمز التحقق:',
                              style: TextStyle(color: AppColors.warning, fontSize: 12),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _devOtp!,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 8,
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(),

                const SizedBox(height: 24),

                // OTP Input boxes
                Row(
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
                              color: AppColors.purple,
                              width: 2,
                            ),
                          ),
                        ),
                        onChanged: (v) => _onDigitEntered(i, v),
                      ),
                    );
                  }),
                ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),

                const SizedBox(height: 32),

                // Verify button
                AppButton(
                  label: AppStrings.verifyOtp,
                  onPressed: _verify,
                  isLoading: _isLoading,
                  icon: Icons.check_circle,
                  width: double.infinity,
                ).animate().fadeIn(delay: 400.ms),

                const SizedBox(height: 24),

                // Resend
                if (_resendSeconds > 0)
                  Text(
                    'إعادة الإرسال بعد $_resendSeconds ثانية',
                    style: const TextStyle(color: AppColors.textHint),
                  )
                else
                  TextButton.icon(
                    onPressed: _isSending ? null : _sendOtp,
                    icon: _isSending
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.refresh),
                    label: const Text(AppStrings.resendOtp),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.purple,
                    ),
                  ),

                const SizedBox(height: 16),

                // Open WhatsApp
                AppButton(
                  label: AppStrings.openWhatsapp,
                  onPressed: _sendOtp,
                  isOutlined: true,
                  icon: Icons.chat,
                  color: const Color(0xFF25D366),
                ).animate().fadeIn(delay: 500.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
