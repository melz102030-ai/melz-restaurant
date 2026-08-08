import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/models/delivery_zone_model.dart';
import '../../../core/providers/delivery_zone_provider.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../core/services/delivery_zone_service.dart';
import '../../../core/services/settings_service.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../customer/screens/delivery_location_picker_screen.dart';

class AdminDeliveryZonesScreen extends ConsumerWidget {
  const AdminDeliveryZonesScreen({super.key});

  Future<void> _pickRestaurantLocation(BuildContext context, WidgetRef ref) async {
    final settings = ref.read(settingsProvider);
    final result = await Navigator.of(context, rootNavigator: true).push<DeliveryLocationResult>(
      MaterialPageRoute(
        builder: (_) => DeliveryLocationPickerScreen(
          initialLat: settings.restaurantLat,
          initialLng: settings.restaurantLng,
        ),
      ),
    );
    if (result != null) {
      await SettingsService.updateSettings(
        settings.copyWith(restaurantLat: result.lat, restaurantLng: result.lng),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final zonesAsync = ref.watch(deliveryZonesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('مناطق التوصيل'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () => showDialog(context: context, builder: (_) => const _ZoneDialog()),
            icon: Icon(Icons.add_location_alt),
            tooltip: 'إضافة نطاق',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Restaurant base location
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.purpleDark.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.storefront, color: AppColors.purple, size: 20),
                    const SizedBox(width: 8),
                    Text('موقع المطعم',
                        style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  settings.hasRestaurantLocation
                      ? '${settings.restaurantLat!.toStringAsFixed(5)}, ${settings.restaurantLng!.toStringAsFixed(5)}'
                      : 'لم يتم تحديد موقع المطعم بعد — لازم لحساب المسافات',
                  style: TextStyle(
                    color: settings.hasRestaurantLocation
                        ? AppColors.textSecondary
                        : AppColors.warning,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () => _pickRestaurantLocation(context, ref),
                  icon: Icon(Icons.edit_location_alt, size: 18),
                  label: Text(settings.hasRestaurantLocation ? 'تغيير الموقع' : 'تحديد موقع المطعم'),
                ),
                Divider(height: 28, color: AppColors.surfaceLight),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('التسعير حسب المسافة',
                              style: TextStyle(
                                  color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 2),
                          Text(
                            'عند التفعيل: تُحسب رسوم التوصيل حسب النطاق الذي تقع فيه مسافة العميل — بدلاً من الرسم الثابت',
                            style: TextStyle(color: AppColors.textHint, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: settings.useDeliveryZones,
                      activeColor: AppColors.purple,
                      onChanged: settings.hasRestaurantLocation
                          ? (v) => SettingsService.updateSettings(
                              settings.copyWith(useDeliveryZones: v))
                          : null,
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          Text(
            'نطاقات المسافة والأسعار',
            style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 10),

          zonesAsync.when(
            loading: () => const Padding(padding: EdgeInsets.all(24), child: LoadingWidget()),
            error: (e, _) => Padding(
              padding: const EdgeInsets.all(24),
              child: Text('خطأ: $e', style: TextStyle(color: AppColors.error)),
            ),
            data: (zones) {
              if (zones.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: EmptyState(
                    message: 'لا توجد نطاقات بعد\nبدون نطاقات سيُستخدم رسم التوصيل الثابت للجميع',
                    icon: Icons.map_outlined,
                  ),
                );
              }
              return Column(
                children: zones.asMap().entries.map((e) => _ZoneTile(zone: e.value, index: e.key)).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ZoneTile extends StatelessWidget {
  final DeliveryZone zone;
  final int index;
  const _ZoneTile({required this.zone, required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.purpleDark.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.purple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.social_distance, color: AppColors.purple, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(zone.name,
                    style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                Text(
                  'حتى ${zone.maxDistanceKm.toStringAsFixed(1)} كم · ${zone.fee.toStringAsFixed(2)} ${AppStrings.sar}',
                  style: TextStyle(color: AppColors.textHint, fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => showDialog(context: context, builder: (_) => _ZoneDialog(zone: zone)),
            icon: Icon(Icons.edit, color: AppColors.textSecondary, size: 20),
          ),
          IconButton(
            onPressed: () => showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('حذف النطاق'),
                content: Text('هل تريد حذف "${zone.name}"؟'),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(ctx), child: const Text(AppStrings.cancel)),
                  TextButton(
                    onPressed: () {
                      DeliveryZoneService.deleteZone(zone.id);
                      Navigator.pop(ctx);
                    },
                    child: const Text(AppStrings.delete, style: TextStyle(color: AppColors.error)),
                  ),
                ],
              ),
            ),
            icon: Icon(Icons.delete_outline, color: AppColors.error, size: 20),
          ),
        ],
      ),
    ).animate(delay: Duration(milliseconds: index * 40)).fadeIn();
  }
}

class _ZoneDialog extends StatefulWidget {
  final DeliveryZone? zone;
  const _ZoneDialog({this.zone});

  @override
  State<_ZoneDialog> createState() => _ZoneDialogState();
}

class _ZoneDialogState extends State<_ZoneDialog> {
  late final _nameCtrl = TextEditingController(text: widget.zone?.name ?? '');
  late final _distanceCtrl =
      TextEditingController(text: widget.zone?.maxDistanceKm.toString() ?? '');
  late final _feeCtrl = TextEditingController(text: widget.zone?.fee.toString() ?? '');
  bool _isSaving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _distanceCtrl.dispose();
    _feeCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    final distance = double.tryParse(_distanceCtrl.text.trim());
    final fee = double.tryParse(_feeCtrl.text.trim());
    if (name.isEmpty || distance == null || fee == null) return;

    setState(() => _isSaving = true);
    try {
      if (widget.zone == null) {
        await DeliveryZoneService.addZone(
          DeliveryZone(id: '', name: name, maxDistanceKm: distance, fee: fee),
        );
      } else {
        await DeliveryZoneService.updateZone(
          widget.zone!.copyWith(name: name, maxDistanceKm: distance, fee: fee),
        );
      }
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.zone == null ? 'إضافة نطاق' : 'تعديل النطاق'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameCtrl,
            style: TextStyle(color: AppColors.textPrimary),
            decoration: const InputDecoration(labelText: 'اسم النطاق', hintText: 'مثال: قريب'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _distanceCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: TextStyle(color: AppColors.textPrimary),
            decoration: const InputDecoration(labelText: 'حتى مسافة (كم)', hintText: 'مثال: 5'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _feeCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: TextStyle(color: AppColors.textPrimary),
            decoration: const InputDecoration(labelText: 'رسم التوصيل', hintText: 'مثال: 10'),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text(AppStrings.cancel)),
        ElevatedButton(
          onPressed: _isSaving ? null : _save,
          child: Text(widget.zone == null ? 'إضافة' : 'حفظ'),
        ),
      ],
    );
  }
}
