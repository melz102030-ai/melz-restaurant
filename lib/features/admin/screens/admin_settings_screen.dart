import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/models/settings_model.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../core/services/settings_service.dart';
import '../../../shared/widgets/admin_action_widgets.dart';
import '../../../shared/widgets/app_button.dart';
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
  final _phoneCtrl = TextEditingController();
  final _reviewUrlCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _welcomeMsgCtrl = TextEditingController();
  CashPaymentPolicy _cashPolicy = CashPaymentPolicy.both;
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
        _phoneCtrl.text = settings.restaurantPhone;
        _reviewUrlCtrl.text = settings.googleReviewUrl ?? '';
        _addressCtrl.text = settings.address ?? '';
        _welcomeMsgCtrl.text = settings.welcomeMessage ?? '';
        _cashPolicy = settings.cashPaymentPolicy;
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
    _phoneCtrl.dispose();
    _reviewUrlCtrl.dispose();
    _addressCtrl.dispose();
    _welcomeMsgCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final minOrder = double.tryParse(_minOrderCtrl.text.trim());
    if (minOrder == null || minOrder < 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('الحد الأدنى للطلب رقم غير صحيح'),
        backgroundColor: AppColors.error,
      ));
      return;
    }
    final prepTime = int.tryParse(_prepTimeCtrl.text.trim());
    if (prepTime == null || prepTime < 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('مدة التحضير التقديرية رقم غير صحيح'),
        backgroundColor: AppColors.error,
      ));
      return;
    }

    setState(() => _isSaving = true);
    try {
      // نجلب الإعدادات الحالية ونعدّل عليها بـ copyWith فقط — حتى لا نطغى بالقيم
      // الافتراضية على حقول تخص شاشات أخرى (المظهر/مناطق التوصيل) لا تظهر هنا
      final current = await SettingsService.getSettings();
      final settings = current.copyWith(
        restaurantName: _nameCtrl.text.trim(),
        minOrderAmount: minOrder,
        estimatedPrepTime: prepTime,
        whatsappNumber: _whatsappCtrl.text.trim(),
        restaurantPhone: _phoneCtrl.text.trim(),
        googleReviewUrl:
            _reviewUrlCtrl.text.trim().isEmpty ? null : _reviewUrlCtrl.text.trim(),
        address: _addressCtrl.text.trim().isEmpty ? null : _addressCtrl.text.trim(),
        welcomeMessage: _welcomeMsgCtrl.text.trim().isEmpty
            ? null
            : _welcomeMsgCtrl.text.trim(),
        cashPaymentPolicy: _cashPolicy,
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
            const SizedBox(height: 12),
            _Field(
              controller: _phoneCtrl,
              label: 'رقم هاتف المطعم (للاتصال المباشر من شاشة تتبع الطلب)',
              icon: Icons.call,
              hint: '05XXXXXXXX',
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            _Field(
              controller: _reviewUrlCtrl,
              label: 'رابط تقييم المطعم على خرائط جوجل (اختياري)',
              icon: Icons.star_outline,
              hint: 'https://g.page/r/.../review',
            ),

            const SizedBox(height: 24),

            _SectionTitle(title: 'الطلبات', icon: Icons.shopping_cart_outlined),
            // مفتاحا "المطعم مفتوح" و"قبول الطلبات" انتقلا لشاشة "ساعات العمل"
            // ليكونا معاً في مكان واحد بوضوح — كانا سابقاً موزَّعين بين هذه
            // الشاشة وشاشة أخرى، فقد يُغلق أحدهما ظاناً أنه أغلق المطعم
            // بالكامل بينما الآخر يبقى مفعّلاً
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.purple.withOpacity(0.06),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.purple, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'التحكم بفتح/إغلاق المطعم وقبول الطلبات موجود في شاشة "ساعات العمل"',
                      style: TextStyle(color: AppColors.purple, fontSize: 12.5),
                    ),
                  ),
                ],
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

            const SizedBox(height: 24),

            _SectionTitle(title: 'طريقة الدفع', icon: Icons.payments_outlined),
            Text(
              'الدفع الإلكتروني (بطاقة/آبل باي/مدى) غير مفعّل بعد، وطريقة الدفع الوحيدة'
              ' حالياً هي النقد — تحكّم متى وأين يُسمح به للعميل.',
              style: TextStyle(color: AppColors.textHint, fontSize: 12.5),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                TypeChip(
                  label: CashPaymentPolicy.both.label,
                  icon: Icons.check_circle_outline,
                  selected: _cashPolicy == CashPaymentPolicy.both,
                  onTap: () => setState(() => _cashPolicy = CashPaymentPolicy.both),
                ),
                TypeChip(
                  label: CashPaymentPolicy.deliveryOnly.label,
                  icon: Icons.delivery_dining_outlined,
                  selected: _cashPolicy == CashPaymentPolicy.deliveryOnly,
                  onTap: () => setState(() => _cashPolicy = CashPaymentPolicy.deliveryOnly),
                ),
                TypeChip(
                  label: CashPaymentPolicy.pickupOnly.label,
                  icon: Icons.storefront_outlined,
                  selected: _cashPolicy == CashPaymentPolicy.pickupOnly,
                  onTap: () => setState(() => _cashPolicy = CashPaymentPolicy.pickupOnly),
                ),
                TypeChip(
                  label: CashPaymentPolicy.disabled.label,
                  icon: Icons.money_off,
                  selected: _cashPolicy == CashPaymentPolicy.disabled,
                  onTap: () => setState(() => _cashPolicy = CashPaymentPolicy.disabled),
                ),
              ],
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

