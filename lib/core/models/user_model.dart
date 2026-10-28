import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/system_admins.dart';

enum UserRole { customer, admin, kitchen, driver }

/// دور النظام — يُحدِّد مستوى الصلاحيات الإدارية فوق الدور الأساسي
enum SystemRole {
  none,           // موظف عادي — صلاحياته من حقل permissions فقط
  assistantAdmin, // مساعد المدير — وصول كامل إلا منح/سحب systemRole
  superAdmin,     // مدير النظام — يُحدَّد في الكود بالهاتف، لا يُلغى من DB
}

class UserModel {
  final String id;
  final String phone;
  final String name;
  final UserRole role;
  final DateTime createdAt;
  final String? fcmToken;
  final bool isAvailable;
  final String? vehicleType;
  final double? savedLat;
  final double? savedLng;
  final String? savedAddress;
  final List<String> extraRoles;
  /// دور النظام المخزَّن في DB — للمدير يأتي التحقق الحقيقي من SystemAdmins
  final SystemRole systemRole;
  /// صلاحيات تفصيلية — تُطبَّق على الأدمن العادي فقط (Perm.*)
  /// مستخدمو النظام (super/assistant) لهم وصول كامل تلقائياً
  final Map<String, bool> permissions;

  const UserModel({
    required this.id,
    required this.phone,
    required this.name,
    required this.role,
    required this.createdAt,
    this.fcmToken,
    this.isAvailable = true,
    this.vehicleType,
    this.savedLat,
    this.savedLng,
    this.savedAddress,
    this.extraRoles = const [],
    this.systemRole = SystemRole.none,
    this.permissions = const {},
  });

  // ─── Computed helpers ──────────────────────────────────────────────────────

  bool get hasSavedLocation => savedLat != null && savedLng != null;

  /// مدير النظام الأساسي — التحقق من الكود لا من قاعدة البيانات
  bool get isSuperAdmin => SystemAdmins.isSuperAdmin(phone);

  /// مساعد المدير — أو المدير نفسه (المدير يتضمن كل صلاحيات المساعد)
  bool get isAssistantAdmin =>
      systemRole == SystemRole.assistantAdmin || isSuperAdmin;

  /// أي من مستويَي إدارة النظام
  bool get isSystemAdmin => isSuperAdmin || systemRole == SystemRole.assistantAdmin;

  bool get hasKitchenAccess =>
      role == UserRole.kitchen ||
      extraRoles.contains('kitchen') ||
      hasPermission('kitchen');

  /// هل لهذا المستخدم صلاحية معيّنة؟
  /// — مستخدمو النظام: نعم افتراضاً، لكن يُحترم الإيقاف الصريح (false) إذا عدّلوا أنفسهم
  /// — الأدمن العادي بلا permissions مُعيَّنة: وصول كامل (تهيئة قديمة)
  /// — الأدمن العادي بـ permissions مُعيَّنة: حسب القيمة المخزَّنة
  bool hasPermission(String key) {
    if (isSystemAdmin) {
      // يحترم الإيقاف الصريح حتى يتمكن المدير/المساعد من تخفيف زحمة الواجهة
      if (permissions[key] == false) return false;
      return true;
    }
    if (role != UserRole.admin) return false;
    if (permissions.isEmpty) return true; // تهيئة قديمة — وصول كامل للمرحلة الانتقالية
    return permissions[key] == true;
  }

  /// هل يستطيع [actor] تعديل هذا المستخدم؟
  bool canBeEditedBy(UserModel actor) {
    // المدير/المساعد يعدّل صلاحياته الخاصة دائماً (لإخفاء/إظهار أقسام عن نفسه)
    if (actor.isSystemAdmin && actor.id == id) return true;
    if (isSuperAdmin) return false;                    // المدير لا يعدّله أحد سواه
    if (actor.isSuperAdmin) return true;              // المدير يعدّل الجميع
    if (actor.isAssistantAdmin && !isSystemAdmin) return true; // المساعد يعدّل غير مستخدمي النظام
    return false;
  }

  // ─── Serialization ─────────────────────────────────────────────────────────

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      phone: map['phone'] ?? '',
      name: map['name'] ?? '',
      role: UserRole.values.firstWhere(
        (r) => r.name == (map['role'] ?? 'customer'),
        orElse: () => UserRole.customer,
      ),
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      fcmToken: map['fcmToken'],
      isAvailable: map['isAvailable'] ?? true,
      vehicleType: map['vehicleType'],
      savedLat: (map['savedLat'] as num?)?.toDouble(),
      savedLng: (map['savedLng'] as num?)?.toDouble(),
      savedAddress: map['savedAddress'],
      extraRoles: List<String>.from(map['extraRoles'] ?? []),
      systemRole: SystemRole.values.firstWhere(
        (r) => r.name == (map['systemRole'] ?? 'none'),
        orElse: () => SystemRole.none,
      ),
      permissions: map['permissions'] != null
          ? Map<String, bool>.from(map['permissions'] as Map)
          : const {},
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'phone': phone,
      'name': name,
      'role': role.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'fcmToken': fcmToken,
      'isAvailable': isAvailable,
      'vehicleType': vehicleType,
      'savedLat': savedLat,
      'savedLng': savedLng,
      'savedAddress': savedAddress,
      'extraRoles': extraRoles,
      'systemRole': systemRole.name,
      'permissions': permissions,
    };
  }

  UserModel copyWith({
    String? name,
    UserRole? role,
    String? fcmToken,
    bool? isAvailable,
    String? vehicleType,
    double? savedLat,
    double? savedLng,
    String? savedAddress,
    List<String>? extraRoles,
    SystemRole? systemRole,
    Map<String, bool>? permissions,
  }) {
    return UserModel(
      id: id,
      phone: phone,
      name: name ?? this.name,
      role: role ?? this.role,
      createdAt: createdAt,
      fcmToken: fcmToken ?? this.fcmToken,
      isAvailable: isAvailable ?? this.isAvailable,
      vehicleType: vehicleType ?? this.vehicleType,
      savedLat: savedLat ?? this.savedLat,
      savedLng: savedLng ?? this.savedLng,
      savedAddress: savedAddress ?? this.savedAddress,
      extraRoles: extraRoles ?? this.extraRoles,
      systemRole: systemRole ?? this.systemRole,
      permissions: permissions ?? this.permissions,
    );
  }
}
