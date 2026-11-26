import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/order_model.dart';
import '../../../core/providers/order_type_provider.dart';
import '../../../core/providers/settings_provider.dart';

class OrderTypeScreen extends ConsumerWidget {
  const OrderTypeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final logoUrl = ref.watch(settingsStreamProvider).valueOrNull?.logoUrl;
    final deliveryEnabled = settings.deliveryEnabled;

    void select(OrderType type) {
      ref.read(orderTypeProvider.notifier).state = type;
      context.go('/home');
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // الشعار
                  if (logoUrl != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(
                        logoUrl,
                        height: 100,
                        width: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _LogoFallback(),
                      ),
                    )
                  else
                    _LogoFallback(),
                  const SizedBox(height: 28),

                  Text(
                    'اختر نوع الطلب',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'كيف تريد استلام طلبك؟',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                  ),
                  const SizedBox(height: 36),

                  // استلام من الفرع — دائماً نشط
                  _TypeCard(
                    title: 'استلام من الفرع',
                    subtitle: 'استلم طلبك من المطعم مباشرة',
                    icon: Icons.storefront_outlined,
                    enabled: true,
                    onTap: () => select(OrderType.pickup),
                  ),
                  const SizedBox(height: 16),

                  // توصيل — يعتمد على إعدادات الأدمن
                  _TypeCard(
                    title: 'التوصيل للمنزل',
                    subtitle: deliveryEnabled
                        ? 'نوصّل إليك أينما كنت في نطاق الخدمة'
                        : 'سيكون متاحاً قريباً',
                    icon: Icons.delivery_dining_outlined,
                    enabled: deliveryEnabled,
                    badge: deliveryEnabled ? null : 'قريباً',
                    onTap: deliveryEnabled ? () => select(OrderType.delivery) : null,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LogoFallback extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: AppColors.purple.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Icon(Icons.restaurant, color: AppColors.purple, size: 48),
    );
  }
}

class _TypeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool enabled;
  final String? badge;
  final VoidCallback? onTap;

  const _TypeCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.enabled,
    this.badge,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        AnimatedOpacity(
          opacity: enabled ? 1.0 : 0.45,
          duration: const Duration(milliseconds: 200),
          child: Material(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: enabled
                        ? AppColors.purple.withValues(alpha: 0.2)
                        : AppColors.surfaceLight,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: enabled
                            ? AppColors.purple.withValues(alpha: 0.1)
                            : AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        icon,
                        color: enabled ? AppColors.purple : AppColors.textSecondary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              color: enabled
                                  ? AppColors.textPrimary
                                  : AppColors.textSecondary,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (enabled)
                      Icon(
                        Icons.arrow_forward_ios,
                        color: AppColors.purple,
                        size: 16,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // شارة "قريباً" في الزاوية العلوية
        if (badge != null)
          Positioned(
            top: -6,
            left: -6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withValues(alpha: 0.4),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                badge!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
