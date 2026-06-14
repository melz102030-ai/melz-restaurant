import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/user_model.dart';
import '../../../core/services/auth_service.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('المستخدمون'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () => _showAddStaffDialog(context),
            icon: const Icon(Icons.person_add),
            tooltip: 'إضافة موظف',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              style: const TextStyle(color: AppColors.textPrimary),
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
                      ...admins.asMap().entries.map((e) => _UserTile(user: e.value, index: e.key)),
                    ],
                    if (kitchen.isNotEmpty) ...[
                      _RoleHeader(role: UserRole.kitchen, count: kitchen.length),
                      ...kitchen.asMap().entries.map((e) => _UserTile(user: e.value, index: e.key)),
                    ],
                    if (customers.isNotEmpty) ...[
                      _RoleHeader(role: UserRole.customer, count: customers.length),
                      ...customers.asMap().entries.map((e) => _UserTile(user: e.value, index: e.key)),
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
  const _UserTile({required this.user, required this.index});

  @override
  Widget build(BuildContext context) {
    final roleColors = {
      UserRole.admin: AppColors.purple,
      UserRole.kitchen: AppColors.manjawi,
      UserRole.customer: AppColors.textSecondary,
    };
    final roleLabels = {
      UserRole.admin: 'إدارة',
      UserRole.kitchen: 'مطبخ',
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
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  user.phone,
                  style: const TextStyle(color: AppColors.textHint, fontSize: 12),
                ),
                Text(
                  'منذ ${DateFormat('dd/MM/yyyy').format(user.createdAt)}',
                  style: const TextStyle(color: AppColors.textHint, fontSize: 11),
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
            onSelected: (role) => AuthService.changeUserRole(user.id, role),
            itemBuilder: (_) => UserRole.values.map((r) {
              return PopupMenuItem<UserRole>(
                value: r,
                child: Text(
                  roleLabels[r] ?? '',
                  style: const TextStyle(color: AppColors.textPrimary),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    ).animate(delay: Duration(milliseconds: index * 30)).fadeIn();
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
    setState(() => _isSaving = true);
    try {
      final user = UserModel(
        id: '',
        phone: _phoneCtrl.text.trim(),
        name: _nameCtrl.text.trim(),
        role: _selectedRole,
        createdAt: DateTime.now(),
      );
      // Add staff user to Firestore with password
      await AuthService.createStaffUser(
          _phoneCtrl.text.trim(), _nameCtrl.text.trim(), _selectedRole);
      if (mounted) Navigator.pop(context);
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
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: const InputDecoration(labelText: 'الاسم'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: const InputDecoration(labelText: 'رقم الجوال', hintText: '+966XXXXXXXXX'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _passwordCtrl,
            obscureText: _obscure,
            style: const TextStyle(color: AppColors.textPrimary),
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
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: const InputDecoration(labelText: 'الصلاحية'),
            items: const [
              DropdownMenuItem(value: UserRole.admin, child: Text('إدارة')),
              DropdownMenuItem(value: UserRole.kitchen, child: Text('مطبخ')),
            ],
            onChanged: (v) {
              if (v != null) setState(() => _selectedRole = v);
            },
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
