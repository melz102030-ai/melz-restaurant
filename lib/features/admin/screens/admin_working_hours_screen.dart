import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/settings_model.dart';
import '../../../core/models/work_shift_model.dart';
import '../../../core/services/settings_service.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/gradient_container.dart';
import '../../../shared/widgets/loading_widget.dart';

Future<String?> _pickTimeString(BuildContext context, String initial) async {
  final parts = initial.split(':');
  final h = int.tryParse(parts.isNotEmpty ? parts[0] : '8') ?? 8;
  final m = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;
  final picked = await showTimePicker(
    context: context,
    initialTime: TimeOfDay(hour: h, minute: m),
    builder: (ctx, child) => Directionality(textDirection: TextDirection.rtl, child: child!),
  );
  if (picked == null) return null;
  return '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
}

class AdminWorkingHoursScreen extends ConsumerStatefulWidget {
  const AdminWorkingHoursScreen({super.key});

  @override
  ConsumerState<AdminWorkingHoursScreen> createState() => _AdminWorkingHoursScreenState();
}

class _AdminWorkingHoursScreenState extends ConsumerState<AdminWorkingHoursScreen> {
  final Map<String, List<WorkShift>> _hours = {for (final d in kWeekDays) d.$1: <WorkShift>[]};
  bool _isOpen = true;
  bool _isLoaded = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final settings = await SettingsService.getSettings();
    if (!mounted) return;
    setState(() {
      _isOpen = settings.isOpen;
      if (settings.hasDetailedHours) {
        for (final d in kWeekDays) {
          _hours[d.$1] = List<WorkShift>.from(settings.workingHours[d.$1] ?? const []);
        }
      } else {
        // نقطة بداية معقولة: نفس النطاق القديم لكل الأيام، بدل البدء من فراغ تام
        final shift = WorkShift(open: settings.openTime, close: settings.closeTime);
        for (final d in kWeekDays) {
          _hours[d.$1] = [shift];
        }
      }
      _isLoaded = true;
    });
  }

  Future<void> _addShift(String dayKey) async {
    final open = await _pickTimeString(context, '08:00');
    if (open == null || !mounted) return;
    final close = await _pickTimeString(context, '22:00');
    if (close == null || !mounted) return;
    setState(() => _hours[dayKey] = [..._hours[dayKey]!, WorkShift(open: open, close: close)]);
  }

  Future<void> _editShiftTime(String dayKey, int index, bool isOpen) async {
    final current = _hours[dayKey]![index];
    final picked = await _pickTimeString(context, isOpen ? current.open : current.close);
    if (picked == null || !mounted) return;
    setState(() {
      final list = List<WorkShift>.from(_hours[dayKey]!);
      list[index] = isOpen ? current.copyWith(open: picked) : current.copyWith(close: picked);
      _hours[dayKey] = list;
    });
  }

  void _removeShift(String dayKey, int index) {
    setState(() {
      final list = List<WorkShift>.from(_hours[dayKey]!)..removeAt(index);
      _hours[dayKey] = list;
    });
  }

  Future<void> _copyToAll(String sourceDayKey, String sourceLabel) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('نسخ لجميع الأيام'),
        content: Text('سيتم استبدال ساعات كل الأيام بنفس ساعات "$sourceLabel". متابعة؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('نسخ')),
        ],
      ),
    );
    if (confirmed != true) return;
    final source = List<WorkShift>.from(_hours[sourceDayKey]!);
    setState(() {
      for (final d in kWeekDays) {
        _hours[d.$1] = source.map((s) => WorkShift(open: s.open, close: s.close)).toList();
      }
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('تم نسخ الساعات لجميع الأيام — لا تنسَ الحفظ'),
        backgroundColor: AppColors.success,
      ));
    }
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      final current = await SettingsService.getSettings();
      await SettingsService.updateSettings(
        current.copyWith(isOpen: _isOpen, workingHours: Map<String, List<WorkShift>>.from(_hours)),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('تم حفظ ساعات العمل'),
          backgroundColor: AppColors.success,
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded) {
      return const Scaffold(body: LoadingWidget(message: 'تحميل ساعات العمل...'));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('ساعات العمل'), automaticallyImplyLeading: false),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GlassMorphCard(
            child: Row(
              children: [
                Icon(Icons.store, color: AppColors.textSecondary, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('المطعم مفتوح', style: TextStyle(color: AppColors.textPrimary)),
                      Text('مفتاح يدوي يطغى على الجدول — أطفئه لإغلاق الطلبات فوراً بغض النظر عن الجدول',
                          style: TextStyle(color: AppColors.textHint, fontSize: 12)),
                    ],
                  ),
                ),
                Switch(value: _isOpen, onChanged: (v) => setState(() => _isOpen = v)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'حدّد شفتاً واحداً أو أكثر لكل يوم (مثال: شفت ظهر + شفت مساء) — يوم بلا شفتات يُعتبر عطلة',
            style: TextStyle(color: AppColors.textHint, fontSize: 12),
          ),
          const SizedBox(height: 12),
          for (final d in kWeekDays)
            _DayCard(
              dayKey: d.$1,
              label: d.$2,
              shifts: _hours[d.$1]!,
              onAddShift: () => _addShift(d.$1),
              onRemoveShift: (i) => _removeShift(d.$1, i),
              onEditShiftTime: (i, isOpen) => _editShiftTime(d.$1, i, isOpen),
              onCopyToAll: () => _copyToAll(d.$1, d.$2),
            ),
          const SizedBox(height: 24),
          AppButton(
            label: 'حفظ ساعات العمل',
            icon: Icons.save,
            width: double.infinity,
            isLoading: _isSaving,
            onPressed: _save,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _DayCard extends StatelessWidget {
  final String dayKey;
  final String label;
  final List<WorkShift> shifts;
  final VoidCallback onAddShift;
  final ValueChanged<int> onRemoveShift;
  final void Function(int index, bool isOpen) onEditShiftTime;
  final VoidCallback onCopyToAll;

  const _DayCard({
    required this.dayKey,
    required this.label,
    required this.shifts,
    required this.onAddShift,
    required this.onRemoveShift,
    required this.onEditShiftTime,
    required this.onCopyToAll,
  });

  @override
  Widget build(BuildContext context) {
    final isClosed = shifts.isEmpty;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Text(label,
                        style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    if (isClosed)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text('عطلة',
                            style: TextStyle(color: AppColors.error, fontSize: 11, fontWeight: FontWeight.w600)),
                      ),
                  ],
                ),
              ),
              IconButton(
                onPressed: isClosed ? null : onCopyToAll,
                icon: Icon(Icons.copy_all, size: 18, color: AppColors.textSecondary),
                tooltip: 'نسخ لجميع الأيام',
              ),
              TextButton.icon(
                onPressed: onAddShift,
                icon: Icon(Icons.add, size: 16),
                label: const Text('شفت'),
              ),
            ],
          ),
          if (!isClosed)
            ...shifts.asMap().entries.map((e) => Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Row(
                    children: [
                      Expanded(
                        child: _TimeChip(
                          label: RestaurantSettings.fmtHHMM(e.value.open),
                          onTap: () => onEditShiftTime(e.key, true),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Icon(Icons.arrow_back, size: 14),
                      ),
                      Expanded(
                        child: _TimeChip(
                          label: RestaurantSettings.fmtHHMM(e.value.close),
                          onTap: () => onEditShiftTime(e.key, false),
                        ),
                      ),
                      IconButton(
                        onPressed: () => onRemoveShift(e.key),
                        icon: Icon(Icons.close, size: 18, color: AppColors.error),
                        tooltip: 'حذف الشفت',
                      ),
                    ],
                  ),
                )),
        ],
      ),
    );
  }
}

class _TimeChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _TimeChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.access_time, size: 14, color: AppColors.purple),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
