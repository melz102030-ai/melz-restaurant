import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/history_cleanup_service.dart';
import '../providers/admin_provider.dart';

/// مسح سجل التجارب نهائياً قبل بدء التشغيل الفعلي
class AdminClearHistoryScreen extends ConsumerStatefulWidget {
  const AdminClearHistoryScreen({super.key});

  @override
  ConsumerState<AdminClearHistoryScreen> createState() => _AdminClearHistoryScreenState();
}

class _AdminClearHistoryScreenState extends ConsumerState<AdminClearHistoryScreen> {
  static const _confirmWord = 'مسح';

  static const Map<HistoryPart, ({String title, String hint, IconData icon})> _parts = {
    HistoryPart.orders: (
      title: 'الطلبات والتقارير',
      hint: 'كل الطلبات وملخصات التقارير المحفوظة',
      icon: Icons.receipt_long_outlined,
    ),
    HistoryPart.support: (
      title: 'تذاكر الدعم الفني',
      hint: 'كل المحادثات مع العملاء',
      icon: Icons.support_agent_outlined,
    ),
    HistoryPart.verifiedPhones: (
      title: 'الأرقام الموثّقة',
      hint: 'أرقام العملاء التي وثّقها المطبخ بالاتصال',
      icon: Icons.verified_user_outlined,
    ),
  };

  final Set<HistoryPart> _selected = {HistoryPart.orders, HistoryPart.support};
  final Map<HistoryPart, int?> _counts = {};
  bool _running = false;
  int _deleted = 0;

  @override
  void initState() {
    super.initState();
    _loadCounts();
  }

  Future<void> _loadCounts() async {
    for (final part in HistoryPart.values) {
      try {
        final n = await HistoryCleanupService.count(part);
        if (mounted) setState(() => _counts[part] = n);
      } catch (_) {
        if (mounted) setState(() => _counts[part] = null);
      }
    }
  }

  Future<bool> _confirm() async {
    final controller = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('مسح نهائي'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'سيُمسح ما اخترته ولا يمكن استرجاعه أبداً.\n'
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
    if (_selected.isEmpty || !await _confirm()) return;
    setState(() {
      _running = true;
      _deleted = 0;
    });
    String message;
    try {
      final total = await HistoryCleanupService.clear(
        _selected,
        onProgress: (n) {
          if (mounted) setState(() => _deleted = n);
        },
      );
      message = 'تم مسح $total سجل';
    } catch (e) {
      message = 'توقف المسح بعد $_deleted سجل، حاول مرة أخرى';
    }
    // الأرقام المعروضة في التقارير ولوحة التحكم تُقرأ من جديد
    ref.invalidate(adminOrderStatsProvider);
    ref.invalidate(dailyStatsProvider);
    ref.invalidate(closingReportProvider);
    if (!mounted) return;
    setState(() => _running = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    _loadCounts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('مسح السجل')),
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
                    'للتخلص من بيانات التجارب قبل التشغيل الفعلي. المسح نهائي ولا يمكن '
                    'استرجاعه.\nالقائمة والأسعار والإعدادات والموظفون لا تتأثر.',
                    style: TextStyle(color: AppColors.textPrimary, fontSize: 13, height: 1.6),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            color: AppColors.cardBackground,
            child: Column(
              children: [
                for (final part in HistoryPart.values)
                  CheckboxListTile(
                    value: _selected.contains(part),
                    onChanged: _running
                        ? null
                        : (v) => setState(() => v == true ? _selected.add(part) : _selected.remove(part)),
                    activeColor: AppColors.error,
                    secondary: Icon(_parts[part]!.icon, color: AppColors.textSecondary),
                    title: Text(_parts[part]!.title,
                        style: TextStyle(color: AppColors.textPrimary, fontSize: 14)),
                    subtitle: Text(
                      '${_parts[part]!.hint}${_counts.containsKey(part) ? ' · ${_counts[part] ?? '؟'}' : ''}',
                      style: TextStyle(color: AppColors.textHint, fontSize: 12),
                    ),
                  ),
              ],
            ),
          ),
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
              onPressed: _selected.isEmpty ? null : _clear,
              icon: const Icon(Icons.delete_forever_outlined),
              label: const Text('مسح المحدد نهائياً'),
            ),
        ],
      ),
    );
  }
}
