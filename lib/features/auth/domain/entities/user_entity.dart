import 'package:equatable/equatable.dart';

/// كيان المستخدم - User Entity
/// هذا الكيان نقي (Pure) ومش بيعرف حاجة عن JSON أو API
/// يُستخدم فقط في الـ Domain و Presentation Layers
class UserEntity extends Equatable {
  final String id;
  final String email;
  final String displayName;
  final String? photoUrl;
  final String? phoneNumber;
  final DateTime? createdAt;

  const UserEntity({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoUrl,
    this.phoneNumber,
    this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    email,
    displayName,
    photoUrl,
    phoneNumber,
    createdAt,
  ];
}
