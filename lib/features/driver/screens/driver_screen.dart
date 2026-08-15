import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/models/order_model.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/drivers_provider.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/order_service.dart';
import '../../../shared/utils/format_utils.dart';
import '../../../shared/widgets/gradient_container.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/app_button.dart';

class DriverScreen extends ConsumerStatefulWidget {
  const DriverScreen({super.key});

  @override
  ConsumerState<DriverScreen> createState() => _DriverScreenState();
}

enum LocationBroadcastStatus { idle, active, permissionDenied, serviceDisabled }

class _DriverScreenState extends ConsumerState<DriverScreen> {
  bool _togglingAvailability = false;
  StreamSubscription<Position>? _positionSub;
  String? _broadcastingOrderId;
  LocationBroadcastStatus _broadcastStatus = LocationBroadcastStatus.idle;

  Future<void> _toggleAvailability(String driverId, bool value) async {
    setState(() => _togglingAvailability = true);
    try {
      await AuthService.setDriverAvailability(driverId, value);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('تعذّر تغيير الحالة — تحقّق من اتصالك بالإنترنت'),
          backgroundColor: AppColors.error,
        ));
      }
    } finally {
      if (mounted) setState(() => _togglingAvailability = false);
    }
  }

  // يبث موقع المندوب الحي لطلبه الحالي أثناء وجود طلب نشط، ويتوقف عند غيابه.
  // يتحقق من mounted ومن أن الطلب المستهدف لم يتغيّر بعد كل await — انتظار
  // إذن الموقع قد يستغرق ثوانٍ، وقد تُغلق الشاشة أو يتغيّر الطلب الحالي أثناءه
  Future<void> _syncLocationBroadcast(OrderModel? currentOrder) async {
    if (currentOrder == null) {
      await _positionSub?.cancel();
      _positionSub = null;
      _broadcastingOrderId = null;
      if (mounted && _broadcastStatus != LocationBroadcastStatus.idle) {
        setState(() => _broadcastStatus = LocationBroadcastStatus.idle);
      }
      return;
    }
    if (_broadcastingOrderId == currentOrder.id) return;

    await _positionSub?.cancel();
    final orderId = currentOrder.id;
    _broadcastingOrderId = orderId;

    var permission = await Geolocator.checkPermission();
    if (!mounted || _broadcastingOrderId != orderId) return;
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (!mounted || _broadcastingOrderId != orderId) return;
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      setState(() => _broadcastStatus = LocationBroadcastStatus.permissionDenied);
      return;
    }
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!mounted || _broadcastingOrderId != orderId) return;
    if (!serviceEnabled) {
      setState(() => _broadcastStatus = LocationBroadcastStatus.serviceDisabled);
      return;
    }

    setState(() => _broadcastStatus = LocationBroadcastStatus.active);
    _positionSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 20,
      ),
    ).listen(
      (position) {
        OrderService.updateDriverLocation(orderId, position.latitude, position.longitude);
      },
      onError: (_) {
        if (mounted) setState(() => _broadcastStatus = LocationBroadcastStatus.serviceDisabled);
      },
    );
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider);
    if (user == null) return const SizedBox.shrink();

    final currentOrder = ref.watch(currentDriverOrderProvider(user.id));
    final queued = ref.watch(queuedDriverOrdersProvider(user.id));
    final ordersAsync = ref.watch(driverActiveOrdersProvider(user.id));
    final invitations = ref.watch(driverInvitationsProvider(user.id)).valueOrNull ?? const [];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _syncLocationBroadcast(currentOrder);
    });

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('لوحة المندوب'),
            Text(
              user.name,
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) context.go('/login');
            },
            icon: Icon(Icons.logout),
            tooltip: 'خروج',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {},
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Availability toggle
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: (user.isAvailable ? AppColors.success : AppColors.textHint)
                      .withOpacity(0.4),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: (user.isAvailable ? AppColors.success : AppColors.textHint)
                          .withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      user.isAvailable ? Icons.check_circle : Icons.pause_circle_outline,
                      color: user.isAvailable ? AppColors.success : AppColors.textHint,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.isAvailable ? 'متاح لاستلام طلبات جديدة' : 'غير متاح حالياً',
                          style: TextStyle(
                              color: AppColors.textPrimary, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'الطلبات النشطة: ${(ordersAsync.valueOrNull ?? const []).length}',
                          style: TextStyle(color: AppColors.textHint, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  _togglingAvailability
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Switch(
                          value: user.isAvailable,
                          activeColor: AppColors.success,
                          onChanged: (v) => _toggleAvailability(user.id, v),
                        ),
                ],
              ),
            ),

            if (invitations.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text(
                'دعوات توصيل جديدة (${invitations.length})',
                style: TextStyle(
                    color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 10),
              ...invitations.map((o) => _InvitationCard(order: o)),
            ],

            const SizedBox(height: 20),

            Text(
              'الطلب الحالي',
              style: TextStyle(
                  color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),

            ordersAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(24),
                child: LoadingWidget(),
              ),
              error: (e, _) => EmptyState(message: 'خطأ: $e', icon: Icons.error),
              data: (_) => currentOrder == null
                  ? const EmptyState(
                      message: 'لا يوجد طلب حالي — سيصلك إشعار عند إسناد طلب جديد',
                      icon: Icons.local_shipping_outlined,
                    )
                  : _CurrentOrderCard(order: currentOrder, broadcastStatus: _broadcastStatus),
            ),

            if (queued.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(
                'طابور الانتظار (${queued.length})',
                style: TextStyle(
                    color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 10),
              ...queued.asMap().entries.map(
                    (e) => _QueuedOrderTile(order: e.value, position: e.key + 2),
                  ),
            ],

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _CurrentOrderCard extends ConsumerStatefulWidget {
  final OrderModel order;
  final LocationBroadcastStatus broadcastStatus;
  const _CurrentOrderCard({required this.order, required this.broadcastStatus});

  @override
  ConsumerState<_CurrentOrderCard> createState() => _CurrentOrderCardState();
}

class _CurrentOrderCardState extends ConsumerState<_CurrentOrderCard> {
  bool _isUpdating = false;
  Timer? _ticker;

  bool get _isPreparing =>
      widget.order.status == OrderStatus.pending ||
      widget.order.status == OrderStatus.confirmed ||
      widget.order.status == OrderStatus.preparing;
  bool get _isReady => widget.order.status == OrderStatus.ready;

  @override
  void initState() {
    super.initState();
    if (widget.order.estimatedMinutes != null) {
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() {});
      });
    }
  }

  @override
  void didUpdateWidget(_CurrentOrderCard old) {
    super.didUpdateWidget(old);
    if (old.order.estimatedMinutes == null &&
        widget.order.estimatedMinutes != null &&
        _ticker == null) {
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() {});
      });
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Future<void> _confirmPickup() async {
    setState(() => _isUpdating = true);
    try {
      await OrderService.confirmPickup(widget.order.id);
    } catch (e) {
      _showNetworkError();
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  // "تم التسليم" لا رجعة فيه فعلياً — يحتاج تأكيداً صريحاً بدل نقرة واحدة قد
  // تحدث بالخطأ أثناء القيادة أو الحركة
  Future<void> _confirmMarkDelivered() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد التسليم'),
        content: Text('هل تم تسليم طلب "${widget.order.customerName}" فعلياً للعميل؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('ليس بعد')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
            child: const Text('نعم، تم التسليم'),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;

    setState(() => _isUpdating = true);
    try {
      await OrderService.updateOrderStatus(widget.order.id, OrderStatus.delivered);
    } catch (e) {
      _showNetworkError();
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  void _showNetworkError() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('تعذّر تنفيذ العملية — تحقّق من اتصالك وحاول مرة أخرى'),
      backgroundColor: AppColors.error,
    ));
  }

  // يفتح الملاحة بالإحداثيات الدقيقة إن توفّرت، وإلا يبحث بنص العنوان نفسه —
  // بدل غياب أي زر ملاحة بالكامل عند عدم توفر إحداثيات دقيقة للعميل
  Future<void> _openCustomerMap() async {
    final order = widget.order;
    final Uri uri;
    if (order.hasDeliveryLocation) {
      uri = Uri.parse(
          'https://www.google.com/maps/search/?api=1&query=${order.deliveryLat},${order.deliveryLng}');
    } else if (order.deliveryAddress != null && order.deliveryAddress!.isNotEmpty) {
      uri = Uri.parse(
          'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(order.deliveryAddress!)}');
    } else {
      return;
    }
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('تعذّر فتح تطبيق الخرائط'),
        backgroundColor: AppColors.error,
      ));
    }
  }

  Future<void> _openRestaurantMap(double lat, double lng) async {
    final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('تعذّر فتح تطبيق الخرائط'),
        backgroundColor: AppColors.error,
      ));
    }
  }

  Future<void> _callCustomer(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    final ok = await launchUrl(uri);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('تعذّر فتح تطبيق الاتصال'),
        backgroundColor: AppColors.error,
      ));
    }
  }

  Color _statusColor(OrderStatus s) {
    switch (s) {
      case OrderStatus.pending:
        return AppColors.statusPending;
      case OrderStatus.confirmed:
        return AppColors.statusConfirmed;
      case OrderStatus.preparing:
        return AppColors.statusPreparing;
      case OrderStatus.ready:
        return AppColors.warning;
      case OrderStatus.outForDelivery:
        return AppColors.statusOutForDelivery;
      case OrderStatus.delivered:
        return AppColors.statusDelivered;
      case OrderStatus.cancelled:
        return AppColors.statusCancelled;
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final settings = ref.watch(settingsProvider);
    final statusColor = _statusColor(order.status);

    return GlassMorphCard(
      borderColor: statusColor.withOpacity(0.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  order.status.label,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '#${order.id.substring(0, 6).toUpperCase()}',
                style: TextStyle(color: AppColors.textHint, fontSize: 12),
              ),
            ],
          ),
          if (order.orderType == OrderType.delivery) ...[
            const SizedBox(height: 8),
            _LocationBroadcastBadge(status: widget.broadcastStatus),
          ],
          if (order.estimatedMinutes != null && order.remainingTime != null) ...[
            const SizedBox(height: 10),
            Builder(builder: (_) {
              final remaining = order.remainingTime!;
              final isLate = remaining.isNegative;
              final chipColor = isLate ? AppColors.error : AppColors.purple;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: chipColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(Icons.timer_outlined, color: chipColor, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      isLate ? 'تجاوز وقت التحضير المتوقع' : 'وقت جاهزية الطلب:',
                      style: TextStyle(color: chipColor, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                    Text(
                      formatCountdown(remaining),
                      style: TextStyle(
                        color: chipColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.customerName,
                      style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                    Text(
                      order.customerPhone,
                      style: TextStyle(color: AppColors.textHint, fontSize: 13),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _callCustomer(order.customerPhone),
                icon: Icon(Icons.call, color: AppColors.success),
                tooltip: 'اتصل بالعميل',
              ),
            ],
          ),
          if (order.orderType == OrderType.delivery &&
              order.deliveryAddress != null &&
              order.deliveryAddress!.isNotEmpty) ...[
            const SizedBox(height: 10),
            // عنوان التوصيل بارز بوضوح — أهم معلومة أثناء القيادة، لا مجرد
            // ملاحظة ثانوية صغيرة أسفل الاسم والهاتف
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.purple.withOpacity(0.06),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.location_on, color: AppColors.purple, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      order.deliveryAddress!,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          // شارة طريقة الدفع — أهم من غيرها لتفادي طلب نقد ممّن دفع إلكترونياً
          // (أو نسيان تحصيل نقد ممّن لم يدفع)، عند تفعيل الدفع الإلكتروني لاحقاً
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: (order.paymentMethod == PaymentMethod.cash
                      ? AppColors.warning
                      : AppColors.success)
                  .withOpacity(0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  order.paymentMethod == PaymentMethod.cash
                      ? Icons.payments_outlined
                      : Icons.credit_card,
                  size: 13,
                  color: order.paymentMethod == PaymentMethod.cash
                      ? AppColors.warning
                      : AppColors.success,
                ),
                const SizedBox(width: 5),
                Text(
                  order.paymentMethod == PaymentMethod.cash
                      ? 'يُحصَّل نقداً من العميل'
                      : 'مدفوع مسبقاً — لا تحصيل',
                  style: TextStyle(
                    color: order.paymentMethod == PaymentMethod.cash
                        ? AppColors.warning
                        : AppColors.success,
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          if (settings.hasRestaurantLocation ||
              order.hasDeliveryLocation ||
              (order.deliveryAddress?.isNotEmpty ?? false)) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                if (settings.hasRestaurantLocation)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          _openRestaurantMap(settings.restaurantLat!, settings.restaurantLng!),
                      icon: Icon(Icons.storefront_outlined, size: 16),
                      label: const Text('موقع المطعم', style: TextStyle(fontSize: 12)),
                    ),
                  ),
                if (settings.hasRestaurantLocation &&
                    (order.hasDeliveryLocation || (order.deliveryAddress?.isNotEmpty ?? false)))
                  const SizedBox(width: 8),
                if (order.hasDeliveryLocation || (order.deliveryAddress?.isNotEmpty ?? false))
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _openCustomerMap,
                      icon: Icon(Icons.location_on_outlined, size: 16),
                      label: const Text('موقع العميل', style: TextStyle(fontSize: 12)),
                    ),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 14),
          Divider(color: AppColors.surfaceLight),
          ...order.items.map(
            (item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  Text('×${item.quantity}',
                      style: TextStyle(color: AppColors.purple, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(item.name,
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  ),
                ],
              ),
            ),
          ),
          Divider(color: AppColors.surfaceLight),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('الإجمالي',
                  style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
              Text('${order.total.toStringAsFixed(2)} ${AppStrings.sar}',
                  style: TextStyle(
                      color: AppColors.purple, fontWeight: FontWeight.bold, fontSize: 15)),
            ],
          ),
          const SizedBox(height: 14),
          if (_isPreparing)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'بانتظار انتهاء التحضير في المطبخ',
                style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
              ),
            )
          else
            AppButton(
              label: _isReady ? 'تأكيد استلام الطلب' : 'تم التسليم',
              icon: _isReady ? Icons.task_alt : Icons.done_all,
              isLoading: _isUpdating,
              width: double.infinity,
              color: _isReady ? AppColors.warning : AppColors.success,
              onPressed: _isReady ? _confirmPickup : _confirmMarkDelivered,
            ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.05);
  }
}

// مؤشر مستمر لحالة مشاركة الموقع الحي مع العميل — بدل عمل البث بصمت تام بلا
// أي إشارة، أو توقّفه بصمت عند تعطّل إذن/خدمة الموقع دون تنبيه أحد
class _LocationBroadcastBadge extends StatelessWidget {
  final LocationBroadcastStatus status;
  const _LocationBroadcastBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (Color color, IconData icon, String label) = switch (status) {
      LocationBroadcastStatus.active => (
          AppColors.success,
          Icons.location_on,
          'مشاركة موقعك مع العميل نشطة'
        ),
      LocationBroadcastStatus.permissionDenied => (
          AppColors.error,
          Icons.location_off,
          'مشاركة الموقع متوقفة — فعّل إذن الموقع من إعدادات المتصفح'
        ),
      LocationBroadcastStatus.serviceDisabled => (
          AppColors.error,
          Icons.location_disabled,
          'مشاركة الموقع متوقفة — فعّل خدمة الموقع في جهازك'
        ),
      LocationBroadcastStatus.idle => (AppColors.textHint, Icons.location_searching, 'جارٍ تفعيل مشاركة الموقع...'),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _QueuedOrderTile extends StatelessWidget {
  final OrderModel order;
  final int position;
  const _QueuedOrderTile({required this.order, required this.position});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surfaceLight),
      ),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.textHint.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Text('$position',
                style: TextStyle(color: AppColors.textHint, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(order.customerName,
                    style: TextStyle(
                        color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                Text(
                  order.status.label,
                  style: TextStyle(color: AppColors.textHint, fontSize: 11),
                ),
              ],
            ),
          ),
          // طلب جاهز فعلياً بانتظار دوره فقط لأن طلباً آخر أُسنِد قبله — يستحق
          // إشارة واضحة لأن المندوب قد يقدر التوجه لاستلامه فوراً رغم مكانه بالطابور
          if (order.status == OrderStatus.ready || order.status == OrderStatus.outForDelivery)
            Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text('جاهز',
                  style: TextStyle(
                      color: AppColors.warning, fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          Text(
            DateFormat('hh:mm a').format(order.createdAt),
            style: TextStyle(color: AppColors.textHint, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

// دعوة تعيين لم يردّ عليها المندوب بعد — قد تصل من لحظة وصول الطلب للمطبخ،
// قبل أن يبدأ التحضير حتى
class _InvitationCard extends StatefulWidget {
  final OrderModel order;
  const _InvitationCard({required this.order});

  @override
  State<_InvitationCard> createState() => _InvitationCardState();
}

class _InvitationCardState extends State<_InvitationCard> {
  bool _isResponding = false;

  Future<void> _respond(bool accepted) async {
    setState(() => _isResponding = true);
    try {
      await OrderService.respondToDriverAssignment(widget.order.id, accepted: accepted);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('تعذّر إرسال الرد — تحقّق من اتصالك وحاول مرة أخرى'),
          backgroundColor: AppColors.error,
        ));
      }
    } finally {
      if (mounted) setState(() => _isResponding = false);
    }
  }

  // الرفض لا رجعة فيه (يُلغي إسناد الطلب) — يحتاج تأكيداً صريحاً كأي إجراء
  // نهائي آخر، بدل نقرة واحدة قد تحدث بالخطأ
  Future<void> _confirmReject() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('رفض الطلب'),
        content: Text('هل تريد رفض توصيل طلب "${widget.order.customerName}"؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('تراجع')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('رفض'),
          ),
        ],
      ),
    );
    if (confirm == true) await _respond(false);
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    return GlassMorphCard(
      borderColor: AppColors.purple.withOpacity(0.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.notifications_active, color: AppColors.purple, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  order.customerName,
                  style: TextStyle(
                      color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
              Text(
                order.status.label,
                style: TextStyle(color: AppColors.textHint, fontSize: 11),
              ),
            ],
          ),
          if (order.deliveryAddress != null && order.deliveryAddress!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              order.deliveryAddress!,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            '${order.items.length} صنف · ${order.total.toStringAsFixed(0)} ${AppStrings.sar}',
            style: TextStyle(color: AppColors.textHint, fontSize: 12),
          ),
          const SizedBox(height: 12),
          if (_isResponding)
            const Center(
              child: SizedBox(
                  width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else
            Row(
              children: [
                // وزن بصري متساوٍ مع زر القبول (كلاهما معبَّأ بالكامل) — كانا
                // سابقاً بوزنين مختلفين (حدود رفيعة مقابل تعبئة كاملة)، ما
                // يُفقد أحد الخيارين وضوحه تحت إضاءة قوية رغم تساوي أهميتهما
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _confirmReject,
                    icon: Icon(Icons.close, size: 16, color: Colors.white),
                    label: const Text('رفض'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _respond(true),
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text('قبول'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.05);
  }
}
