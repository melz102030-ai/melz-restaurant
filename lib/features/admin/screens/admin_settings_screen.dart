import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../core/services/settings_service.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/gradient_container.dart';
import '../../../shared/widgets/loading_widget.dart';

class AdminSettingsScreen extends ConsumerStatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  ConsumerState<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends ConsumerState<AdminSettingsScreen> {
  final _nameCtrl = TextEditingController();
  final _minOrderCtrl = TextEditingController();
  final _prepTimeCtrl = TextEditingController();
  final _whatsappCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _welcomeMsgCtrl = TextEditingController();
  bool _allowOrders = true;
  bool _isSaving = false;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await SettingsService.getSettings();
    if (mounted) {
      setState(() {
        _nameCtrl.text = settings.restaurantName;
        _minOrderCtrl.text = settings.minOrderAmount.toString();
        _prepTimeCtrl.text = settings.estimatedPrepTime.toString();
        _whatsappCtrl.text = settings.whatsappNumber;
        _addressCtrl.text = settings.address ?? '';
        _welcomeMsgCtrl.text = settings.welcomeMessage ?? '';
        _allowOrders = settings.allowOrders;
        _isLoaded = true;
      });
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _minOrderCtrl.dispose();
    _prepTimeCtrl.dispose();
    _whatsappCtrl.dispose();
    _addressCtrl.dispose();
    _welcomeMsgCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      // نجلب الإعدادات الحالية ونعدّل عليها بـ copyWith فقط — حتى لا نطغى بالقيم
      // الافتراضية على حقول تخص شاشات أخرى (المظهر/مناطق التوصيل) لا تظهر هنا
      final current = await SettingsService.getSettings();
      final settings = current.copyWith(
        restaurantName: _nameCtrl.text.trim(),
        minOrderAmount: double.tryParse(_minOrderCtrl.text) ?? 30,
        estimatedPrepTime: int.tryParse(_prepTimeCtrl.text) ?? 30,
        whatsappNumber: _whatsappCtrl.text.trim(),
        address: _addressCtrl.text.trim().isEmpty ? null : _addressCtrl.text.trim(),
        welcomeMessage: _welcomeMsgCtrl.text.trim().isEmpty
            ? null
            : _welcomeMsgCtrl.text.trim(),
        allowOrders: _allowOrders,
      );

      await SettingsService.updateSettings(settings);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حفظ الإعدادات بنجاح'),
            backgroundColor: AppColors.success,
          ),
        );
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
    if (!_isLoaded) return const LoadingWidget(message: 'تحميل الإعدادات...');

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.settings),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SectionTitle(title: 'معلومات المطعم', icon: Icons.restaurant),
            _Field(controller: _nameCtrl, label: 'اسم المطعم', icon: Icons.store),
            const SizedBox(height: 12),
            _Field(controller: _addressCtrl, label: 'العنوان', icon: Icons.location_on),
            const SizedBox(height: 12),
            _Field(
              controller: _welcomeMsgCtrl,
              label: 'رسالة الترحيب',
              icon: Icons.message,
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            _Field(
              controller: _whatsappCtrl,
              label: 'رقم واتساب المطعم',
              icon: Icons.chat,
              hint: '+966XXXXXXXXX',
              keyboardType: TextInputType.phone,
            ),

            const SizedBox(height: 24),

            _SectionTitle(title: 'الطلبات', icon: Icons.shopping_cart_outlined),
            GlassMorphCard(
              child: _SwitchRow(
                label: 'قبول الطلبات',
                subtitle: 'السماح بتقديم طلبات جديدة (ساعات العمل التفصيلية في تبويب مستقل)',
                value: _allowOrders,
                onChanged: (v) => setState(() => _allowOrders = v),
                icon: Icons.shopping_cart,
              ),
            ),
            const SizedBox(height: 12),
            _Field(
              controller: _minOrderCtrl,
              label: 'الحد الأدنى للطلب',
              hint: '30',
              suffix: AppStrings.sar,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            _Field(
              controller: _prepTimeCtrl,
              label: 'وقت التحضير المتوقع',
              hint: '30',
              suffix: 'دقيقة',
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 32),

            AppButton(
              label: AppStrings.save,
              onPressed: _save,
              isLoading: _isSaving,
              icon: Icons.save,
              width: double.infinity,
            ),

            const SizedBox(height: 16),
            Divider(color: AppColors.surfaceLight),
            const SizedBox(height: 16),

            // Logout button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('تسجيل الخروج'),
                      content: const Text('هل أنت متأكد من تسجيل الخروج؟'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('إلغاء'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          style: TextButton.styleFrom(foregroundColor: AppColors.error),
                          child: const Text('خروج'),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true && mounted) {
                    await ref.read(authProvider.notifier).logout();
                    if (mounted) context.go('/login');
                  }
                },
                icon: Icon(Icons.logout, color: AppColors.error),
                label: const Text('تسجيل الخروج',
                    style: TextStyle(color: AppColors.error)),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.error),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SectionTitle({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: AppColors.purple, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Divider(color: AppColors.surfaceLight)),
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final String? suffix;
  final IconData? icon;
  final int maxLines;
  final TextInputType? keyboardType;

  const _Field({
    required this.controller,
    required this.label,
    this.hint,
    this.suffix,
    this.icon,
    this.maxLines = 1,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: icon != null ? Icon(icon) : null,
        suffix: suffix != null ? Text(suffix!) : null,
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  final String label;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final IconData icon;

  const _SwitchRow({
    required this.label,
    this.subtitle,
    required this.value,
    required this.onChanged,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.textSecondary, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: AppColors.textPrimary)),
              if (subtitle != null)
                Text(subtitle!, style: TextStyle(color: AppColors.textHint, fontSize: 12)),
            ],
          ),
        ),
        Switch(value: value, onChanged: onChanged),
      ],
    );
  }
}

