import 'package:pharmacare/core/network/api_result.dart';
import 'package:pharmacare/features/auth/domain/entities/user_entity.dart';

abstract class ProfileRepository {
  Future<ApiResult<UserEntity>> completeProfile({
    required String name,
    String? phone,
    String? gender,
    String? dateOfBirth,
    String? avatarUrl,
  });
}
