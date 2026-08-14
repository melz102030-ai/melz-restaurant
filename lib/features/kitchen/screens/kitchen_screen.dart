import 'dart:async';
import 'dart:js' as js;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/models/order_model.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/drivers_provider.dart';
import '../../../core/services/order_service.dart';
import '../../../shared/widgets/gradient_container.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../providers/kitchen_provider.dart';

class KitchenScreen extends ConsumerStatefulWidget {
  const KitchenScreen({super.key});

  @override
  ConsumerState<KitchenScreen> createState() => _KitchenScreenState();
}

class _KitchenScreenState extends ConsumerState<KitchenScreen> {
  // Alarm state
  final Set<String> _knownPendingIds = {};
  bool _initialLoaded = false;
  bool _alarmPlaying = false;
  // قسم "مُسلَّمة" مطوي افتراضياً — يتراكم فيه أكبر عدد من الطلبات وأقلها أهمية للمتابعة
  bool _deliveredExpanded = false;

  void _primeAudio() {
    try { js.context.callMethod('primeKitchenAudio', []); } catch (_) {}
  }

  void _playAlarm() {
    try { js.context.callMethod('playKitchenAlarm', []); } catch (_) {}
    if (mounted) setState(() => _alarmPlaying = true);
    // Safety auto-stop after 22s if JS timer somehow fails
    Future.delayed(const Duration(seconds: 22), _stopAlarm);
  }

  void _stopAlarm() {
    try { js.context.callMethod('stopKitchenAlarm', []); } catch (_) {}
    if (mounted) setState(() => _alarmPlaying = false);
  }

  void _openAvailability() => context.push('/kitchen/availability');

  @override
  void initState() {
    super.initState();
    // محاولة تهيئة الصوت فور فتح شاشة المطبخ
    // (يعمل إذا وصل المستخدم عبر نقرة — أي تفاعل مسبق يكفي)
    WidgetsBinding.instance.addPostFrameCallback((_) => _primeAudio());
  }

  @override
  void dispose() {
    _stopAlarm();
    super.dispose();
  }

  // قسم واحد (عنوان + عدّاد + قائمة/شبكة الطلبات) كسلايفرز ضمن صفحة واحدة —
  // بدل تبويبات تُخفي الطلب عن العين أثناء التنقل بينها. يدعم الطي الاختياري
  // (مثل قسم "مُسلَّمة" المطوي افتراضياً لأنه الأقل أهمية للمتابعة الحيّة)
  List<Widget> _section(
    String label,
    List<OrderModel> orders,
    Color color,
    String emptyMessage, {
    bool collapsible = false,
    bool expanded = true,
    VoidCallback? onToggle,
  }) {
    final isWide = MediaQuery.of(context).size.width > 900;
    final showContent = !collapsible || expanded;
    return [
      SliverToBoxAdapter(
        child: InkWell(
          onTap: collapsible ? onToggle : null,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
                Text(label,
                    style: TextStyle(
                        color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(width: 8),
                if (orders.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration:
                        BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
                    child: Text(
                      '${orders.length}',
                      style: const TextStyle(
                          color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                if (collapsible) ...[
                  const Spacer(),
                  Icon(expanded ? Icons.expand_less : Icons.expand_more,
                      color: AppColors.textHint),
                ],
              ],
            ),
          ),
        ),
      ),
      if (!showContent)
        const SliverToBoxAdapter(child: SizedBox.shrink())
      else if (orders.isEmpty)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(emptyMessage, style: TextStyle(color: AppColors.textHint, fontSize: 13)),
          ),
        )
      else if (isWide)
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            delegate: SliverChildBuilderDelegate(
              (_, i) => _KitchenOrderCard(order: orders[i], index: i),
              childCount: orders.length,
            ),
          ),
        )
      else
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (_, i) => _KitchenOrderCard(order: orders[i], index: i),
              childCount: orders.length,
            ),
          ),
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final newOrders = ref.watch(newKitchenOrdersProvider);
    final inProgress = ref.watch(inProgressKitchenOrdersProvider);
    final ready = ref.watch(readyKitchenOrdersProvider);
    final delivering = ref.watch(deliveringKitchenOrdersProvider);
    final delivered = ref.watch(deliveredKitchenOrdersProvider);
    final ordersAsync = ref.watch(kitchenOrdersProvider);

    // Detect truly-new pending orders and trigger alarm
    ref.listen<AsyncValue<List<OrderModel>>>(kitchenOrdersProvider, (_, next) {
      final orders = next.valueOrNull ?? [];
      final pendingIds = orders
          .where((o) => o.status == OrderStatus.pending)
          .map((o) => o.id)
          .toSet();

      if (_initialLoaded) {
        final brandNew = pendingIds.difference(_knownPendingIds);
        if (brandNew.isNotEmpty) _playAlarm();
      } else {
        _initialLoaded = true;
      }
      _knownPendingIds
        ..clear()
        ..addAll(pendingIds);
    });

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(AppStrings.kitchenDisplay),
            Text(
              'مجموع النشط: ${ordersAsync.maybeWhen(data: (d) => d.length, orElse: () => 0)} طلب',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          // إيقاف الإنذار عند تشغيله
          if (_alarmPlaying)
            TextButton.icon(
              onPressed: _stopAlarm,
              icon: Icon(Icons.volume_off, size: 18, color: Colors.redAccent),
              label: const Text('إيقاف', style: TextStyle(color: Colors.redAccent, fontSize: 12)),
            ),
          // Availability management
          IconButton(
            onPressed: _openAvailability,
            icon: Icon(Icons.restaurant_menu),
            tooltip: 'إدارة توفر الأصناف',
          ),
          // Logout
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
      body: Column(
        children: [
          // Flashing alarm banner
          if (_alarmPlaying)
            GestureDetector(
              onTap: _stopAlarm,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                color: Colors.red,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.notifications_active, color: Colors.white, size: 22),
                    SizedBox(width: 10),
                    Text(
                      '🔔 طلب جديد وصل! — اضغط لإيقاف الصوت',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ).animate(onPlay: (c) => c.repeat()).shimmer(
                  duration: const Duration(milliseconds: 600),
                  color: Colors.orange,
                ),
          Expanded(
            child: ordersAsync.when(
              loading: () => const LoadingWidget(message: 'جاري تحميل الطلبات...'),
              error: (e, _) => EmptyState(message: 'خطأ: $e', icon: Icons.error),
              // كل الحالات في صفحة واحدة قابلة للتمرير بدل تبويبات تُخفي الطلب
              // عن العين أثناء البحث بينها
              data: (_) => CustomScrollView(
                slivers: [
                  ..._section(AppStrings.newOrders, newOrders, AppColors.statusPending,
                      'لا توجد طلبات جديدة'),
                  ..._section(AppStrings.inProgress, inProgress, AppColors.statusPreparing,
                      'لا توجد طلبات قيد التنفيذ'),
                  ..._section(
                      AppStrings.completed, ready, AppColors.statusReady, 'لا توجد طلبات جاهزة'),
                  ..._section('التوصيل', delivering, AppColors.statusOutForDelivery,
                      'لا توجد طلبات في الطريق حالياً'),
                  ..._section(
                    'مُسلَّمة',
                    delivered,
                    AppColors.statusDelivered,
                    'لا توجد طلبات مُسلَّمة خلال آخر 4 ساعات',
                    collapsible: true,
                    expanded: _deliveredExpanded,
                    onToggle: () => setState(() => _deliveredExpanded = !_deliveredExpanded),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 40)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class _KitchenOrderCard extends StatefulWidget {
  final OrderModel order;
  final int index;
  const _KitchenOrderCard({required this.order, required this.index});

  @override
  State<_KitchenOrderCard> createState() => _KitchenOrderCardState();
}

class _KitchenOrderCardState extends State<_KitchenOrderCard> {
  final _notesCtrl = TextEditingController();
  final _timeCtrl = TextEditingController();
  bool _isUpdating = false;
  bool _expanded = false;
  Timer? _ticker;

  bool get _isTerminal =>
      widget.order.status == OrderStatus.delivered ||
      widget.order.status == OrderStatus.cancelled;

  @override
  void initState() {
    super.initState();
    final mins = widget.order.estimatedMinutes;
    _timeCtrl.text = mins != null ? '$mins' : '';
    _notesCtrl.text = widget.order.kitchenNotes ?? '';
    if (widget.order.estimatedMinutes != null && !_isTerminal) {
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() {});
      });
    }
  }

  @override
  void didUpdateWidget(_KitchenOrderCard old) {
    super.didUpdateWidget(old);

    if (_isTerminal) {
      _ticker?.cancel();
      _ticker = null;
      return;
    }

    // عند وصول estimatedMinutes من Firestore لأول مرة ابدأ المؤقت
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
    _notesCtrl.dispose();
    _timeCtrl.dispose();
    super.dispose();
  }

  Future<void> _updateStatus(OrderStatus newStatus) async {
    setState(() => _isUpdating = true);
    try {
      final mins = int.tryParse(_timeCtrl.text.trim());
      await OrderService.updateOrderStatus(
        widget.order.id,
        newStatus,
        estimatedTime: mins != null ? '$mins دقيقة' : null,
        kitchenNotes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
        estimatedMinutes: mins,
      );
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  // تأكيد الطلب (pending → confirmed) — إن كان هناك مندوب مُسنَد لم يوافق بعد،
  // ننبّه المطبخ ونترك له الخيار: يتابع الآن أو ينتظر موافقة المندوب أولاً
  Future<void> _confirmOrder() async {
    if (widget.order.isAwaitingDriverAcceptance) {
      final proceed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('المندوب لم يوافق بعد'),
          content: Text(
              'المندوب "${widget.order.driverName}" لم يوافق بعد على استلام هذا الطلب. '
              'يمكنك تأكيد الطلب الآن على أي حال، أو الانتظار حتى يوافق.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('انتظار')),
            ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true), child: const Text('تأكيد الآن')),
          ],
        ),
      );
      if (proceed != true) return;
    }
    if (mounted) await _updateStatus(OrderStatus.confirmed);
  }

  Future<void> _openAssignDriver() async {
    await showDialog(
      context: context,
      builder: (_) => _AssignDriverDialog(order: widget.order),
    );
  }

  Future<void> _unassignDriver() async {
    setState(() => _isUpdating = true);
    try {
      await OrderService.unassignDriver(widget.order.id);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: AppColors.error,
        ));
      }
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  String _fmtCountdown(Duration d) {
    if (d.isNegative) {
      final over = d.abs();
      return 'تأخر ${over.inMinutes} د ${over.inSeconds % 60} ث';
    }
    final m = d.inMinutes.toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Color get _statusColor {
    switch (widget.order.status) {
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
      default:
        return AppColors.textHint;
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final elapsed = DateTime.now().difference(order.createdAt);
    final isUrgent = elapsed.inMinutes > 15 && order.status == OrderStatus.pending;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isUrgent ? AppColors.error : _statusColor.withOpacity(0.4),
          width: isUrgent ? 2 : 1,
        ),
        boxShadow: isUrgent
            ? [
                BoxShadow(
                  color: AppColors.error.withOpacity(0.2),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _statusColor.withOpacity(0.2),
                  Colors.transparent,
                ],
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                // Order number
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: _statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '#${order.id.substring(0, 6).toUpperCase()}',
                    style: TextStyle(
                      color: _statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Customer info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.customerName,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        order.customerPhone,
                        style: TextStyle(
                          color: AppColors.textHint,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: (order.orderType == OrderType.delivery
                                  ? AppColors.purple
                                  : AppColors.manjawi)
                              .withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          order.orderType.label,
                          style: TextStyle(
                            color: order.orderType == OrderType.delivery
                                ? AppColors.purple
                                : AppColors.manjawi,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (order.driverName != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.delivery_dining,
                                size: 12, color: AppColors.statusOutForDelivery),
                            const SizedBox(width: 3),
                            Text(
                              order.driverName!,
                              style: TextStyle(
                                color: AppColors.statusOutForDelivery,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                IconButton(
                  onPressed: () =>
                      launchUrl(Uri(scheme: 'tel', path: order.customerPhone)),
                  icon: Icon(Icons.call, color: AppColors.success, size: 20),
                  tooltip: 'اتصل بالعميل',
                ),

                // Time elapsed + countdown
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Elapsed since order placed
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isUrgent
                            ? AppColors.error.withOpacity(0.15)
                            : AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.timer,
                            size: 12,
                            color: isUrgent ? AppColors.error : AppColors.textHint,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${elapsed.inMinutes} د',
                            style: TextStyle(
                              color: isUrgent ? AppColors.error : AppColors.textHint,
                              fontSize: 12,
                              fontWeight: isUrgent ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Countdown pill (shown only when estimatedMinutes is set and order still active)
                    if (order.estimatedMinutes != null &&
                        order.remainingTime != null &&
                        !_isTerminal) ...[
                      Builder(builder: (_) {
                        final remaining = order.remainingTime!;
                        final isLate = remaining.isNegative;
                        final isNear = !isLate && remaining.inMinutes < 3;
                        final color = isLate
                            ? AppColors.error
                            : isNear
                                ? AppColors.warning
                                : AppColors.success;
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: color.withOpacity(0.4)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isLate ? Icons.warning_amber : Icons.hourglass_bottom,
                                size: 12,
                                color: color,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _fmtCountdown(remaining),
                                style: TextStyle(
                                  color: color,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  fontFeatures: const [FontFeature.tabularFigures()],
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ] else
                      Text(
                        DateFormat('hh:mm a').format(order.createdAt),
                        style: TextStyle(color: AppColors.textHint, fontSize: 10),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // Items
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: order.items.map((item) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.purple.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            '×${item.quantity}',
                            style: TextStyle(
                              color: AppColors.purple,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          item.name,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),

          // Notes
          if (order.notes != null && order.notes!.isNotEmpty)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.warning.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.note, color: AppColors.warning, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      order.notes!,
                      style: TextStyle(
                        color: AppColors.warning,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // معلومات التوصيل — متاحة من لحظة وصول الطلب، لا تنتظر جهوزيته
          if (order.orderType == OrderType.delivery && !_isTerminal)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
              child: _DriverPanel(
                order: order,
                isUpdating: _isUpdating,
                onAssign: _openAssignDriver,
                onUnassign: _unassignDriver,
              ),
            ),

          // Expandable section
          if (_expanded) ...[
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _timeCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: TextStyle(color: AppColors.textPrimary),
                    decoration: const InputDecoration(
                      labelText: 'وقت التحضير (دقائق)',
                      hintText: 'مثال: 20',
                      prefixIcon: Icon(Icons.timer_outlined),
                      suffixText: 'دقيقة',
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _notesCtrl,
                    maxLines: 2,
                    style: TextStyle(color: AppColors.textPrimary),
                    decoration: const InputDecoration(
                      labelText: 'ملاحظة للعميل',
                      hintText: 'مثال: تأخير بسيط...',
                      prefixIcon: Icon(Icons.message),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Action buttons
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Expand button
                    TextButton.icon(
                      onPressed: () => setState(() => _expanded = !_expanded),
                      icon: Icon(
                        _expanded ? Icons.expand_less : Icons.expand_more,
                        size: 18,
                      ),
                      label: Text(_expanded ? 'إخفاء' : 'تفاصيل'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.textHint,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ),

                    // Status buttons
                    if (_isUpdating)
                      const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    else
                      Row(
                        children: [
                          if (order.status == OrderStatus.pending)
                            _ActionBtn(
                              label: AppStrings.confirm,
                              color: AppColors.statusConfirmed,
                              icon: Icons.thumb_up,
                              onTap: _confirmOrder,
                            ),
                          if (order.status == OrderStatus.confirmed)
                            _ActionBtn(
                              label: AppStrings.startPreparing,
                              color: AppColors.statusPreparing,
                              icon: Icons.restaurant,
                              onTap: () => _updateStatus(OrderStatus.preparing),
                            ),
                          if (order.status == OrderStatus.preparing)
                            _ActionBtn(
                              label: AppStrings.markReady,
                              color: AppColors.statusReady,
                              icon: Icons.check_circle,
                              onTap: () => _updateStatus(OrderStatus.ready),
                            ),
                          // للاستلام من المطعم: يُنهي المطبخ الطلب مباشرة. للتوصيل: لوحة
                          // المندوب أعلاه (تظهر منذ وصول الطلب) هي المسؤولة عن الإسناد/الحالة
                          if (order.status == OrderStatus.ready &&
                              order.orderType == OrderType.pickup)
                            _ActionBtn(
                              label: AppStrings.markDelivered,
                              color: AppColors.statusDelivered,
                              icon: Icons.done_all,
                              onTap: () => _updateStatus(OrderStatus.delivered),
                            ),
                          if (order.status == OrderStatus.outForDelivery)
                            _ActionBtn(
                              label: AppStrings.markDelivered,
                              color: AppColors.statusDelivered,
                              icon: Icons.done_all,
                              onTap: () => _updateStatus(OrderStatus.delivered),
                            ),
                          const SizedBox(width: 8),
                          // الإلغاء متاح فقط قبل خروج الطلب فعلياً للتوصيل (أو تسليمه) — بعدها
                          // المندوب يحمل الطلب بالفعل ولا يجوز إلغاؤه من المطبخ بضغطة واحدة
                          if (order.status != OrderStatus.ready &&
                              order.status != OrderStatus.outForDelivery &&
                              !_isTerminal)
                            _ActionBtn(
                              label: 'إلغاء',
                              color: AppColors.error,
                              icon: Icons.cancel,
                              onTap: () => _updateStatus(OrderStatus.cancelled),
                            ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    )
        .animate(delay: Duration(milliseconds: widget.index * 60))
        .fadeIn()
        .slideY(begin: 0.1);
  }
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.label,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 15),
        label: Text(label, style: TextStyle(fontSize: 12)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}

// لوحة إسناد المندوب — تظهر منذ لحظة وصول الطلب (لا تنتظر الجاهزية)، وتوضح
// هل المندوب وافق على الاستلام بعد أم لا زال بانتظار ردّه
class _DriverPanel extends StatelessWidget {
  final OrderModel order;
  final bool isUpdating;
  final VoidCallback onAssign;
  final VoidCallback onUnassign;

  const _DriverPanel({
    required this.order,
    required this.isUpdating,
    required this.onAssign,
    required this.onUnassign,
  });

  @override
  Widget build(BuildContext context) {
    if (order.driverId == null) {
      return Align(
        alignment: Alignment.centerRight,
        child: OutlinedButton.icon(
          onPressed: isUpdating ? null : onAssign,
          icon: Icon(Icons.delivery_dining, size: 16),
          label: const Text('تعيين مندوب', style: TextStyle(fontSize: 12)),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.purple,
            side: BorderSide(color: AppColors.purple.withValues(alpha: 0.4)),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      );
    }

    final accepted = order.driverAcceptedAt != null;
    final color = accepted ? AppColors.success : AppColors.warning;
    final canUnassign = order.status != OrderStatus.outForDelivery;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Icon(accepted ? Icons.check_circle : Icons.hourglass_top, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              accepted
                  ? 'المندوب ${order.driverName} وافق ✅'
                  : 'بانتظار موافقة المندوب: ${order.driverName}',
              style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
          if (canUnassign)
            IconButton(
              onPressed: isUpdating ? null : onUnassign,
              icon: Icon(Icons.close, size: 16, color: AppColors.error),
              tooltip: 'إلغاء تعيين المندوب',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            ),
        ],
      ),
    );
  }
}

class _AssignDriverDialog extends ConsumerWidget {
  final OrderModel order;
  const _AssignDriverDialog({required this.order});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final driversAsync = ref.watch(allDriversProvider);
    final activeCounts = ref.watch(driverActiveOrderCountsProvider);

    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420, maxHeight: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: const Text(
                'تعيين مندوب للطلب',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            Flexible(
              child: driversAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(32),
                  child: LoadingWidget(),
                ),
                error: (e, _) => Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text('خطأ: $e', style: TextStyle(color: AppColors.error)),
                ),
                data: (drivers) {
                  if (drivers.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(
                        'لا يوجد مناديب مسجّلين بعد — أضفهم من لوحة الإدارة',
                        style: TextStyle(color: AppColors.textHint),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  final sorted = [...drivers]
                    ..sort((a, b) =>
                        (activeCounts[a.id] ?? 0).compareTo(activeCounts[b.id] ?? 0));
                  return ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: sorted.length,
                    itemBuilder: (_, i) {
                      final d = sorted[i];
                      final count = activeCounts[d.id] ?? 0;
                      final isBusy = count > 0;
                      final statusColor = !d.isAvailable
                          ? AppColors.textHint
                          : isBusy
                              ? AppColors.warning
                              : AppColors.success;
                      return ListTile(
                        onTap: () async {
                          await OrderService.assignDriver(
                            order.id,
                            d.id,
                            d.name,
                            d.phone.isEmpty ? null : d.phone,
                          );
                          if (context.mounted) Navigator.pop(context);
                        },
                        leading: CircleAvatar(
                          backgroundColor: statusColor.withOpacity(0.15),
                          child: Icon(Icons.delivery_dining, color: statusColor),
                        ),
                        title: Text(d.name,
                            style: TextStyle(
                                color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                        subtitle: Text(
                          !d.isAvailable
                              ? 'غير متصل'
                              : isBusy
                                  ? 'مشغول — $count طلب حالي'
                                  : 'متاح الآن',
                          style: TextStyle(color: statusColor, fontSize: 12),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إلغاء'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
