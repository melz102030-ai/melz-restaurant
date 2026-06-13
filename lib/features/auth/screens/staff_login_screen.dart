import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/models/user_model.dart';
import '../../../core/services/auth_service.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/gradient_container.dart';

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

      // Look up staff user by phone
      final query = await FirebaseFirestore.instance
          .collection('users')
          .where('phone', isEqualTo: phone)
          .where('role', whereIn: ['admin', 'kitchen'])
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        throw Exception('المستخدم غير موجود أو ليس من فريق العمل');
      }

      final userData = query.docs.first.data();
      final storedPassword = userData['staffPassword'] as String?;

      if (storedPassword != password) {
        throw Exception('كلمة المرور غير صحيحة');
      }

      final user = UserModel.fromMap(userData, query.docs.first.id);
      await ref.read(authProvider.notifier).login(user);

      if (!mounted) return;

      switch (user.role) {
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: GradientContainer(
                    borderRadius: 20,
                    padding: const EdgeInsets.all(20),
                    child: const Icon(
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
                const Text(
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
                        keyboardType: TextInputType.phone,
                        style: const TextStyle(color: AppColors.textPrimary),
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
                        style: const TextStyle(color: AppColors.textPrimary),
                        decoration: InputDecoration(
                          labelText: 'كلمة المرور',
                          prefixIcon: const Icon(Icons.lock),
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
