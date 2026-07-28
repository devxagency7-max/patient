import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String firebaseUid;
  final String email;
  final String name;
  final String? phone;
  final String? gender;
  final String? dateOfBirth;
  final String? avatarUrl;
  final List<String> roles;
  final String status;
  final bool isNewUser;

  const UserEntity({
    required this.id,
    required this.firebaseUid,
    required this.email,
    required this.name,
    this.phone,
    this.gender,
    this.dateOfBirth,
    this.avatarUrl,
    required this.roles,
    required this.status,
    this.isNewUser = false,
  });

  @override
  List<Object?> get props => [
        id,
        firebaseUid,
        email,
        name,
        phone,
        gender,
        dateOfBirth,
        avatarUrl,
        roles,
        status,
        isNewUser,
      ];
}
