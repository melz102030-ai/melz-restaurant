import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/models/user_model.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/settings_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/services/auth_service.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/gradient_container.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String _selectedCountryCode = '+966';

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
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final phone = '$_selectedCountryCode${_phoneController.text.trim()}';
      await AuthService.sendOtp(phone);
      if (!mounted) return;
      context.push('/otp', extra: phone);
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

  String _firebaseError(String code) {
    switch (code) {
      case 'invalid-phone-number':
        return 'رقم الجوال غير صحيح';
      case 'too-many-requests':
        return 'طلبات كثيرة، حاول لاحقاً';
      case 'network-request-failed':
        return 'تحقق من اتصال الإنترنت';
      default:
        return 'خطأ: $code';
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 768;
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      body: Row(
        children: [
          // Left panel (shown on wide screens)
          if (isWide)
            Expanded(
              flex: 5,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.heroGradient,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLogo(large: true),
                    const SizedBox(height: 20),
                    Text(
                      settings.welcomeMessage ?? AppStrings.appTagline,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 18,
                      ),
                    ).animate().fadeIn(delay: 400.ms),
                    const SizedBox(height: 60),
                    _buildFeatureRow(Icons.restaurant_menu, 'قائمة طعام متنوعة'),
                    const SizedBox(height: 16),
                    _buildFeatureRow(Icons.delivery_dining, 'توصيل سريع'),
                    const SizedBox(height: 16),
                    _buildFeatureRow(Icons.track_changes, 'تتبع طلبك لحظة بلحظة'),
                  ],
                ),
              ),
            ),

          // Right panel - login form
          Expanded(
            flex: isWide ? 4 : 10,
            child: Container(
              color: AppColors.background,
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(32),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!isWide) ...[
                          Center(child: _buildLogo()),
                          const SizedBox(height: 40),
                        ],
                        Text(
                          'مرحباً بك!',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ).animate().fadeIn(),
                        const SizedBox(height: 8),
                        const Text(
                          'أدخل رقم جوالك للمتابعة',
                          style: TextStyle(color: AppColors.textSecondary),
                        ).animate().fadeIn(delay: 100.ms),
                        const SizedBox(height: 40),
                        Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Phone input
                              Text(
                                AppStrings.phoneNumber,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  // Country code dropdown
                                  Container(
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceLight,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: AppColors.purpleDark,
                                        width: 1,
                                      ),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: _selectedCountryCode,
                                        dropdownColor: AppColors.surface,
                                        items: _countryCodes.map((c) {
                                          return DropdownMenuItem<String>(
                                            value: c['code'],
                                            child: Text(
                                              '${c['flag']} ${c['code']}',
                                              style: const TextStyle(
                                                color: AppColors.textPrimary,
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                        onChanged: (v) {
                                          if (v != null) {
                                            setState(() => _selectedCountryCode = v);
                                          }
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
                                        letterSpacing: 1.5,
                                      ),
                                      decoration: const InputDecoration(
                                        hintText: '5XXXXXXXX',
                                        prefixIcon: Icon(Icons.phone_android),
                                      ),
                                      validator: (v) {
                                        if (v == null || v.trim().isEmpty) {
                                          return 'أدخل رقم الجوال';
                                        }
                                        if (v.trim().length < 9) {
                                          return 'رقم الجوال غير صحيح';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 32),

                              // Send OTP Button
                              AppButton(
                                label: AppStrings.sendOtp,
                                onPressed: _sendOtp,
                                isLoading: _isLoading,
                                icon: Icons.send,
                                width: double.infinity,
                              ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),

                              const SizedBox(height: 16),

                              // WhatsApp note
                              GlassMorphCard(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF25D366).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.chat,
                                        color: Color(0xFF25D366),
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Expanded(
                                      child: Text(
                                        'سيتم إرسال رمز التحقق عبر SMS',
                                        style: TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ).animate().fadeIn(delay: 400.ms),

                              const SizedBox(height: 40),
                              const Divider(color: AppColors.surfaceLight),
                              const SizedBox(height: 20),

                              // Admin/Kitchen login hint
                              Center(
                                child: Column(
                                  children: [
                                    const Text(
                                      'هل أنت من فريق العمل؟',
                                      style: TextStyle(color: AppColors.textHint),
                                    ),
                                    const SizedBox(height: 8),
                                    TextButton.icon(
                                      onPressed: () => context.push('/staff-login'),
                                      icon: const Icon(Icons.admin_panel_settings),
                                      label: const Text('دخول الإدارة والمطبخ'),
                                      style: TextButton.styleFrom(
                                        foregroundColor: AppColors.manjawi,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // ─── أزرار معاينة مؤقتة (DEV ONLY) ───────────
                              const SizedBox(height: 24),
                              const _DevLoginButtons(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo({bool large = false}) {
    final size = large ? 220.0 : 130.0;
    final settingsAsync = ref.watch(settingsStreamProvider);
    final logoUrl = settingsAsync.valueOrNull?.logoUrl;
    final isLoading = settingsAsync.isLoading;

    if (isLoading) return SizedBox(width: size, height: size);

    if (logoUrl != null) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(large ? 28 : 20),
          boxShadow: [
            BoxShadow(
              color: AppColors.purple.withOpacity(0.55),
              blurRadius: large ? 48 : 28,
              spreadRadius: large ? 8 : 4,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(large ? 28 : 20),
          child: Image.network(
            logoUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _logoFallback(large, size),
          ),
        ),
      ).animate().scale(duration: 700.ms, curve: Curves.elasticOut);
    }

    return _logoFallback(large, size)
        .animate()
        .scale(duration: 600.ms, curve: Curves.elasticOut);
  }

  Widget _logoFallback(bool large, double size) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(large ? 28 : 20),
          gradient: AppColors.heroGradient,
          boxShadow: [
            BoxShadow(
              color: AppColors.purple.withOpacity(0.4),
              blurRadius: 24,
              spreadRadius: 4,
            ),
          ],
        ),
        child: Center(
          child: Text(
            'M',
            style: TextStyle(
              color: Colors.white,
              fontSize: large ? 80 : 48,
              fontWeight: FontWeight.bold,
              fontFamily: 'serif',
            ),
          ),
        ),
      );

  Widget _buildFeatureRow(IconData icon, String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      ],
    ).animate().fadeIn(delay: 600.ms).slideX(begin: -0.2);
  }
}

// ─── أزرار الدخول السريع للمعاينة (مؤقتة - تُحذف قبل الإطلاق) ─────────────
class _DevLoginButtons extends ConsumerWidget {
  const _DevLoginButtons();

  Future<void> _loginAs(BuildContext context, WidgetRef ref, UserRole role) async {
    final names = {
      UserRole.customer: 'عميل تجريبي',
      UserRole.admin: 'مدير النظام',
      UserRole.kitchen: 'موظف مطبخ',
    };
    final phones = {
      UserRole.customer: 'dev_customer',
      UserRole.admin: 'dev_admin',
      UserRole.kitchen: 'dev_kitchen',
    };

    final user = UserModel(
      id: 'dev_${role.name}',
      phone: phones[role]!,
      name: names[role]!,
      role: role,
      createdAt: DateTime.now(),
    );

    await ref.read(authProvider.notifier).login(user);

    if (!context.mounted) return;
    switch (role) {
      case UserRole.customer:
        context.go('/home');
        break;
      case UserRole.admin:
        context.go('/admin');
        break;
      case UserRole.kitchen:
        context.go('/kitchen');
        break;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.amber.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.developer_mode, color: Colors.amber, size: 16),
              const SizedBox(width: 6),
              const Text(
                'معاينة سريعة — مؤقت',
                style: TextStyle(
                  color: Colors.amber,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'DEV',
                  style: TextStyle(color: Colors.amber, fontSize: 10),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _DevBtn(
                label: 'عميل',
                icon: Icons.person,
                color: AppColors.purple,
                onTap: () => _loginAs(context, ref, UserRole.customer),
              ),
              const SizedBox(width: 8),
              _DevBtn(
                label: 'مطبخ',
                icon: Icons.restaurant,
                color: AppColors.manjawi,
                onTap: () => _loginAs(context, ref, UserRole.kitchen),
              ),
              const SizedBox(width: 8),
              _DevBtn(
                label: 'إدارة',
                icon: Icons.admin_panel_settings,
                color: AppColors.red,
                onTap: () => _loginAs(context, ref, UserRole.admin),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 500.ms);
  }
}

class _DevBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _DevBtn({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 16),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withValues(alpha: 0.15),
          foregroundColor: color,
          side: BorderSide(color: color.withValues(alpha: 0.4)),
          padding: const EdgeInsets.symmetric(vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 0,
        ),
      ),
    );
  }
}
