import 'package:pharmacare/core/error/exceptions.dart';
import 'package:pharmacare/core/error/failures.dart';
import 'package:pharmacare/core/network/api_result.dart';
import 'package:pharmacare/features/auth/domain/entities/user_entity.dart';
import 'package:pharmacare/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:pharmacare/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl(this.remoteDataSource);

  @override
  Future<ApiResult<UserEntity>> completeProfile({
    required String name,
    String? phone,
    String? gender,
    String? dateOfBirth,
    String? avatarUrl,
  }) async {
    try {
      final user = await remoteDataSource.completeProfile(
        name: name,
        phone: phone,
        gender: gender,
        dateOfBirth: dateOfBirth,
        avatarUrl: avatarUrl,
      );
      return ApiSuccess(user);
    } on ServerException catch (e) {
      return ApiFailure(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException {
      return const ApiFailure(NetworkFailure());
    } on AuthException {
      return const ApiFailure(AuthFailure());
    } catch (e) {
      return ApiFailure(UnexpectedFailure(message: e.toString()));
    }
  }
}
