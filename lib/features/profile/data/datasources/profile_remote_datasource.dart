import 'package:pharmacare/features/auth/domain/entities/user_entity.dart';

abstract class ProfileRemoteDataSource {
  Future<UserEntity> completeProfile({
    required String name,
    String? phone,
    String? gender,
    String? dateOfBirth,
    String? avatarUrl,
  });
}
