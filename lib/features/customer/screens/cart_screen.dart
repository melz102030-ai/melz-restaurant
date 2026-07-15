import 'dart:js' as js;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/cart_provider.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../core/models/order_model.dart';
import '../../../core/services/order_service.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/gradient_container.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../auth/widgets/login_bottom_sheet.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  final _notesController = TextEditingController();
  bool _isPlacingOrder = false;
  OrderType _orderType = OrderType.delivery;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    final cart = ref.read(cartProvider);
    final settings = ref.read(settingsProvider);
    final cartTotal = ref.read(cartTotalProvider);

    if (cart.isEmpty) return;

    if (!settings.effectivelyOpen) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('المطعم مغلق حالياً، لا يمكن إرسال الطلب'),
        backgroundColor: AppColors.error,
      ));
      return;
    }

    if (cartTotal < settings.minOrderAmount) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'الحد الأدنى للطلب ${settings.minOrderAmount.toStringAsFixed(0)} ${AppStrings.sar}'),
        backgroundColor: AppColors.warning,
      ));
      return;
    }

    var user = ref.read(authProvider);
    if (user == null) {
      final loggedIn = await showLoginBottomSheet(context);
      if (!loggedIn || !mounted) return;
      user = ref.read(authProvider);
      if (user == null) return;
    }

    final isDelivery =
        settings.deliveryEnabled && _orderType == OrderType.delivery;
    final deliveryFee = isDelivery ? settings.deliveryFee : 0.0;

    setState(() => _isPlacingOrder = true);
    try {
      final order = OrderModel(
        id: '',
        customerId: user.id,
        customerName: user.name,
        customerPhone: user.phone,
        items: ref.read(cartProvider.notifier).toOrderItems(),
        subtotal: cartTotal,
        deliveryFee: deliveryFee,
        total: cartTotal + deliveryFee,
        status: OrderStatus.pending,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        orderType: isDelivery ? OrderType.delivery : OrderType.pickup,
      );

      final orderId = await OrderService.placeOrder(order);
      ref.read(cartProvider.notifier).clear();
      if (mounted) await _showThankYouDialog(orderId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('فشل إرسال الطلب، حاول مجدداً'),
          backgroundColor: AppColors.error,
        ));
      }
    } finally {
      if (mounted) setState(() => _isPlacingOrder = false);
    }
  }

  Future<void> _showThankYouDialog(String orderId) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.celebration, color: AppColors.purple),
            SizedBox(width: 10),
            Expanded(
              child: Text('شكراً لطلبك! 🎉',
                  style: TextStyle(color: AppColors.textPrimary, fontSize: 18)),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'يمكنك تتبع طلبك أول بأول، وبإمكانك فتح تطبيقات أخرى دون إغلاق المتصفح — '
              'سنُشعرك فور جاهزية طلبك للاستلام.',
              style: TextStyle(color: AppColors.textSecondary, height: 1.5),
            ),
            const SizedBox(height: 20),
            AppButton(
              label: 'تتبع الطلب',
              icon: Icons.receipt_long,
              width: double.infinity,
              onPressed: () {
                try {
                  js.context.callMethod('requestNotifyPermission', []);
                } catch (_) {}
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
    if (mounted) context.go('/track/$orderId');
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final cartTotal = ref.watch(cartTotalProvider);
    final settings = ref.watch(settingsProvider);
    final isDelivery =
        settings.deliveryEnabled && _orderType == OrderType.delivery;
    final deliveryFee = isDelivery ? settings.deliveryFee : 0.0;
    final total = cartTotal + deliveryFee;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.myCart),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (cart.isNotEmpty)
            TextButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('تفريغ السلة'),
                    content: const Text('هل تريد إزالة جميع العناصر؟'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(AppStrings.cancel),
                      ),
                      TextButton(
                        onPressed: () {
                          ref.read(cartProvider.notifier).clear();
                          Navigator.pop(context);
                        },
                        child: const Text(AppStrings.delete,
                            style: TextStyle(color: AppColors.error)),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.delete_outline, color: AppColors.error),
              label: const Text(
                'تفريغ',
                style: TextStyle(color: AppColors.error),
              ),
            ),
        ],
      ),
      body: cart.isEmpty
          ? const EmptyState(
              message: 'سلتك فارغة\nتصفح قائمتنا وأضف ما يعجبك!',
              icon: Icons.shopping_cart_outlined,
            )
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Cart items
                      ...cart.asMap().entries.map((e) {
                        final cartItem = e.value;
                        return _CartItemTile(
                          cartItem: cartItem,
                          index: e.key,
                        );
                      }),

                      const SizedBox(height: 16),

                      // Notes
                      GlassMorphCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.note_alt_outlined,
                                    color: AppColors.textSecondary, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  AppStrings.notes,
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _notesController,
                              maxLines: 3,
                              style: const TextStyle(color: AppColors.textPrimary),
                              decoration: const InputDecoration(
                                hintText: AppStrings.notesHint,
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ],
                        ),
                      ),

                      if (settings.deliveryEnabled) ...[
                        const SizedBox(height: 16),
                        _OrderTypeToggle(
                          orderType: _orderType,
                          onChanged: (t) => setState(() => _orderType = t),
                        ),
                      ],

                      const SizedBox(height: 16),

                      // Price summary
                      GlassMorphCard(
                        child: Column(
                          children: [
                            _PriceRow(AppStrings.subtotal,
                                '${cartTotal.toStringAsFixed(2)} ${AppStrings.sar}'),
                            const SizedBox(height: 8),
                            _PriceRow(
                                isDelivery ? AppStrings.deliveryFee : 'الاستلام من المطعم',
                                isDelivery
                                    ? '${deliveryFee.toStringAsFixed(2)} ${AppStrings.sar}'
                                    : 'مجاناً'),
                            const Divider(color: AppColors.surfaceLight),
                            _PriceRow(
                              AppStrings.total,
                              '${total.toStringAsFixed(2)} ${AppStrings.sar}',
                              isBold: true,
                              valueColor: AppColors.purple,
                            ),
                            if (cartTotal < settings.minOrderAmount) ...[
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.warning.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'الحد الأدنى للطلب ${settings.minOrderAmount.toStringAsFixed(0)} ${AppStrings.sar}',
                                  style: const TextStyle(
                                    color: AppColors.warning,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ],
            ),
      bottomNavigationBar: cart.isEmpty
          ? Padding(
              padding: const EdgeInsets.all(16),
              child: AppButton(
                label: 'تصفح القائمة',
                onPressed: () => context.go('/home'),
                icon: Icons.restaurant_menu,
                width: double.infinity,
              ),
            )
          : Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!settings.effectivelyOpen)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: AppColors.error.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.access_time,
                              color: AppColors.error, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              !settings.isOpen
                                  ? 'المطعم مغلق حالياً من قِبل الإدارة'
                                  : 'المطعم مغلق · يفتح ${settings.openTimeLabel}',
                              style: const TextStyle(
                                  color: AppColors.error, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                  AppButton(
                    label:
                        '${AppStrings.checkout} - ${total.toStringAsFixed(2)} ${AppStrings.sar}',
                    onPressed:
                        settings.effectivelyOpen ? _placeOrder : null,
                    isLoading: _isPlacingOrder,
                    icon: Icons.check_circle,
                    width: double.infinity,
                    color: settings.effectivelyOpen
                        ? AppColors.purple
                        : AppColors.textHint,
                  ),
                ],
              ),
            ),
    );
  }
}

class _CartItemTile extends ConsumerWidget {
  final CartItem cartItem;
  final int index;

  const _CartItemTile({required this.cartItem, required this.index});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.read(cartProvider.notifier);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.purpleDark.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: cartItem.item.imageUrl != null
                ? Image.network(
                    cartItem.item.imageUrl!,
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _placeholder(),
                  )
                : _placeholder(),
          ),
          const SizedBox(width: 12),

          // Name and price
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cartItem.item.name,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                if (cartItem.optionsSummary.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    cartItem.optionsSummary,
                    style: const TextStyle(color: AppColors.textHint, fontSize: 11),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  '${cartItem.unitPrice.toStringAsFixed(2)} ${AppStrings.sar}',
                  style: const TextStyle(color: AppColors.purple, fontSize: 13),
                ),
              ],
            ),
          ),

          // Quantity controls
          Row(
            children: [
              IconButton(
                onPressed: () => cart.removeItem(cartItem.cartKey),
                icon: const Icon(Icons.remove_circle_outline,
                    color: AppColors.red, size: 22),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  '${cartItem.quantity}',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => cart.addItem(cartItem.item, cartItem.selectedOptions),
                icon: const Icon(Icons.add_circle_outline,
                    color: AppColors.purple, size: 22),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 8),
              // Delete
              IconButton(
                onPressed: () => cart.deleteItem(cartItem.cartKey),
                icon: const Icon(Icons.delete_outline,
                    color: AppColors.textHint, size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    ).animate(delay: Duration(milliseconds: index * 50)).fadeIn().slideX(begin: 0.1);
  }

  Widget _placeholder() {
    return Container(
      width: 64,
      height: 64,
      decoration: const BoxDecoration(color: AppColors.surfaceLight),
      child: const Icon(Icons.restaurant, color: AppColors.textHint, size: 28),
    );
  }
}

class _OrderTypeToggle extends StatelessWidget {
  final OrderType orderType;
  final ValueChanged<OrderType> onChanged;

  const _OrderTypeToggle({required this.orderType, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ToggleOption(
              label: 'توصيل',
              icon: Icons.delivery_dining,
              isSelected: orderType == OrderType.delivery,
              onTap: () => onChanged(OrderType.delivery),
            ),
          ),
          Expanded(
            child: _ToggleOption(
              label: 'استلام من المطعم',
              icon: Icons.storefront,
              isSelected: orderType == OrderType.pickup,
              onTap: () => onChanged(OrderType.pickup),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ToggleOption({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.purple : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 16,
                color: isSelected ? Colors.white : AppColors.textSecondary),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color? valueColor;

  const _PriceRow(this.label, this.value, {this.isBold = false, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isBold ? AppColors.textPrimary : AppColors.textSecondary,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: isBold ? 16 : 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? (isBold ? AppColors.textPrimary : AppColors.textSecondary),
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: isBold ? 16 : 14,
          ),
        ),
      ],
    );
  }
}
