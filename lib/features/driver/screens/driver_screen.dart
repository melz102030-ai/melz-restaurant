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
import '../../../core/models/settings_model.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/drivers_provider.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/order_service.dart';
import '../../../core/services/routing_service.dart';
import '../../../shared/widgets/gradient_container.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/app_button.dart';

class DriverScreen extends ConsumerStatefulWidget {
  const DriverScreen({super.key});

  @override
  ConsumerState<DriverScreen> createState() => _DriverScreenState();
}

class _DriverScreenState extends ConsumerState<DriverScreen> {
  bool _togglingAvailability = false;
  StreamSubscription<Position>? _positionSub;
  String? _broadcastingOrderId;

  Future<void> _toggleAvailability(String driverId, bool value) async {
    setState(() => _togglingAvailability = true);
    try {
      await AuthService.setDriverAvailability(driverId, value);
    } finally {
      if (mounted) setState(() => _togglingAvailability = false);
    }
  }

  // يبث موقع المندوب الحي لطلبه الحالي أثناء وجود طلب نشط، ويتوقف عند غيابه
  Future<void> _syncLocationBroadcast(OrderModel? currentOrder) async {
    if (currentOrder == null) {
      await _positionSub?.cancel();
      _positionSub = null;
      _broadcastingOrderId = null;
      return;
    }
    if (_broadcastingOrderId == currentOrder.id) return;

    await _positionSub?.cancel();
    _broadcastingOrderId = currentOrder.id;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return;
    }
    if (!await Geolocator.isLocationServiceEnabled()) return;

    final orderId = currentOrder.id;
    _positionSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 20,
      ),
    ).listen((position) {
      OrderService.updateDriverLocation(orderId, position.latitude, position.longitude);
    });
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
                  : _CurrentOrderCard(order: currentOrder),
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
  const _CurrentOrderCard({required this.order});

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
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  Future<void> _markDelivered() async {
    setState(() => _isUpdating = true);
    try {
      await OrderService.updateOrderStatus(widget.order.id, OrderStatus.delivered);
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  void _openCustomerMap() {
    final order = widget.order;
    if (!order.hasDeliveryLocation) return;
    launchUrl(
      Uri.parse('https://www.google.com/maps/search/?api=1&query=${order.deliveryLat},${order.deliveryLng}'),
      mode: LaunchMode.externalApplication,
    );
  }

  void _openRestaurantMap(double lat, double lng) {
    launchUrl(
      Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng'),
      mode: LaunchMode.externalApplication,
    );
  }

  String _fmtCountdown(Duration d) {
    if (d.isNegative) {
      final over = d.abs();
      return 'تأخر ${over.inMinutes} د';
    }
    final m = d.inMinutes.toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
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
                      _fmtCountdown(remaining),
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
                onPressed: () =>
                    launchUrl(Uri(scheme: 'tel', path: order.customerPhone)),
                icon: Icon(Icons.call, color: AppColors.success),
                tooltip: 'اتصل بالعميل',
              ),
            ],
          ),
          if (order.deliveryAddress != null && order.deliveryAddress!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.note_alt_outlined, color: AppColors.textHint, size: 16),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    order.deliveryAddress!,
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                ),
              ],
            ),
          ],
          if (settings.hasRestaurantLocation || order.hasDeliveryLocation) ...[
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
                if (settings.hasRestaurantLocation && order.hasDeliveryLocation)
                  const SizedBox(width: 8),
                if (order.hasDeliveryLocation)
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
          if (settings.hasRestaurantLocation && order.hasDeliveryLocation) ...[
            const SizedBox(height: 10),
            _DriverEtaCard(order: order, settings: settings),
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
              label: _isReady ? 'تأكيد استلام الطلب' : 'تم التسليم ✅',
              icon: _isReady ? Icons.task_alt : Icons.done_all,
              isLoading: _isUpdating,
              width: double.infinity,
              color: _isReady ? AppColors.warning : AppColors.success,
              onPressed: _isReady ? _confirmPickup : _markDelivered,
            ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.05);
  }
}

// وقت الوصول التقديري: من المندوب إلى المطعم، ومن المطعم إلى العميل، حسب
// شبكة الطرق الفعلية (OSRM) — يتحدّث دورياً مع تحرك المندوب
class _DriverEtaCard extends StatefulWidget {
  final OrderModel order;
  final RestaurantSettings settings;
  const _DriverEtaCard({required this.order, required this.settings});

  @override
  State<_DriverEtaCard> createState() => _DriverEtaCardState();
}

class _DriverEtaCardState extends State<_DriverEtaCard> {
  int? _toRestaurant;
  int? _toCustomer;
  bool _loading = false;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _fetch();
    _refreshTimer = Timer.periodic(const Duration(seconds: 60), (_) => _fetch());
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetch() async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      double? driverLat;
      double? driverLng;
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission != LocationPermission.denied &&
          permission != LocationPermission.deniedForever) {
        try {
          final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.medium)
              .timeout(const Duration(seconds: 8));
          driverLat = pos.latitude;
          driverLng = pos.longitude;
        } catch (_) {}
      }

      final toCustomer = await RoutingService.drivingDurationMinutes(
        fromLat: widget.settings.restaurantLat!,
        fromLng: widget.settings.restaurantLng!,
        toLat: widget.order.deliveryLat!,
        toLng: widget.order.deliveryLng!,
      );

      int? toRestaurant;
      if (driverLat != null && driverLng != null) {
        toRestaurant = await RoutingService.drivingDurationMinutes(
          fromLat: driverLat,
          fromLng: driverLng,
          toLat: widget.settings.restaurantLat!,
          toLng: widget.settings.restaurantLng!,
        );
      }

      if (!mounted) return;
      setState(() {
        _toRestaurant = toRestaurant;
        _toCustomer = toCustomer;
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final total =
        (_toRestaurant != null && _toCustomer != null) ? _toRestaurant! + _toCustomer! : null;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.purple.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.purple.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.alt_route, color: AppColors.purple, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'الوقت التقديري حسب حركة المرور الحالية',
                  style: TextStyle(color: AppColors.purple, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
              if (_loading)
                const SizedBox(
                    width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
              else
                InkWell(
                  onTap: _fetch,
                  child: Icon(Icons.refresh, size: 16, color: AppColors.purple),
                ),
            ],
          ),
          const SizedBox(height: 8),
          _etaRow('منك إلى المطعم', _toRestaurant),
          _etaRow('من المطعم إلى العميل', _toCustomer),
          Divider(color: AppColors.purple.withOpacity(0.2), height: 14),
          _etaRow('الإجمالي', total, bold: true),
        ],
      ),
    );
  }

  Widget _etaRow(String label, int? minutes, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            minutes != null ? '$minutes د' : '—',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 12,
              fontWeight: bold ? FontWeight.bold : FontWeight.w600,
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
    } finally {
      if (mounted) setState(() => _isResponding = false);
    }
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
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _respond(false),
                    icon: Icon(Icons.close, size: 16, color: AppColors.error),
                    label: const Text('رفض'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: BorderSide(color: AppColors.error.withValues(alpha: 0.4)),
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
