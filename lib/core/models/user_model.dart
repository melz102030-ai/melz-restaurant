import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { customer, admin, kitchen, driver }

class UserModel {
  final String id;
  final String phone;
  final String name;
  final UserRole role;
  final DateTime createdAt;
  final String? fcmToken;
  // Driver-only fields
  final bool isAvailable;
  final String? vehicleType;

  const UserModel({
    required this.id,
    required this.phone,
    required this.name,
    required this.role,
    required this.createdAt,
    this.fcmToken,
    this.isAvailable = true,
    this.vehicleType,
  });

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
    };
  }

  UserModel copyWith({
    String? name,
    UserRole? role,
    String? fcmToken,
    bool? isAvailable,
    String? vehicleType,
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
    );
  }
}
