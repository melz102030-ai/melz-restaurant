import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/user_model.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/services/auth_service.dart';
import '../../../shared/utils/async_utils.dart';
import '../../../shared/widgets/gradient_container.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../providers/admin_provider.dart';

class AdminUsersScreen extends ConsumerStatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  ConsumerState<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends ConsumerState<AdminUsersScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(allUsersProvider);
    final currentUserId = ref.watch(authProvider)?.id;

    return Scaffold(
      appBar: AppBar(
        title: const Text('المستخدمون'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () => _showAddStaffDialog(context),
            icon: Icon(Icons.person_add),
            tooltip: 'إضافة موظف',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              style: TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(
                hintText: 'بحث بالاسم أو الجوال...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
            ),
          ),
          Expanded(
            child: usersAsync.when(
              data: (users) {
                final filtered = _searchQuery.isEmpty
                    ? users
                    : users.where((u) =>
                        u.name.toLowerCase().contains(_searchQuery) ||
                        u.phone.contains(_searchQuery)).toList();

                if (filtered.isEmpty) {
                  return const EmptyState(
                    message: 'لا توجد نتائج',
                    icon: Icons.person_off,
                  );
                }

                // Group by role
                final admins = filtered.where((u) => u.role == UserRole.admin).toList();
                final kitchen = filtered.where((u) => u.role == UserRole.kitchen).toList();
                final customers = filtered.where((u) => u.role == UserRole.customer).toList();

                return ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    if (admins.isNotEmpty) ...[
                      _RoleHeader(role: UserRole.admin, count: admins.length),
                      ...admins.asMap().entries.map((e) => _UserTile(
                          user: e.value, index: e.key, isSelf: e.value.id == currentUserId)),
                    ],
                    if (kitchen.isNotEmpty) ...[
                      _RoleHeader(role: UserRole.kitchen, count: kitchen.length),
                      ...kitchen.asMap().entries.map((e) => _UserTile(
                          user: e.value, index: e.key, isSelf: e.value.id == currentUserId)),
                    ],
                    if (customers.isNotEmpty) ...[
                      _RoleHeader(role: UserRole.customer, count: customers.length),
                      ...customers.asMap().entries.map((e) => _UserTile(
                          user: e.value, index: e.key, isSelf: e.value.id == currentUserId)),
                    ],
                    const SizedBox(height: 32),
                  ],
                );
              },
              loading: () => const LoadingWidget(),
              error: (e, _) => EmptyState(message: 'خطأ: $e', icon: Icons.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddStaffDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const _AddStaffDialog(),
    );
  }
}

class _RoleHeader extends StatelessWidget {
  final UserRole role;
  final int count;
  const _RoleHeader({required this.role, required this.count});

  @override
  Widget build(BuildContext context) {
    final labels = {
      UserRole.admin: 'الإدارة',
      UserRole.kitchen: 'المطبخ',
      UserRole.customer: 'العملاء',
    };
    final colors = {
      UserRole.admin: AppColors.purple,
      UserRole.kitchen: AppColors.manjawi,
      UserRole.customer: AppColors.textSecondary,
    };

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: colors[role]!.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: colors[role]!.withOpacity(0.3)),
            ),
            child: Text(
              '${labels[role]} ($count)',
              style: TextStyle(color: colors[role], fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _UserTile extends StatelessWidget {
  final UserModel user;
  final int index;
  final bool isSelf;
  const _UserTile({required this.user, required this.index, required this.isSelf});

  @override
  Widget build(BuildContext context) {
    final roleColors = {
      UserRole.admin: AppColors.purple,
      UserRole.kitchen: AppColors.manjawi,
      UserRole.driver: AppColors.info,
      UserRole.customer: AppColors.textSecondary,
    };
    final roleLabels = {
      UserRole.admin: 'إدارة',
      UserRole.kitchen: 'مطبخ',
      UserRole.driver: 'مندوب',
      UserRole.customer: 'عميل',
    };
    final color = roleColors[user.role] ?? AppColors.textSecondary;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  user.phone,
                  style: TextStyle(color: AppColors.textHint, fontSize: 12),
                ),
                Text(
                  'منذ ${DateFormat('dd/MM/yyyy').format(user.createdAt)}',
                  style: TextStyle(color: AppColors.textHint, fontSize: 11),
                ),
              ],
            ),
          ),
          // Role badge
          PopupMenuButton<UserRole>(
            color: AppColors.surface,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    roleLabels[user.role] ?? '',
                    style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.arrow_drop_down, color: color, size: 16),
                ],
              ),
            ),
            onSelected: (role) => _confirmRoleChange(context, role, roleLabels),
            itemBuilder: (_) => UserRole.values.map((r) {
              return PopupMenuItem<UserRole>(
                value: r,
                child: Text(
                  roleLabels[r] ?? '',
                  style: TextStyle(color: AppColors.textPrimary),
                ),
              );
            }).toList(),
          ),
          const SizedBox(width: 4),
          PopupMenuButton<String>(
            color: AppColors.surface,
            icon: Icon(Icons.more_vert, color: AppColors.textHint, size: 20),
            onSelected: (action) {
              if (action == 'edit') _showEditNameDialog(context);
              if (action == 'password') _showChangePasswordDialog(context);
              if (action == 'kitchen_toggle') _toggleKitchenAccess(context);
              if (action == 'delete') _confirmDelete(context);
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'edit', child: Text('تعديل الاسم')),
              if (user.role != UserRole.customer)
                const PopupMenuItem(value: 'password', child: Text('تغيير كلمة المرور')),
              // وصول المطبخ — فقط للأدمن والمندوب (المطبخ لديه وصول افتراضياً)
              if (user.role == UserRole.admin || user.role == UserRole.driver)
                PopupMenuItem(
                  value: 'kitchen_toggle',
                  child: Text(user.extraRoles.contains('kitchen')
                      ? 'إزالة وصول المطبخ'
                      : 'منح وصول المطبخ'),
                ),
              PopupMenuItem(
                value: 'delete',
                enabled: !isSelf,
                child: Text(
                  isSelf ? 'حذف (لا يمكن حذف حسابك)' : 'حذف',
                  style: TextStyle(color: isSelf ? AppColors.textHint : AppColors.error),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate(delay: Duration(milliseconds: index * 30)).fadeIn();
  }

  void _showEditNameDialog(BuildContext context) {
    final nameCtrl = TextEditingController(text: user.name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تعديل الاسم'),
        content: TextField(
          controller: nameCtrl,
          autofocus: true,
          style: TextStyle(color: AppColors.textPrimary),
          decoration: const InputDecoration(labelText: 'الاسم'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              final newName = nameCtrl.text.trim();
              if (newName.isEmpty) return;
              Navigator.pop(ctx);
              runOrShowError(context, () => AuthService.adminUpdateUserName(user.id, newName));
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => _ChangePasswordDialog(user: user),
    );
  }

  void _toggleKitchenAccess(BuildContext context) {
    final hasAccess = user.extraRoles.contains('kitchen');
    final newRoles = hasAccess
        ? user.extraRoles.where((r) => r != 'kitchen').toList()
        : [...user.extraRoles, 'kitchen'];
    runOrShowError(context, () => AuthService.setExtraRoles(user.id, newRoles));
  }

  // حذف المستخدم لا رجعة فيه — يفقد الوصول للدخول فوراً (راجع ملاحظة
  // AuthService.deleteUserProfile حول نطاق الحذف الفعلي)
  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف المستخدم'),
        content: Text('هل تريد حذف "${user.name}"؟ سيفقد القدرة على تسجيل الدخول فوراً، ولا يمكن التراجع عن هذا.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              runOrShowError(context, () => AuthService.deleteUserProfile(user.id));
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  // ضغطة واحدة على تصعيد/تخفيض صلاحية مستخدم (خاصة الأدمن) لا رجعة سهلة فيها
  // — تأكيد صريح قبل التنفيذ، بنفس نمط تأكيد الحذف في بقية لوحة الإدارة
  void _confirmRoleChange(
      BuildContext context, UserRole newRole, Map<UserRole, String> roleLabels) {
    if (newRole == user.role) return;

    // ترقية عميل (حساب مجهول بلا كلمة مرور) إلى موظف — يجب إعداد بيانات الدخول
    if (user.role == UserRole.customer && newRole != UserRole.customer) {
      showDialog(
        context: context,
        builder: (_) => _PromoteCustomerDialog(customer: user, targetRole: newRole),
      );
      return;
    }

    // الترقية لصلاحية "إدارة" كاملة أخطر عملية صلاحيات في التطبيق بأكمله —
    // تحتاج حاجزاً إضافياً (كتابة الاسم) بدل نفس تأكيد تغيير أي دور آخر
    if (newRole == UserRole.admin) {
      _confirmAdminPromotion(context);
      return;
    }
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تغيير الصلاحية'),
        content: Text(
          'هل تريد تغيير صلاحية "${user.name}" من "${roleLabels[user.role]}" إلى "${roleLabels[newRole]}"؟',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              runOrShowError(context, () => AuthService.changeUserRole(user.id, newRole));
            },
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );
  }

  void _confirmAdminPromotion(BuildContext context) {
    final confirmCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final matches = confirmCtrl.text.trim() == user.name;
          return AlertDialog(
            title: const Text('منح صلاحية إدارة كاملة'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'هذا يمنح "${user.name}" وصولاً كاملاً لكل بيانات المطعم وإعداداته —'
                  ' للتأكيد، اكتب اسمه بالضبط:',
                ),
                const SizedBox(height: 12),
                Text(user.name,
                    style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                const SizedBox(height: 8),
                TextField(
                  controller: confirmCtrl,
                  onChanged: (_) => setDialogState(() {}),
                  decoration: const InputDecoration(hintText: 'اكتب الاسم هنا'),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
              ElevatedButton(
                onPressed: matches
                    ? () {
                        Navigator.pop(ctx);
                        runOrShowError(
                            context, () => AuthService.changeUserRole(user.id, UserRole.admin));
                      }
                    : null,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                child: const Text('منح صلاحية إدارة'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _PromoteCustomerDialog extends StatefulWidget {
  final UserModel customer;
  final UserRole targetRole;
  const _PromoteCustomerDialog({required this.customer, required this.targetRole});

  @override
  State<_PromoteCustomerDialog> createState() => _PromoteCustomerDialogState();
}

class _PromoteCustomerDialogState extends State<_PromoteCustomerDialog> {
  late final TextEditingController _phoneCtrl;
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscure = true;
  bool _obscureConfirm = true;
  bool _isSaving = false;
  String? _error;

  static const _roleLabels = {
    UserRole.admin: 'إدارة',
    UserRole.kitchen: 'مطبخ',
    UserRole.driver: 'مندوب',
  };

  @override
  void initState() {
    super.initState();
    _phoneCtrl = TextEditingController(text: widget.customer.phone);
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final phone = _phoneCtrl.text.trim();
    final pw = _passwordCtrl.text.trim();
    final confirm = _confirmCtrl.text.trim();

    if (phone.isEmpty || pw.isEmpty || confirm.isEmpty) {
      setState(() => _error = 'جميع الحقول مطلوبة');
      return;
    }
    if (pw != confirm) {
      setState(() => _error = 'كلمة المرور غير متطابقة');
      return;
    }
    if (pw.length < 6) {
      setState(() => _error = 'كلمة المرور 6 أحرف على الأقل');
      return;
    }

    setState(() { _isSaving = true; _error = null; });
    try {
      // نُنشئ حساب موظف جديداً بالجوال+كلمة المرور ونحذف مستند الفايرستور القديم
      await AuthService.promoteCustomerToStaff(
        oldUserId: widget.customer.id,
        phone: phone,
        name: widget.customer.name,
        password: pw,
        newRole: widget.targetRole,
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        setState(() => _error = e.toString().replaceAll('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final roleLabel = _roleLabels[widget.targetRole] ?? widget.targetRole.name;
    return AlertDialog(
      title: Row(children: [
        Icon(Icons.manage_accounts, color: AppColors.purple, size: 20),
        const SizedBox(width: 8),
        Expanded(child: Text('ترقية "${widget.customer.name}" إلى $roleLabel',
            maxLines: 2, style: const TextStyle(fontSize: 15))),
      ]),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'حساب العميل لا يملك كلمة مرور للدخول كموظف.\n'
            'سيُنشأ حساب موظف جديد بهذا الرقم وكلمة المرور.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
            style: TextStyle(color: AppColors.textPrimary),
            decoration: const InputDecoration(
                labelText: 'رقم الجوال', hintText: '+966XXXXXXXXX'),
          ),
          const SizedBox(height: 12),
          _PasswordField(
            controller: _passwordCtrl,
            label: 'كلمة المرور',
            obscure: _obscure,
            onToggle: () => setState(() => _obscure = !_obscure),
          ),
          const SizedBox(height: 12),
          _PasswordField(
            controller: _confirmCtrl,
            label: 'تأكيد كلمة المرور',
            obscure: _obscureConfirm,
            onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
          ),
          if (_error != null) ...[
            const SizedBox(height: 10),
            Text(_error!, style: TextStyle(color: AppColors.error, fontSize: 13)),
          ],
        ],
      ),
      actions: [
        TextButton(
            onPressed: _isSaving ? null : () => Navigator.pop(context),
            child: const Text('إلغاء')),
        ElevatedButton(
          onPressed: _isSaving ? null : _save,
          child: _isSaving
              ? const SizedBox(
                  width: 20, height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : Text('ترقية إلى $roleLabel'),
        ),
      ],
    );
  }
}

class _ChangePasswordDialog extends StatefulWidget {
  final UserModel user;
  const _ChangePasswordDialog({required this.user});

  @override
  State<_ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<_ChangePasswordDialog> {
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isSaving = false;
  String? _error;

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final current = _currentCtrl.text.trim();
    final newPw = _newCtrl.text.trim();
    final confirm = _confirmCtrl.text.trim();

    if (current.isEmpty || newPw.isEmpty || confirm.isEmpty) {
      setState(() => _error = 'جميع الحقول مطلوبة');
      return;
    }
    if (newPw != confirm) {
      setState(() => _error = 'كلمة المرور الجديدة غير متطابقة');
      return;
    }
    if (newPw.length < 6) {
      setState(() => _error = 'كلمة المرور يجب أن تكون 6 أحرف على الأقل');
      return;
    }

    setState(() { _isSaving = true; _error = null; });
    try {
      await AuthService.changeStaffPassword(widget.user.phone, current, newPw);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        setState(() => _error = e.toString().replaceAll('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(children: [
        Icon(Icons.lock_outline, color: AppColors.purple, size: 20),
        const SizedBox(width: 8),
        Expanded(child: Text('تغيير كلمة مرور ${widget.user.name}',
            maxLines: 2, style: const TextStyle(fontSize: 16))),
      ]),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PasswordField(
            controller: _currentCtrl,
            label: 'كلمة المرور الحالية',
            obscure: _obscureCurrent,
            onToggle: () => setState(() => _obscureCurrent = !_obscureCurrent),
          ),
          const SizedBox(height: 12),
          _PasswordField(
            controller: _newCtrl,
            label: 'كلمة المرور الجديدة',
            obscure: _obscureNew,
            onToggle: () => setState(() => _obscureNew = !_obscureNew),
          ),
          const SizedBox(height: 12),
          _PasswordField(
            controller: _confirmCtrl,
            label: 'تأكيد كلمة المرور الجديدة',
            obscure: _obscureConfirm,
            onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: TextStyle(color: AppColors.error, fontSize: 13)),
          ],
        ],
      ),
      actions: [
        TextButton(onPressed: _isSaving ? null : () => Navigator.pop(context),
            child: const Text('إلغاء')),
        ElevatedButton(
          onPressed: _isSaving ? null : _save,
          child: _isSaving
              ? const SizedBox(width: 20, height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('حفظ'),
        ),
      ],
    );
  }
}

class _PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool obscure;
  final VoidCallback onToggle;
  const _PasswordField({
    required this.controller,
    required this.label,
    required this.obscure,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: IconButton(
          icon: Icon(obscure ? Icons.visibility : Icons.visibility_off),
          onPressed: onToggle,
        ),
      ),
    );
  }
}

class _AddStaffDialog extends StatefulWidget {
  const _AddStaffDialog();

  @override
  State<_AddStaffDialog> createState() => _AddStaffDialogState();
}

class _AddStaffDialogState extends State<_AddStaffDialog> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  UserRole _selectedRole = UserRole.kitchen;
  bool _isSaving = false;
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_nameCtrl.text.isEmpty || _phoneCtrl.text.isEmpty || _passwordCtrl.text.isEmpty) {
      return;
    }
    setState(() {
      _isSaving = true;
      _error = null;
    });
    try {
      await AuthService.createStaffUser(_phoneCtrl.text.trim(),
          _nameCtrl.text.trim(), _selectedRole, _passwordCtrl.text.trim());
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('إضافة موظف'),
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
          const SizedBox(height: 12),
          DropdownButtonFormField<UserRole>(
            value: _selectedRole,
            dropdownColor: AppColors.surface,
            style: TextStyle(color: AppColors.textPrimary),
            decoration: const InputDecoration(labelText: 'الصلاحية'),
            items: const [
              DropdownMenuItem(value: UserRole.admin, child: Text('إدارة')),
              DropdownMenuItem(value: UserRole.kitchen, child: Text('مطبخ')),
            ],
            onChanged: (v) {
              if (v != null) setState(() => _selectedRole = v);
            },
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: TextStyle(color: AppColors.error, fontSize: 13)),
          ],
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
