import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/order_model.dart';
import '../../../core/models/user_model.dart';
import '../../../core/providers/drivers_provider.dart';
import '../../../core/services/auth_service.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../providers/admin_provider.dart';

class AdminDriversScreen extends ConsumerStatefulWidget {
  const AdminDriversScreen({super.key});

  @override
  ConsumerState<AdminDriversScreen> createState() => _AdminDriversScreenState();
}

class _AdminDriversScreenState extends ConsumerState<AdminDriversScreen> {
  @override
  Widget build(BuildContext context) {
    final driversAsync = ref.watch(allDriversProvider);
    final allOrders = ref.watch(allOrdersProvider(null)).valueOrNull ?? const <OrderModel>[];

    final activeCounts = <String, int>{};
    for (final o in allOrders) {
      if (o.driverId == null) continue;
      if (o.status == OrderStatus.ready || o.status == OrderStatus.outForDelivery) {
        activeCounts[o.driverId!] = (activeCounts[o.driverId!] ?? 0) + 1;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('المناديب'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () => showDialog(context: context, builder: (_) => const _AddDriverDialog()),
            icon: Icon(Icons.person_add),
            tooltip: 'إضافة مندوب',
          ),
        ],
      ),
      body: driversAsync.when(
        loading: () => const LoadingWidget(),
        error: (e, _) => EmptyState(message: 'خطأ: $e', icon: Icons.error),
        data: (drivers) {
          if (drivers.isEmpty) {
            return const EmptyState(
              message: 'لا يوجد مناديب بعد\nأضف أول مندوب من الزر أعلاه',
              icon: Icons.delivery_dining,
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: drivers.length,
            itemBuilder: (_, i) => _DriverTile(
              driver: drivers[i],
              activeCount: activeCounts[drivers[i].id] ?? 0,
              index: i,
            ),
          );
        },
      ),
    );
  }
}

class _DriverTile extends StatelessWidget {
  final UserModel driver;
  final int activeCount;
  final int index;
  const _DriverTile({required this.driver, required this.activeCount, required this.index});

  @override
  Widget build(BuildContext context) {
    final statusColor = !driver.isAvailable
        ? AppColors.textHint
        : activeCount > 0
            ? AppColors.warning
            : AppColors.success;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: statusColor.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: statusColor.withOpacity(0.12), shape: BoxShape.circle),
            child: Icon(Icons.delivery_dining, color: statusColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(driver.name,
                    style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                Text(driver.phone, style: TextStyle(color: AppColors.textHint, fontSize: 12)),
                Text(
                  !driver.isAvailable
                      ? 'غير متصل'
                      : activeCount > 0
                          ? 'مشغول — $activeCount طلب حالي'
                          : 'متاح الآن',
                  style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          Switch(
            value: driver.isAvailable,
            activeColor: AppColors.success,
            onChanged: (v) => AuthService.setDriverAvailability(driver.id, v),
          ),
          IconButton(
            onPressed: () => AuthService.changeUserRole(driver.id, UserRole.customer),
            icon: Icon(Icons.person_remove_outlined, color: AppColors.error, size: 20),
            tooltip: 'إلغاء صلاحية المندوب',
          ),
        ],
      ),
    ).animate(delay: Duration(milliseconds: index * 40)).fadeIn();
  }
}

class _AddDriverDialog extends StatefulWidget {
  const _AddDriverDialog();

  @override
  State<_AddDriverDialog> createState() => _AddDriverDialogState();
}

class _AddDriverDialogState extends State<_AddDriverDialog> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _isSaving = false;
  bool _obscure = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_nameCtrl.text.isEmpty || _phoneCtrl.text.isEmpty || _passwordCtrl.text.isEmpty) return;
    setState(() => _isSaving = true);
    try {
      await AuthService.createStaffUser(
        _phoneCtrl.text.trim(),
        _nameCtrl.text.trim(),
        UserRole.driver,
        _passwordCtrl.text.trim(),
      );
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('إضافة مندوب'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameCtrl,
            style: TextStyle(color: AppColors.textPrimary),
            decoration: const InputDecoration(labelText: 'الاسم'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
            style: TextStyle(color: AppColors.textPrimary),
            decoration: const InputDecoration(labelText: 'رقم الجوال', hintText: '+966XXXXXXXXX'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _passwordCtrl,
            obscureText: _obscure,
            style: TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              labelText: 'كلمة المرور',
              suffixIcon: IconButton(
                icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
        ElevatedButton(
          onPressed: _isSaving ? null : _save,
          child: const Text('إضافة'),
        ),
      ],
    );
  }
}
