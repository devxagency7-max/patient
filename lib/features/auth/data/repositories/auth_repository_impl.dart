import 'package:dartz/dartz.dart';
import 'package:pharmacare/core/error/exceptions.dart';
import 'package:pharmacare/core/error/failures.dart';
import 'package:pharmacare/core/services/secure_storage_service.dart';
import 'package:pharmacare/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:pharmacare/features/auth/domain/entities/user_entity.dart';
import 'package:pharmacare/features/auth/domain/repositories/auth_repository.dart';

/// تنفيذ الـ Repository — يربط بين الـ Domain والـ DataSource
/// هنا بيتم:
/// 1. استدعاء الـ DataSource
/// 2. تحويل الـ Exceptions لـ Failures
/// 3. حفظ/حذف الـ Tokens
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final SecureStorageService secureStorage;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.secureStorage,
  });

  @override
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  }) async {
    try {
      final user = await remoteDataSource.loginWithEmail(
        email: email,
        password: password,
      );

      // حفظ الـ Token بعد نجاح تسجيل الدخول
      final token = await remoteDataSource.getIdToken();
      if (token != null) {
        await secureStorage.saveAccessToken(token);
      }
      await secureStorage.saveUserId(user.id);

      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } on NetworkException {
      return const Left(NetworkFailure());
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final user = await remoteDataSource.registerWithEmail(
        name: name,
        email: email,
        password: password,
      );

      final token = await remoteDataSource.getIdToken();
      if (token != null) {
        await secureStorage.saveAccessToken(token);
      }
      await secureStorage.saveUserId(user.id);

      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } on NetworkException {
      return const Left(NetworkFailure());
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await remoteDataSource.logout();
      await secureStorage.clearAll();
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    try {
      final user = await remoteDataSource.getCurrentUser();
      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> loginWithGoogle() async {
    try {
      final user = await remoteDataSource.loginWithGoogle();

      final token = await remoteDataSource.getIdToken();
      if (token != null) {
        await secureStorage.saveAccessToken(token);
      }
      await secureStorage.saveUserId(user.id);

      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } on NetworkException {
      return const Left(NetworkFailure());
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }
}
