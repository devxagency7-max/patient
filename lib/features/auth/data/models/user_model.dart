import 'package:pharmacare/features/auth/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.firebaseUid,
    required super.email,
    required super.name,
    super.phone,
    super.gender,
    super.dateOfBirth,
    super.avatarUrl,
    required super.roles,
    required super.status,
    super.isNewUser = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? '',
      firebaseUid: json['firebaseUid'] as String? ?? '',
      email: json['email'] as String? ?? '',
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? json['phoneNumber'] as String?,
      gender: json['gender'] as String?,
      dateOfBirth: json['dateOfBirth'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      roles: (json['roles'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
      status: json['status'] as String? ?? 'Active',
      isNewUser: json['isNewUser'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firebaseUid': firebaseUid,
      'email': email,
      'name': name,
      'phone': phone,
      'gender': gender,
      'dateOfBirth': dateOfBirth,
      'avatarUrl': avatarUrl,
      'roles': roles,
      'status': status,
      'isNewUser': isNewUser,
    };
  }
}
