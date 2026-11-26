import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/authentica_service.dart';
import '../../../shared/widgets/app_button.dart';

/// تعرض ورقة أسفل الشاشة لإدخال رمز OTP.
/// تُعيد الكود المُدخَل عند التحقق الناجح، أو null عند الإغلاق/الإلغاء.
Future<String?> showOtpVerifySheet(
  BuildContext context, {
  required String phone,
  int initialRetryAfter = 60,
}) {
  return showModalBottomSheet<String?>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _OtpSheetContent(phone: phone, initialRetryAfter: initialRetryAfter),
  );
}

class _OtpSheetContent extends StatefulWidget {
  final String phone;
  final int initialRetryAfter;
  const _OtpSheetContent({required this.phone, this.initialRetryAfter = 60});
  @override
  State<_OtpSheetContent> createState() => _OtpSheetContentState();
}

class _OtpSheetContentState extends State<_OtpSheetContent> {
  final _controllers = List.generate(4, (_) => TextEditingController());
  final _focusNodes = List.generate(4, (_) => FocusNode());
  Timer? _timer;
  late int _secondsLeft;
  bool _isVerifying = false;
  bool _isSending = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _secondsLeft = widget.initialRetryAfter;
    _startTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) { c.dispose(); }
    for (final f in _focusNodes) { f.dispose(); }
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft <= 0) {
        t.cancel();
        return;
      }
      if (mounted) setState(() => _secondsLeft--);
    });
  }

  String get _maskedPhone {
    final p = widget.phone.replaceAll(RegExp(r'\s'), '');
    if (p.length >= 9) return '${p.substring(0, p.length - 6)}****${p.substring(p.length - 3)}';
    return p;
  }

  String get _timerText {
    final m = _secondsLeft ~/ 60;
    final s = _secondsLeft % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  static const int _otpLength = 4;
  String get _otp => _controllers.map((c) => c.text).join();

  void _onDigitChanged(int index, String value) {
    setState(() => _error = null);
    if (value.isEmpty) return;
    // دعم لصق الكود كاملاً في الخانة الأولى
    if (value.length >= 4) {
      final digits = value.replaceAll(RegExp(r'\D'), '');
      for (int i = 0; i < 4 && i < digits.length; i++) {
        _controllers[i].text = digits[i];
      }
      _focusNodes[3].requestFocus();
      if (_otp.length == 4) _verify();
      return;
    }
    if (index < 3) _focusNodes[index + 1].requestFocus();
    if (_otp.length == 4) _verify();
  }

  void _onKeyDown(int index, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      _controllers[index - 1].clear();
      _focusNodes[index - 1].requestFocus();
    }
  }

  Future<void> _verify() async {
    final code = _otp;
    if (code.length != _otpLength || _isVerifying) return;
    setState(() { _isVerifying = true; _error = null; });
    try {
      final ok = await AuthenticaService.verifyOtp(widget.phone, code);
      if (!mounted) return;
      if (ok) {
        Navigator.pop(context, code);
      } else {
        setState(() => _error = 'الرمز غير صحيح، تحقق وأعد المحاولة');
        for (final c in _controllers) { c.clear(); }
        _focusNodes[0].requestFocus();
      }
    } catch (e) {
      if (mounted) setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isVerifying = false);
    }
  }

  Future<void> _resend() async {
    setState(() { _isSending = true; _error = null; });
    try {
      final retryAfter = await AuthenticaService.sendOtp(widget.phone);
      if (!mounted) return;
      setState(() => _secondsLeft = retryAfter);
      _startTimer();
      for (final c in _controllers) { c.clear(); }
      _focusNodes[0].requestFocus();
    } catch (e) {
      if (mounted) setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isSending = false);
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
          children: [
            Center(
              child: Container(
                width: 36, height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Container(
              width: 60, height: 60,
              decoration: BoxDecoration(
                color: AppColors.purple.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.sms_outlined, color: AppColors.purple, size: 28),
            ),
            const SizedBox(height: 14),
            Text(
              'رمز التحقق',
              style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const SizedBox(height: 6),
            Text(
              'أُرسل رمز إلى $_maskedPhone',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 28),
            Directionality(
              textDirection: TextDirection.ltr,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_otpLength, (i) => _OtpBox(
                  controller: _controllers[i],
                  focusNode: _focusNodes[i],
                  hasError: _error != null,
                  onChanged: (v) => _onDigitChanged(i, v),
                  onKeyEvent: (e) => _onKeyDown(i, e),
                )),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 10),
              Text(
                _error!,
                style: TextStyle(color: AppColors.error, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 22),
            AppButton(
              label: 'تحقق',
              width: double.infinity,
              onPressed: _otp.length == _otpLength ? _verify : null,
              isLoading: _isVerifying,
            ),
            const SizedBox(height: 14),
            if (_secondsLeft > 0)
              Text(
                'إعادة الإرسال بعد $_timerText',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              )
            else
              TextButton(
                onPressed: _isSending ? null : _resend,
                child: _isSending
                    ? SizedBox(
                        width: 18, height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.purple),
                      )
                    : Text('إعادة إرسال الرمز', style: TextStyle(color: AppColors.purple, fontSize: 14)),
              ),
          ],
        ),
      ),
    );
  }
}

class _OtpBox extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool hasError;
  final ValueChanged<String> onChanged;
  final ValueChanged<KeyEvent> onKeyEvent;

  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.hasError,
    required this.onChanged,
    required this.onKeyEvent,
  });

  @override
  State<_OtpBox> createState() => _OtpBoxState();
}

class _OtpBoxState extends State<_OtpBox> {
  final _keyFocusNode = FocusNode(skipTraversal: true);

  @override
  void dispose() {
    _keyFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = widget.hasError ? AppColors.error : AppColors.surfaceLight;
    final focusBorderColor = widget.hasError ? AppColors.error : AppColors.purple;
    return KeyboardListener(
      focusNode: _keyFocusNode,
      onKeyEvent: widget.onKeyEvent,
      child: Container(
        width: 44, height: 54,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: TextField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 1,
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d]'))],
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
          decoration: InputDecoration(
            counterText: '',
            contentPadding: EdgeInsets.zero,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: borderColor, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: focusBorderColor, width: 2),
            ),
          ),
          onChanged: widget.onChanged,
        ),
      ),
    );
  }
}
