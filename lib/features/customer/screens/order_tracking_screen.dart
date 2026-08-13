import 'dart:async';
import 'dart:js' as js;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/models/order_model.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../core/services/routing_service.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/gradient_container.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../providers/orders_provider.dart';

class OrderTrackingScreen extends ConsumerWidget {
  final String orderId;
  const OrderTrackingScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(trackOrderProvider(orderId));

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.trackOrder),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: orderAsync.when(
        loading: () => const LoadingWidget(message: 'جاري تحميل الطلب...'),
        error: (e, _) => EmptyState(
          message: 'خطأ في تحميل الطلب',
          icon: Icons.error_outline,
          actionLabel: 'عودة',
          onAction: () => context.go('/home'),
        ),
        data: (order) => order == null
            ? EmptyState(
                message: 'الطلب غير موجود',
                icon: Icons.search_off,
                actionLabel: 'عودة',
                onAction: () => context.go('/home'),
              )
            : _OrderTrackingContent(order: order),
      ),
    );
  }
}

class _OrderTrackingContent extends StatefulWidget {
  final OrderModel order;
  const _OrderTrackingContent({required this.order});

  @override
  State<_OrderTrackingContent> createState() => _OrderTrackingContentState();
}

class _OrderTrackingContentState extends State<_OrderTrackingContent> {
  Timer? _ticker;

  bool get _isTerminal =>
      widget.order.status == OrderStatus.delivered ||
      widget.order.status == OrderStatus.cancelled;

  @override
  void initState() {
    super.initState();
    if (widget.order.estimatedMinutes != null && !_isTerminal) {
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() {});
      });
    }
  }

  @override
  void didUpdateWidget(_OrderTrackingContent old) {
    super.didUpdateWidget(old);

    if (old.order.status != OrderStatus.ready &&
        widget.order.status == OrderStatus.ready) {
      _notifyOrderReady();
    }

    if (_isTerminal) {
      _ticker?.cancel();
      _ticker = null;
      return;
    }

    if (old.order.estimatedMinutes == null &&
        widget.order.estimatedMinutes != null &&
        _ticker == null) {
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() {});
      });
    }
  }

  void _notifyOrderReady() {
    try {
      js.context.callMethod('showOrderReadyNotification', [
        'طلبك جاهز! 🎉',
        'يمكنك الآن استلام طلبك #${widget.order.id.substring(0, 6).toUpperCase()}',
      ]);
    } catch (_) {}
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  OrderModel get order => widget.order;

  String _fmtCountdown(Duration d) {
    if (d.isNegative) {
      final over = d.abs();
      return 'تأخر ${over.inMinutes} د ${over.inSeconds % 60} ث';
    }
    final m = d.inMinutes.toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Color _getStatusColor(OrderStatus s) {
    switch (s) {
      case OrderStatus.pending:
        return AppColors.statusPending;
      case OrderStatus.confirmed:
        return AppColors.statusConfirmed;
      case OrderStatus.preparing:
        return AppColors.statusPreparing;
      case OrderStatus.ready:
        return AppColors.statusReady;
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
    final isCancelled = widget.order.status == OrderStatus.cancelled;
    final isDelivered = order.status == OrderStatus.delivered;
    final statusColor = _getStatusColor(order.status);

    final steps = [
      OrderStatus.pending,
      OrderStatus.confirmed,
      OrderStatus.preparing,
      OrderStatus.ready,
      if (order.orderType == OrderType.delivery) OrderStatus.outForDelivery,
      OrderStatus.delivered,
    ];

    final currentStep = isCancelled ? -1 : order.status.step;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Quick actions: call restaurant / restaurant location
          Row(
            children: [
              Expanded(
                child: _QuickActionButton(
                  icon: Icons.call,
                  label: 'اتصل بالمطعم',
                  onTap: () => launchUrl(Uri(scheme: 'tel', path: '0565235404')),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _QuickActionButton(
                  icon: Icons.location_on_outlined,
                  label: 'الموقع على الخريطة',
                  onTap: () => launchUrl(
                    Uri.parse('https://maps.app.goo.gl/DUsDbGQAaVDYHmKz9'),
                    mode: LaunchMode.externalApplication,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (!isDelivered && !isCancelled) ...[
            _PlayWhileWaitingCard(orderId: order.id),
            const SizedBox(height: 16),
          ],

          if (isDelivered) ...[
            const _DeliveredThankYouCard(),
            const SizedBox(height: 16),
          ],

          if (!isDelivered && !isCancelled) ...[
            _TotalEtaCard(order: order),
            const SizedBox(height: 16),
          ],

          if (order.status == OrderStatus.outForDelivery && order.driverName != null) ...[
            _DriverInfoCard(order: order),
            const SizedBox(height: 16),
          ],

          if (order.status == OrderStatus.outForDelivery &&
              order.hasLiveDriverLocation &&
              order.hasDeliveryLocation) ...[
            _DriverLiveMapCard(order: order),
            const SizedBox(height: 16),
          ],

          // Status card
          GlassMorphCard(
            borderColor: statusColor.withOpacity(0.5),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getStatusIcon(order.status),
                    color: statusColor,
                    size: 48,
                  ),
                ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
                const SizedBox(height: 12),
                Text(
                  order.status.label,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ).animate().fadeIn(),
                if (order.estimatedMinutes != null) ...[
                  const SizedBox(height: 12),
                  Builder(builder: (_) {
                    final remaining = order.remainingTime!;
                    final isLate = remaining.isNegative;
                    final isNear = !isLate && remaining.inMinutes < 3;
                    final chipColor = isLate
                        ? AppColors.error
                        : isNear
                            ? AppColors.warning
                            : AppColors.success;
                    return Column(
                      children: [
                        Text(
                          isLate ? 'تجاوز الوقت المتوقع' : 'الوقت المتبقي',
                          style: TextStyle(
                            color: chipColor.withOpacity(0.8),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: chipColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: chipColor.withOpacity(0.4)),
                          ),
                          child: Text(
                            _fmtCountdown(remaining),
                            style: TextStyle(
                              color: chipColor,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              fontFeatures: const [FontFeature.tabularFigures()],
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'إجمالي وقت التحضير: ${order.estimatedMinutes} دقيقة',
                          style: TextStyle(
                            color: AppColors.textHint,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    );
                  }),
                ] else if (order.estimatedTime != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'الوقت المتوقع: ${order.estimatedTime}',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  'رقم الطلب: #${order.id.substring(0, 8).toUpperCase()}',
                  style: TextStyle(color: AppColors.textHint, fontSize: 12),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Progress stepper (only if not cancelled)
          if (!isCancelled)
            GlassMorphCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'تتبع الطلب',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ...steps.asMap().entries.map((e) {
                    final stepIndex = e.key;
                    final stepStatus = e.value;
                    final isDone = currentStep > stepIndex;
                    final isCurrent = currentStep == stepIndex;
                    final color = isDone || isCurrent ? AppColors.purple : AppColors.textHint;

                    return Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: isDone
                                    ? AppColors.success
                                    : isCurrent
                                        ? AppColors.purple
                                        : AppColors.surfaceLight,
                                shape: BoxShape.circle,
                                border: isCurrent
                                    ? Border.all(color: AppColors.purple, width: 2)
                                    : null,
                              ),
                              child: Center(
                                child: isDone
                                    ? Icon(Icons.check, color: Colors.white, size: 16)
                                    : isCurrent
                                        ? const SizedBox(
                                            width: 12,
                                            height: 12,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : Text(
                                            '${stepIndex + 1}',
                                            style: TextStyle(
                                              color: AppColors.textHint,
                                              fontSize: 12,
                                            ),
                                          ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              stepStatus.label,
                              style: TextStyle(
                                color: color,
                                fontWeight: isCurrent
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                        if (stepIndex < steps.length - 1)
                          Container(
                            margin: const EdgeInsets.only(right: 16, top: 2, bottom: 2),
                            height: 24,
                            width: 2,
                            color: isDone ? AppColors.success : AppColors.surfaceLight,
                          ),
                      ],
                    );
                  }),
                ],
              ),
            ),

          if (isCancelled)
            GlassMorphCard(
              borderColor: AppColors.error.withOpacity(0.5),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.cancel, color: AppColors.error, size: 28),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'تم إلغاء هذا الطلب',
                      style: TextStyle(color: AppColors.error, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 16),

          // Kitchen notes
          if (order.kitchenNotes != null && order.kitchenNotes!.isNotEmpty)
            GlassMorphCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.restaurant, color: AppColors.textSecondary, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'ملاحظة من المطبخ',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    order.kitchenNotes!,
                    style: TextStyle(color: AppColors.textPrimary),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 16),

          // Order Items
          GlassMorphCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'العناصر المطلوبة',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                ...order.items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.purple.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '×${item.quantity}',
                            style: TextStyle(color: AppColors.purple, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            item.name,
                            style: TextStyle(color: AppColors.textPrimary),
                          ),
                        ),
                        Text(
                          '${item.total.toStringAsFixed(2)} ${AppStrings.sar}',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ),
                Divider(color: AppColors.surfaceLight),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(AppStrings.subtotal, style: TextStyle(color: AppColors.textSecondary)),
                    Text('${order.subtotal.toStringAsFixed(2)} ${AppStrings.sar}',
                        style: TextStyle(color: AppColors.textSecondary)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(AppStrings.deliveryFee, style: TextStyle(color: AppColors.textSecondary)),
                    Text('${order.deliveryFee.toStringAsFixed(2)} ${AppStrings.sar}',
                        style: TextStyle(color: AppColors.textSecondary)),
                  ],
                ),
                Divider(color: AppColors.surfaceLight),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppStrings.total,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '${order.total.toStringAsFixed(2)} ${AppStrings.sar}',
                      style: TextStyle(
                        color: AppColors.purple,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Date
          GlassMorphCard(
            child: Row(
              children: [
                Icon(Icons.access_time, color: AppColors.textSecondary, size: 18),
                const SizedBox(width: 8),
                Text(
                  'وقت الطلب: ${DateFormat('dd/MM/yyyy - hh:mm a', 'ar').format(order.createdAt)}',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Back to home
          AppButton(
            label: 'العودة للرئيسية',
            onPressed: () => context.go('/home'),
            isOutlined: true,
            icon: Icons.home_outlined,
            width: double.infinity,
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  IconData _getStatusIcon(OrderStatus s) {
    switch (s) {
      case OrderStatus.pending:
        return Icons.hourglass_empty;
      case OrderStatus.confirmed:
        return Icons.thumb_up;
      case OrderStatus.preparing:
        return Icons.restaurant;
      case OrderStatus.ready:
        return Icons.delivery_dining;
      case OrderStatus.outForDelivery:
        return Icons.two_wheeler;
      case OrderStatus.delivered:
        return Icons.check_circle;
      case OrderStatus.cancelled:
        return Icons.cancel;
    }
  }
}

class _PlayWhileWaitingCard extends StatelessWidget {
  final String orderId;
  const _PlayWhileWaitingCard({required this.orderId});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/game/$orderId'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          gradient: AppColors.heroGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.purple.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.videogame_asset, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('العب وأنت تنتظر 🎮',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14)),
                  SizedBox(height: 2),
                  Text('احمِ القلب من الاصطدام وسجّل أعلى نقاطك',
                      style: TextStyle(color: Colors.white70, fontSize: 11)),
                ],
              ),
            ),
            Icon(Icons.chevron_left, color: Colors.white, size: 22),
          ],
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black.withOpacity(0.06)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.purple, size: 18),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DriverInfoCard extends StatelessWidget {
  final OrderModel order;
  const _DriverInfoCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return GlassMorphCard(
      borderColor: AppColors.statusOutForDelivery.withOpacity(0.5),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.statusOutForDelivery.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.two_wheeler,
                color: AppColors.statusOutForDelivery, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'مندوب التوصيل',
                  style: TextStyle(color: AppColors.textHint, fontSize: 11),
                ),
                Text(
                  order.driverName!,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
          if (order.driverPhone != null && order.driverPhone!.isNotEmpty)
            IconButton(
              onPressed: () =>
                  launchUrl(Uri(scheme: 'tel', path: order.driverPhone)),
              icon: Icon(Icons.call, color: AppColors.success),
              tooltip: 'اتصل بالمندوب',
            ),
        ],
      ),
    );
  }
}

// خريطة حية تُظهر موقع المندوب المباشر ووجهة التوصيل
class _DriverLiveMapCard extends StatelessWidget {
  final OrderModel order;
  const _DriverLiveMapCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final driver = ll.LatLng(order.driverLat!, order.driverLng!);
    final dest = ll.LatLng(order.deliveryLat!, order.deliveryLng!);
    final bounds = ll.LatLngBounds.fromPoints([driver, dest]);

    return GlassMorphCard(
      borderColor: AppColors.statusOutForDelivery.withOpacity(0.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.map_outlined, color: AppColors.statusOutForDelivery, size: 18),
              const SizedBox(width: 6),
              Text(
                'موقع المندوب المباشر',
                style: TextStyle(
                    color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              height: 200,
              child: FlutterMap(
                options: MapOptions(
                  initialCameraFit: CameraFit.bounds(
                    bounds: bounds,
                    padding: const EdgeInsets.all(40),
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.melz.restaurant',
                  ),
                  MarkerLayer(markers: [
                    Marker(
                      point: driver,
                      width: 42,
                      height: 42,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.statusOutForDelivery,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 6),
                          ],
                        ),
                        child: const Icon(Icons.two_wheeler, color: Colors.white, size: 22),
                      ),
                    ),
                    Marker(
                      point: dest,
                      width: 38,
                      height: 38,
                      child: Icon(
                        Icons.location_pin,
                        color: AppColors.purple,
                        size: 38,
                        shadows: [Shadow(color: Colors.black.withOpacity(0.3), blurRadius: 4)],
                      ),
                    ),
                  ]),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn();
  }
}

// بطاقة الوقت الإجمالي المتوقع للوصول = الوقت المتبقي للتحضير + زمن التوصيل الفعلي
// (محسوب عبر شبكة الطرق الحقيقية عبر OSRM، وليس تقديراً بالخط المستقيم)
class _TotalEtaCard extends ConsumerStatefulWidget {
  final OrderModel order;
  const _TotalEtaCard({required this.order});

  @override
  ConsumerState<_TotalEtaCard> createState() => _TotalEtaCardState();
}

class _TotalEtaCardState extends ConsumerState<_TotalEtaCard> {
  int? _deliveryMinutes;
  bool _loadingDelivery = false;
  Timer? _refreshTimer;
  DateTime? _lastDriverLocationUsed;

  @override
  void initState() {
    super.initState();
    _fetchDeliveryEstimate();
    _refreshTimer = Timer.periodic(const Duration(seconds: 45), (_) {
      if (mounted) _fetchDeliveryEstimate();
    });
  }

  @override
  void didUpdateWidget(_TotalEtaCard old) {
    super.didUpdateWidget(old);
    final updatedAt = widget.order.driverLocationUpdatedAt;
    if (updatedAt != null && updatedAt != _lastDriverLocationUsed) {
      _fetchDeliveryEstimate();
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchDeliveryEstimate() async {
    final order = widget.order;
    if (order.orderType != OrderType.delivery || !order.hasDeliveryLocation) return;

    double? fromLat;
    double? fromLng;
    if (order.hasLiveDriverLocation) {
      fromLat = order.driverLat;
      fromLng = order.driverLng;
      _lastDriverLocationUsed = order.driverLocationUpdatedAt;
    } else {
      final settings = ref.read(settingsProvider);
      if (settings.hasRestaurantLocation) {
        fromLat = settings.restaurantLat;
        fromLng = settings.restaurantLng;
      }
    }
    if (fromLat == null || fromLng == null) return;

    setState(() => _loadingDelivery = true);
    final minutes = await RoutingService.drivingDurationMinutes(
      fromLat: fromLat,
      fromLng: fromLng,
      toLat: order.deliveryLat!,
      toLng: order.deliveryLng!,
    );
    if (!mounted) return;
    setState(() {
      _loadingDelivery = false;
      if (minutes != null) _deliveryMinutes = minutes;
    });
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;

    final prepRemaining = order.remainingTime;
    final prepMinutes = (order.status == OrderStatus.ready ||
            order.status == OrderStatus.outForDelivery)
        ? 0
        : (prepRemaining != null && !prepRemaining.isNegative ? prepRemaining.inMinutes : 0);

    final prepKnown = order.status == OrderStatus.ready ||
        order.status == OrderStatus.outForDelivery ||
        order.estimatedMinutes != null;
    final showDelivery = order.orderType == OrderType.delivery;
    final totalKnown = prepKnown && (!showDelivery || _deliveryMinutes != null);
    final totalMinutes = prepMinutes + (showDelivery ? (_deliveryMinutes ?? 0) : 0);

    if (!prepKnown) return const SizedBox.shrink();
    if (!totalKnown && _loadingDelivery) {
      return GlassMorphCard(
        child: Row(
          children: [
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 10),
            Text('جاري حساب الوقت الإجمالي المتوقع...',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          ],
        ),
      );
    }
    if (!totalKnown) return const SizedBox.shrink();

    return GlassMorphCard(
      borderColor: AppColors.purple.withOpacity(0.4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.purple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.schedule, color: AppColors.purple, size: 26),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'الوقت الإجمالي المتوقع للوصول',
                  style: TextStyle(color: AppColors.textHint, fontSize: 11),
                ),
                const SizedBox(height: 2),
                Text(
                  totalMinutes <= 0 ? 'قريباً جداً' : '≈ $totalMinutes دقيقة',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                if (showDelivery)
                  Text(
                    'تحضير: $prepMinutes د + توصيل: ${_deliveryMinutes ?? 0} د',
                    style: TextStyle(color: AppColors.textHint, fontSize: 11),
                  ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn();
  }
}

class _DeliveredThankYouCard extends StatelessWidget {
  const _DeliveredThankYouCard();

  @override
  Widget build(BuildContext context) {
    return GlassMorphCard(
      borderColor: AppColors.success.withOpacity(0.5),
      child: Column(
        children: [
          Icon(Icons.favorite, color: AppColors.success, size: 40)
              .animate()
              .scale(duration: 500.ms, curve: Curves.elasticOut),
          const SizedBox(height: 10),
          Text(
            'شكراً لطلبك من Meals! 💜',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 17,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            'يسعدنا لو شاركتنا رأيك — تقييمك يعني لنا الكثير ويساعد الآخرين',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          AppButton(
            label: 'قيّمنا على خرائط جوجل',
            icon: Icons.star_rate_rounded,
            width: double.infinity,
            onPressed: () => launchUrl(
              Uri.parse('https://g.page/r/CdcxqI33hmd2EBM/review'),
              mode: LaunchMode.externalApplication,
            ),
          ),
        ],
      ),
    );
  }
}
