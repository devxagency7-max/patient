import 'package:pharmacare/features/auth/domain/entities/user_entity.dart';

/// موديل المستخدم - User Model
/// يعرف يتحول من وإلى JSON
/// يورث من UserEntity (الكيان النقي)
class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    required super.displayName,
    super.photoUrl,
    super.phoneNumber,
    super.createdAt,
  });

  /// تحويل من JSON إلى UserModel
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      displayName:
          json['displayName'] as String? ?? json['name'] as String? ?? '',
      photoUrl: json['photoUrl'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
    );
  }

  /// تحويل من UserModel إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'phoneNumber': phoneNumber,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  /// تحويل من UserEntity إلى UserModel
  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      email: entity.email,
      displayName: entity.displayName,
      photoUrl: entity.photoUrl,
      phoneNumber: entity.phoneNumber,
      createdAt: entity.createdAt,
    );
  }
}
