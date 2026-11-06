import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/history_cleanup_service.dart';
import '../providers/admin_provider.dart';

/// مسح سجل الطلبات الماضية (التجارب) نهائياً قبل بدء التشغيل الفعلي
class AdminClearHistoryScreen extends ConsumerStatefulWidget {
  const AdminClearHistoryScreen({super.key});

  @override
  ConsumerState<AdminClearHistoryScreen> createState() => _AdminClearHistoryScreenState();
}

class _AdminClearHistoryScreenState extends ConsumerState<AdminClearHistoryScreen> {
  static const _confirmWord = 'مسح';

  int? _count;
  bool _countFailed = false;
  bool _running = false;
  int _deleted = 0;

  @override
  void initState() {
    super.initState();
    _loadCount();
  }

  Future<void> _loadCount() async {
    try {
      final n = await HistoryCleanupService.countOrders();
      if (mounted) setState(() => _count = n);
    } catch (_) {
      if (mounted) setState(() => _countFailed = true);
    }
  }

  Future<bool> _confirm() async {
    final controller = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('مسح سجل الطلبات'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ستُمسح كل الطلبات الماضية ولا يمكن استرجاعها أبداً.\n'
                'للتأكيد اكتب كلمة «$_confirmWord»:',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                autofocus: true,
                textAlign: TextAlign.center,
                onChanged: (_) => setDialogState(() {}),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppColors.error),
              onPressed: controller.text.trim() == _confirmWord
                  ? () => Navigator.pop(context, true)
                  : null,
              child: const Text('امسح الآن'),
            ),
          ],
        ),
      ),
    );
    controller.dispose();
    return ok == true;
  }

  Future<void> _clear() async {
    if (!await _confirm()) return;
    setState(() {
      _running = true;
      _deleted = 0;
    });
    String message;
    try {
      final total = await HistoryCleanupService.clearOrders(
        onProgress: (n) {
          if (mounted) setState(() => _deleted = n);
        },
      );
      message = 'تم مسح $total طلب';
    } catch (e) {
      message = 'توقف المسح بعد $_deleted طلب، حاول مرة أخرى';
    }
    // أرقام التقارير ولوحة التحكم تُقرأ من جديد
    ref.invalidate(adminOrderStatsProvider);
    ref.invalidate(dailyStatsProvider);
    ref.invalidate(closingReportProvider);
    if (!mounted) return;
    setState(() => _running = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    _loadCount();
  }

  @override
  Widget build(BuildContext context) {
    final countText = _countFailed
        ? 'تعذّر حساب عدد الطلبات'
        : _count == null
            ? 'جارٍ حساب عدد الطلبات...'
            : 'عدد الطلبات الحالية: $_count';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('مسح سجل الطلبات')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.error.withValues(alpha: 0.4)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.warning_amber_rounded, color: AppColors.error),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'يمسح كل الطلبات الماضية وأرقامها في التقارير، للتخلص من طلبات '
                    'التجارب قبل التشغيل الفعلي. المسح نهائي ولا يمكن استرجاعه.\n'
                    'القائمة والأسعار والإعدادات والموظفون والدعم الفني لا تتأثر.',
                    style: TextStyle(color: AppColors.textPrimary, fontSize: 13, height: 1.6),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(countText,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
          const SizedBox(height: 20),
          if (_running) ...[
            const LinearProgressIndicator(),
            const SizedBox(height: 8),
            Text('جارٍ المسح... $_deleted',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary)),
          ] else
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.error,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: _count == 0 ? null : _clear,
              icon: const Icon(Icons.delete_forever_outlined),
              label: const Text('مسح كل الطلبات الماضية'),
            ),
        ],
      ),
    );
  }
}
