import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/gradient_container.dart';
import '../../auth/widgets/guest_checkout_sheet.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _login(BuildContext context, WidgetRef ref) async {
    final user = await showCustomerLoginSheet(context);
    if (user == null) return;
    await ref.read(authProvider.notifier).login(user);
  }

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تسجيل الخروج؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('تراجع')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('خروج'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    await ref.read(authProvider.notifier).logout();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.profile),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.canPop() ? context.pop() : context.go('/home'),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          _AccountCard(
            phone: user?.phone,
            onLogin: () => _login(context, ref),
          ),
          const SizedBox(height: 24),
          _MenuGroup(children: [
            _MenuRow(
              label: 'الدعم الفني',
              icon: Icons.support_agent_outlined,
              onTap: () => context.push('/support'),
            ),
          ]),
          const SizedBox(height: 16),
          _MenuGroup(children: [
            _MenuRow(
              label: 'سياسة الخصوصية',
              icon: Icons.privacy_tip_outlined,
              onTap: () => context.push('/legal/privacy_policy'),
            ),
            _MenuRow(
              label: 'الشروط والأحكام والاسترجاع',
              icon: Icons.gavel_outlined,
              onTap: () => context.push('/legal/terms_conditions'),
            ),
          ]),
          if (user != null) ...[
            const SizedBox(height: 16),
            _MenuGroup(children: [
              _MenuRow(
                label: 'تسجيل الخروج',
                icon: Icons.logout,
                color: AppColors.error,
                onTap: () => _logout(context, ref),
              ),
            ]),
          ],
        ],
      ),
    );
  }
}

class _AccountCard extends StatelessWidget {
  final String? phone;
  final VoidCallback onLogin;
  const _AccountCard({required this.phone, required this.onLogin});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          GradientContainer(
            borderRadius: 50,
            padding: const EdgeInsets.all(18),
            child: const Icon(Icons.person_rounded, color: Colors.white, size: 38),
          ),
          const SizedBox(height: 14),
          if (phone != null)
            Directionality(
              textDirection: TextDirection.ltr,
              child: Text(
                phone!,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            )
          else
            AppButton(
              label: 'تسجيل الدخول',
              icon: Icons.login,
              width: double.infinity,
              onPressed: onLogin,
            ),
        ],
      ),
    );
  }
}

class _MenuGroup extends StatelessWidget {
  final List<Widget> children;
  const _MenuGroup({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          for (int i = 0; i < children.length; i++) ...[
            if (i > 0) Divider(height: 1, indent: 52, color: AppColors.surfaceLight),
            children[i],
          ],
        ],
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  const _MenuRow({required this.label, required this.icon, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        child: Row(
          children: [
            Icon(icon, color: color ?? AppColors.textSecondary, size: 21),
            const SizedBox(width: 14),
            Expanded(
              child: Text(label, style: TextStyle(color: color ?? AppColors.textPrimary, fontSize: 14.5)),
            ),
            if (color == null) Icon(Icons.chevron_left, color: AppColors.textHint, size: 20),
          ],
        ),
      ),
    );
  }
}
