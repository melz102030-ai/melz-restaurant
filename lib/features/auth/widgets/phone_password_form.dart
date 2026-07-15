import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/models/user_model.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/services/auth_service.dart';
import '../../../shared/widgets/app_button.dart';

/// نموذج تسجيل الدخول / إنشاء حساب برقم الجوال وكلمة المرور.
/// يُستخدم داخل [LoginScreen] كصفحة كاملة وداخل [LoginBottomSheet] كنافذة منبثقة.
class PhonePasswordForm extends ConsumerStatefulWidget {
  final ValueChanged<UserModel> onSuccess;
  final bool compact;

  const PhonePasswordForm({
    super.key,
    required this.onSuccess,
    this.compact = false,
  });

  @override
  ConsumerState<PhonePasswordForm> createState() => _PhonePasswordFormState();
}

class _PhonePasswordFormState extends ConsumerState<PhonePasswordForm> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();

  String _selectedCountryCode = '+966';
  bool _isSignUp = false;
  bool _isLoading = false;
  bool _obscurePassword = true;

  static const List<Map<String, String>> _countryCodes = [
    {'code': '+966', 'flag': '🇸🇦', 'name': 'السعودية'},
    {'code': '+971', 'flag': '🇦🇪', 'name': 'الإمارات'},
    {'code': '+965', 'flag': '🇰🇼', 'name': 'الكويت'},
    {'code': '+973', 'flag': '🇧🇭', 'name': 'البحرين'},
    {'code': '+974', 'flag': '🇶🇦', 'name': 'قطر'},
    {'code': '+968', 'flag': '🇴🇲', 'name': 'عمان'},
  ];

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final phone = _phoneController.text.trim();
      final password = _passwordController.text.trim();

      final user = _isSignUp
          ? await AuthService.signUpWithPhonePassword(
              _selectedCountryCode, phone, password, _nameController.text)
          : await AuthService.loginWithPhonePassword(
              _selectedCountryCode, phone, password);

      await ref.read(authProvider.notifier).login(user);
      if (!mounted) return;
      widget.onSuccess(user);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(AuthService.phonePasswordError(e.code)),
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

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _isSignUp ? 'إنشاء حساب جديد' : 'مرحباً بك!',
            style: widget.compact
                ? const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  )
                : Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 6),
          const Text(
            'أدخل رقم جوالك وكلمة المرور للمتابعة',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),

          if (_isSignUp) ...[
            Text('الاسم',
                style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameController,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(
                hintText: 'اسمك',
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'أدخل اسمك' : null,
            ),
            const SizedBox(height: 16),
          ],

          Text(AppStrings.phoneNumber,
              style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.purpleDark, width: 1),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCountryCode,
                    dropdownColor: AppColors.surface,
                    items: _countryCodes.map((c) {
                      return DropdownMenuItem<String>(
                        value: c['code'],
                        child: Text('${c['flag']} ${c['code']}',
                            style:
                                const TextStyle(color: AppColors.textPrimary)),
                      );
                    }).toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _selectedCountryCode = v);
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  textAlign: TextAlign.left,
                  style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      letterSpacing: 1.5),
                  decoration: const InputDecoration(
                    hintText: '5XXXXXXXX',
                    prefixIcon: Icon(Icons.phone_android),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'أدخل رقم الجوال';
                    final digits = v.replaceAll(RegExp(r'\D'), '');
                    if (digits.length < 8) return 'رقم الجوال غير صحيح';
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Text('كلمة المرور',
              style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: '••••••••',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(_obscurePassword
                    ? Icons.visibility
                    : Icons.visibility_off),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'أدخل كلمة المرور';
              if (_isSignUp && v.length < 6) {
                return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
              }
              return null;
            },
          ),

          if (_isSignUp) ...[
            const SizedBox(height: 16),
            Text('تأكيد كلمة المرور',
                style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: _obscurePassword,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(
                hintText: '••••••••',
                prefixIcon: Icon(Icons.lock_outline),
              ),
              validator: (v) => v != _passwordController.text
                  ? 'كلمتا المرور غير متطابقتين'
                  : null,
            ),
          ],

          const SizedBox(height: 28),

          AppButton(
            label: _isSignUp ? 'إنشاء حساب' : 'تسجيل الدخول',
            onPressed: _submit,
            isLoading: _isLoading,
            icon: _isSignUp ? Icons.person_add : Icons.login,
            width: double.infinity,
          ),

          const SizedBox(height: 16),

          Center(
            child: TextButton(
              onPressed: _isLoading
                  ? null
                  : () => setState(() => _isSignUp = !_isSignUp),
              child: Text(
                _isSignUp
                    ? 'لديك حساب بالفعل؟ تسجيل الدخول'
                    : 'ليس لديك حساب؟ إنشاء حساب جديد',
                style: const TextStyle(color: AppColors.purple),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
