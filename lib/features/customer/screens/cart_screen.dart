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
import '../../../core/providers/delivery_zone_provider.dart';
import '../../../core/models/order_model.dart';
import '../../../core/models/settings_model.dart';
import '../../../core/models/delivery_zone_model.dart';
import '../../../core/services/order_service.dart';
import '../../../core/services/delivery_zone_service.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/gradient_container.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../auth/widgets/login_bottom_sheet.dart';
import 'delivery_location_picker_screen.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  final _notesController = TextEditingController();
  bool _isPlacingOrder = false;
  OrderType _orderType = OrderType.delivery;
  double? _deliveryLat;
  double? _deliveryLng;
  String? _deliveryAddressNote;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDeliveryLocation() async {
    final result = await Navigator.of(context, rootNavigator: true)
        .push<DeliveryLocationResult>(
      MaterialPageRoute(
        builder: (_) => DeliveryLocationPickerScreen(
          initialLat: _deliveryLat,
          initialLng: _deliveryLng,
          initialNote: _deliveryAddressNote,
        ),
      ),
    );
    if (result != null && mounted) {
      setState(() {
        _deliveryLat = result.lat;
        _deliveryLng = result.lng;
        _deliveryAddressNote = result.addressNote;
      });
    }
  }

  // يحدد رسوم التوصيل: حسب النطاق (المسافة) إن كان مُفعّلاً عند الإدارة، وإلا الرسم الثابت
  ({double fee, String? zoneId, String? zoneName, bool outsideServiceArea})
      _resolveDeliveryPricing(RestaurantSettings settings, List<DeliveryZone> zones) {
    if (!settings.useDeliveryZones || !settings.hasRestaurantLocation || zones.isEmpty) {
      return (fee: settings.deliveryFee, zoneId: null, zoneName: null, outsideServiceArea: false);
    }
    if (_deliveryLat == null || _deliveryLng == null) {
      return (fee: settings.deliveryFee, zoneId: null, zoneName: null, outsideServiceArea: false);
    }
    final distance = DeliveryZoneService.distanceKm(
      settings.restaurantLat!,
      settings.restaurantLng!,
      _deliveryLat!,
      _deliveryLng!,
    );
    final zone = DeliveryZoneService.resolveZone(zones, distance);
    if (zone == null) {
      return (fee: 0, zoneId: null, zoneName: null, outsideServiceArea: true);
    }
    return (fee: zone.fee, zoneId: zone.id, zoneName: zone.name, outsideServiceArea: false);
  }

  Future<void> _placeOrder() async {
    if (_isPlacingOrder) return;

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

    final isDelivery =
        settings.deliveryEnabled && _orderType == OrderType.delivery;

    if (isDelivery && (_deliveryLat == null || _deliveryLng == null)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('الرجاء تحديد موقع التوصيل على الخريطة أولاً'),
        backgroundColor: AppColors.warning,
      ));
      return;
    }

    final zones = ref.read(deliveryZonesProvider).valueOrNull ?? const <DeliveryZone>[];
    final pricing = _resolveDeliveryPricing(settings, zones);

    if (isDelivery && pricing.outsideServiceArea) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('عذراً، موقعك خارج نطاق التوصيل المتاح'),
        backgroundColor: AppColors.error,
      ));
      return;
    }

    setState(() => _isPlacingOrder = true);
    try {
      var user = ref.read(authProvider);
      if (user == null) {
        final loggedIn = await showLoginBottomSheet(context);
        if (!loggedIn || !mounted) return;
        user = ref.read(authProvider);
        if (user == null) return;
      }

      final deliveryFee = isDelivery ? pricing.fee : 0.0;

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
        deliveryLat: isDelivery ? _deliveryLat : null,
        deliveryLng: isDelivery ? _deliveryLng : null,
        deliveryAddress: isDelivery ? _deliveryAddressNote : null,
        deliveryZoneId: isDelivery ? pricing.zoneId : null,
        deliveryZoneName: isDelivery ? pricing.zoneName : null,
      );

      final orderId = await OrderService.placeOrder(order);
      ref.read(cartProvider.notifier).clear();
      if (!mounted) return;
      try {
        js.context.callMethod('requestNotifyPermission', []);
      } catch (_) {}
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('شكراً لطلبك! 🎉 يمكنك تتبع طلبك أول بأول'),
        backgroundColor: AppColors.purple,
      ));
      context.go('/track/$orderId');
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

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final cartTotal = ref.watch(cartTotalProvider);
    final settings = ref.watch(settingsProvider);
    final zones = ref.watch(deliveryZonesProvider).valueOrNull ?? const <DeliveryZone>[];
    final isDelivery =
        settings.deliveryEnabled && _orderType == OrderType.delivery;
    final pricing = _resolveDeliveryPricing(settings, zones);
    final deliveryFee = isDelivery ? pricing.fee : 0.0;
    final total = cartTotal + deliveryFee;
    final locationMissing = isDelivery && (_deliveryLat == null || _deliveryLng == null);
    final outsideServiceArea = isDelivery && pricing.outsideServiceArea;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.myCart),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
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
              icon: Icon(Icons.delete_outline, color: AppColors.error),
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
                            Row(
                              children: [
                                Icon(Icons.note_alt_outlined,
                                    color: AppColors.textSecondary, size: 20),
                                const SizedBox(width: 8),
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
                              style: TextStyle(color: AppColors.textPrimary),
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

                      if (isDelivery) ...[
                        const SizedBox(height: 16),
                        _DeliveryLocationCard(
                          hasLocation: !locationMissing,
                          addressNote: _deliveryAddressNote,
                          outsideServiceArea: outsideServiceArea,
                          onTap: _pickDeliveryLocation,
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
                                isDelivery
                                    ? (pricing.zoneName != null
                                        ? '${AppStrings.deliveryFee} (${pricing.zoneName})'
                                        : AppStrings.deliveryFee)
                                    : 'الاستلام من المطعم',
                                isDelivery
                                    ? (outsideServiceArea
                                        ? '—'
                                        : '${deliveryFee.toStringAsFixed(2)} ${AppStrings.sar}')
                                    : 'مجاناً'),
                            Divider(color: AppColors.surfaceLight),
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
                                  style: TextStyle(
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
              decoration: BoxDecoration(
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
                          Icon(Icons.access_time,
                              color: AppColors.error, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              !settings.isOpen
                                  ? 'المطعم مغلق حالياً من قِبل الإدارة'
                                  : 'المطعم مغلق · يفتح ${settings.openTimeLabel}',
                              style: TextStyle(
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
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                if (cartItem.optionsSummary.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    cartItem.optionsSummary,
                    style: TextStyle(color: AppColors.textHint, fontSize: 11),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  '${cartItem.unitPrice.toStringAsFixed(2)} ${AppStrings.sar}',
                  style: TextStyle(color: AppColors.purple, fontSize: 13),
                ),
              ],
            ),
          ),

          // Quantity controls
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _QtyButton(
                      icon: Icons.remove,
                      onTap: () => cart.removeItem(cartItem.cartKey),
                    ),
                    SizedBox(
                      width: 22,
                      child: Text(
                        '${cartItem.quantity}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    _QtyButton(
                      icon: Icons.add,
                      onTap: () => cart.addItem(cartItem.item, cartItem.selectedOptions),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              // Delete
              InkWell(
                onTap: () => cart.deleteItem(cartItem.cartKey),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(Icons.delete_outline,
                      color: AppColors.textHint, size: 16),
                ),
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
      decoration: BoxDecoration(color: AppColors.surfaceLight),
      child: Icon(Icons.restaurant, color: AppColors.textHint, size: 28),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QtyButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(icon, color: AppColors.textPrimary, size: 14),
      ),
    );
  }
}

class _DeliveryLocationCard extends StatelessWidget {
  final bool hasLocation;
  final String? addressNote;
  final bool outsideServiceArea;
  final VoidCallback onTap;

  const _DeliveryLocationCard({
    required this.hasLocation,
    required this.addressNote,
    required this.outsideServiceArea,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = outsideServiceArea
        ? AppColors.error
        : hasLocation
            ? AppColors.success
            : AppColors.warning;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.35)),
        ),
        child: Row(
          children: [
            Icon(
              outsideServiceArea
                  ? Icons.location_off
                  : hasLocation
                      ? Icons.location_on
                      : Icons.add_location_alt_outlined,
              color: color,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    outsideServiceArea
                        ? 'موقعك خارج نطاق التوصيل'
                        : hasLocation
                            ? 'تم تحديد موقع التوصيل'
                            : 'حدّد موقع التوصيل',
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  if (hasLocation && addressNote != null && addressNote!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        addressNote!,
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    )
                  else if (!hasLocation)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        'عبر GPS أو التحديد اليدوي على الخريطة',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                      ),
                    ),
                ],
              ),
            ),
            Text(
              hasLocation ? 'تغيير' : 'تحديد',
              style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ],
        ),
      ),
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
