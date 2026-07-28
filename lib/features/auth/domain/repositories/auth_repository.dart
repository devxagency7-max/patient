import 'package:pharmacare/core/network/api_result.dart';
import 'package:pharmacare/features/auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<ApiResult<UserEntity>> login({
    required String email,
    required String password,
  });

  Future<ApiResult<UserEntity>> register({
    required String name,
    required String email,
    required String password,
    required String phone,
  });

  Future<ApiResult<UserEntity?>> signInWithGoogle();

  Future<ApiResult<void>> logout();

  Future<ApiResult<UserEntity>> getProfile();
}
