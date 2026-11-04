import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/models/order_model.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../core/services/cloudinary_service.dart';
import '../../../core/services/order_service.dart';
import '../../../core/services/receipt_print_service.dart';
import '../../../shared/utils/async_utils.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/gradient_container.dart';
import '../providers/admin_provider.dart';

class AdminOrdersScreen extends ConsumerStatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  ConsumerState<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends ConsumerState<AdminOrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const _tabs = [
    (label: 'الكل', status: null),
    (label: 'انتظار', status: OrderStatus.pending),
    (label: 'تأكيد', status: OrderStatus.confirmed),
    (label: 'تحضير', status: OrderStatus.preparing),
    (label: 'جاهز', status: OrderStatus.ready),
    (label: 'توصيل', status: OrderStatus.outForDelivery),
    (label: 'تسليم', status: OrderStatus.delivered),
    (label: 'ملغى', status: OrderStatus.cancelled),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.orders),
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: _tabs.map((t) => Tab(text: t.label)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _tabs.map((t) => _OrdersList(status: t.status)).toList(),
      ),
    );
  }
}

class _OrdersList extends ConsumerWidget {
  final OrderStatus? status;
  const _OrdersList({required this.status});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(allOrdersProvider(status));

    return ordersAsync.when(
      data: (orders) {
        if (orders.isEmpty) {
          return const EmptyState(
            message: 'لا توجد طلبات',
            icon: Icons.receipt_long_outlined,
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: orders.length,
          itemBuilder: (_, i) => _AdminOrderCard(order: orders[i], index: i),
        );
      },
      loading: () => const LoadingWidget(),
      error: (e, _) => EmptyState(message: 'خطأ: $e', icon: Icons.error),
    );
  }
}

class _AdminOrderCard extends StatefulWidget {
  final OrderModel order;
  final int index;
  const _AdminOrderCard({required this.order, required this.index});

  @override
  State<_AdminOrderCard> createState() => _AdminOrderCardState();
}

class _AdminOrderCardState extends State<_AdminOrderCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final color = order.status.color;
    final isActive =
        order.status != OrderStatus.delivered && order.status != OrderStatus.cancelled;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.receipt_long, color: color, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${order.customerName} · #${order.orderNumberLabel}',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        GestureDetector(
                          onTap: () =>
                              launchUrl(Uri(scheme: 'tel', path: order.customerPhone)),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.call, color: AppColors.success, size: 13),
                              const SizedBox(width: 4),
                              Text(
                                order.customerPhone,
                                style: TextStyle(color: AppColors.textHint, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${DateFormat('dd/MM/yyyy - hh:mm a').format(order.createdAt)} · ${order.orderType.label}',
                          style: TextStyle(color: AppColors.textHint, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          order.status.label,
                          style: TextStyle(
                            color: color,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${order.total.toStringAsFixed(2)} ${AppStrings.sar}',
                        style: TextStyle(
                          color: AppColors.purple,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  Icon(_expanded ? Icons.expand_less : Icons.expand_more,
                      color: AppColors.textHint),
                ],
              ),
            ),
          ),
          // أزرار تقدّم الحالة ظاهرة دائماً بلا حاجة لتوسيع البطاقة — أكثر
          // عملية متكررة يومياً في هذه الشاشة، كانت مخفية خلف توسيع إجباري
          if (isActive)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: _StatusActionButtons(order: order),
            ),
          if (_expanded) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Divider(color: AppColors.surfaceLight),
                  ...order.items.map(
                    (item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Text(
                            '×${item.shownQuantity}',
                            style: TextStyle(
                              color: AppColors.purple,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              item.name,
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          ),
                          Text(
                            '${item.total.toStringAsFixed(2)} ${AppStrings.sar}',
                            style: TextStyle(color: AppColors.textHint, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (order.notes != null && order.notes!.isNotEmpty) ...[
                    Divider(color: AppColors.surfaceLight),
                    Row(
                      children: [
                        Icon(Icons.note, color: AppColors.textHint, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            order.notes!,
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (order.paymentMethod == PaymentMethod.manualBankTransfer) ...[
                    Divider(color: AppColors.surfaceLight),
                    _PaymentReceiptRow(order: order),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    ).animate(delay: Duration(milliseconds: widget.index * 50)).fadeIn();
  }
}

// صف مراجعة التحويل البنكي اليدوي — يظهر فقط لطلبات هذه الطريقة تحديداً
class _PaymentReceiptRow extends StatelessWidget {
  final OrderModel order;
  const _PaymentReceiptRow({required this.order});

  void _confirmPayment(BuildContext context, {required bool paid}) {
    final amount = '${order.total.toStringAsFixed(2)} ${AppStrings.sar}';
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(paid ? 'تأكيد استلام المبلغ' : 'إلغاء تأكيد الاستلام'),
        content: Text(paid
            ? 'هل وصل مبلغ $amount من "${order.customerName}" إلى الحساب؟'
            : 'سيعود طلب "${order.customerName}" إلى انتظار مراجعة التحويل.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('تراجع')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              runOrShowError(
                context,
                () => OrderService.updatePaymentStatus(
                  order.id,
                  paid ? PaymentStatus.paid : PaymentStatus.pending,
                ),
              );
            },
            child: Text(paid ? 'تأكيد' : 'إلغاء التأكيد'),
          ),
        ],
      ),
    );
  }

  void _confirmRefund(BuildContext context) {
    final amount = '${order.total.toStringAsFixed(2)} ${AppStrings.sar}';
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('تسجيل استرجاع المبلغ'),
        content: Text('هل أعدت مبلغ $amount إلى "${order.customerName}"؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('تراجع')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              runOrShowError(
                context,
                () => OrderService.updatePaymentStatus(order.id, PaymentStatus.refunded),
              );
            },
            child: const Text('تم الاسترجاع'),
          ),
        ],
      ),
    );
  }

  // الرابط يُطلب من الخادم أولاً، ثم يُفتح بضغطة في النافذة لأن المتصفح قد يمنع فتح
  // صفحة جديدة بعد الانتظار
  Future<void> _openReceipt(BuildContext context) async {
    final stored = order.paymentReceiptUrl!;
    final isOldLink =
        stored.startsWith('https://res.cloudinary.com/${CloudinaryService.cloudName}/');
    try {
      final url = isOldLink ? stored : await CloudinaryService.receiptUrl(order.id);
      if (!context.mounted) return;
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('إيصال التحويل'),
          content: Text(isOldLink ? 'إيصال قديم' : 'الرابط صالح لمدة ١٠ دقائق'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('إغلاق'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
              },
              child: const Text('فتح الإيصال'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: AppColors.error,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final paid = order.paymentStatus == PaymentStatus.paid;
    final refunded = order.paymentStatus == PaymentStatus.refunded;
    final refundDue = paid && order.status == OrderStatus.cancelled;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(Icons.account_balance, color: AppColors.textHint, size: 16),
            const SizedBox(width: 8),
            Text('تحويل بنكي · ', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            Text(
              order.paymentStatus.label,
              style: TextStyle(
                color: order.paymentStatus == PaymentStatus.paid
                    ? AppColors.success
                    : order.paymentStatus == PaymentStatus.failed
                        ? AppColors.error
                        : AppColors.warning,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (order.paymentReceiptUrl != null)
          OutlinedButton.icon(
            onPressed: () => _openReceipt(context),
            icon: const Icon(Icons.receipt_long, size: 18),
            label: const Text('عرض إيصال التحويل'),
          )
        else
          Text('لم يُرفق العميل إيصالاً بعد',
              style: TextStyle(color: AppColors.textHint, fontSize: 12.5)),
        const SizedBox(height: 8),
        if (refundDue)
          OutlinedButton.icon(
            onPressed: () => _confirmRefund(context),
            style: OutlinedButton.styleFrom(foregroundColor: AppColors.warning),
            icon: const Icon(Icons.currency_exchange, size: 18),
            label: const Text('الطلب ملغى: سجّل استرجاع المبلغ'),
          )
        else if (refunded)
          const SizedBox.shrink()
        else if (paid)
          TextButton.icon(
            onPressed: () => _confirmPayment(context, paid: false),
            icon: const Icon(Icons.undo, size: 18),
            label: const Text('إلغاء تأكيد الاستلام'),
          )
        else
          OutlinedButton.icon(
            onPressed: () => _confirmPayment(context, paid: true),
            style: OutlinedButton.styleFrom(foregroundColor: AppColors.success),
            icon: const Icon(Icons.check_circle_outline, size: 18),
            label: const Text('تأكيد استلام المبلغ'),
          ),
      ],
    );
  }
}

class _StatusActionButtons extends ConsumerWidget {
  final OrderModel order;
  const _StatusActionButtons({required this.order});

  void _advance(BuildContext context, OrderStatus to) {
    runOrShowError(
      context,
      () => OrderService.advanceOrderStatus(order.id, from: order.status, to: to),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        // قبول الطلب من المطبخ فقط، لأنه يحدد وقت التحضير ويطبع على طابعته
        if (order.status == OrderStatus.confirmed)
          _ActionButton(
            label: 'بدء التحضير',
            icon: Icons.restaurant,
            color: AppColors.statusPreparing,
            onTap: () => _advance(context, OrderStatus.preparing),
          ),
        if (order.status == OrderStatus.preparing)
          _ActionButton(
            label: 'جاهز',
            icon: Icons.check_circle,
            color: AppColors.statusReady,
            onTap: () => _advance(context, OrderStatus.ready),
          ),
        if (order.status == OrderStatus.ready ||
            order.status == OrderStatus.outForDelivery)
          _ActionButton(
            label: 'تم التسليم',
            icon: Icons.done_all,
            color: AppColors.statusDelivered,
            onTap: () => _advance(context, OrderStatus.delivered),
          ),
        _ActionButton(
          label: 'إعادة طباعة',
          icon: Icons.print_outlined,
          color: AppColors.purple,
          onTap: () => ReceiptPrintService.printOrder(order, ref.read(settingsProvider)),
        ),
        _ActionButton(
          label: 'إلغاء',
          icon: Icons.cancel,
          color: AppColors.error,
          onTap: () => _confirmCancel(context),
        ),
      ],
    );
  }

  // إلغاء طلب عميل لا رجعة فيه (قد يكون طلباً مدفوعاً فعلياً) — يحتاج تأكيداً
  // صريحاً كأي حذف آخر في لوحة الإدارة، بدل تنفيذه بضغطة واحدة مباشرة
  void _confirmCancel(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('إلغاء الطلب'),
        content: Text('هل تريد إلغاء طلب "${order.customerName}"؟ لا يمكن التراجع عن هذا.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('تراجع')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _advance(context, OrderStatus.cancelled);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('إلغاء الطلب'),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16),
      label: Text(label, style: TextStyle(fontSize: 12)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}
