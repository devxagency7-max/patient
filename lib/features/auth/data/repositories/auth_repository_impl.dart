import 'package:pharmacare/core/error/exceptions.dart';
import 'package:pharmacare/core/error/failures.dart';
import 'package:pharmacare/core/network/api_result.dart';
import 'package:pharmacare/core/services/secure_storage_service.dart';
import 'package:pharmacare/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:pharmacare/features/auth/domain/entities/user_entity.dart';
import 'package:pharmacare/features/auth/domain/repositories/auth_repository.dart';
import 'package:pharmacare/features/devices/data/services/device_push_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final SecureStorageService secureStorage;
  final DevicePushService devicePushService;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.secureStorage,
    required this.devicePushService,
  });

  @override
  Future<ApiResult<UserEntity>> login({
    required String email,
    required String password,
  }) async {
    try {
      await remoteDataSource.loginWithEmail(
        email: email,
        password: password,
      );

      // Session is derived from Firebase (currentUser + fresh ID token), so we
      // don't persist the short-lived token as a fake session marker here.

      // Sync with backend using email
      final user = await remoteDataSource.syncUser(
        email: email,
        name: '', // Empty because it's a login, backend will use existing data
        phoneNumber: '',
      );

      await secureStorage.saveUserId(user.id);

      return ApiSuccess(user);
    } on AuthException catch (e) {
      return ApiFailure(AuthFailure(message: e.message));
    } on ServerException catch (e) {
      return ApiFailure(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException {
      return const ApiFailure(NetworkFailure());
    } catch (e) {
      return ApiFailure(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<ApiResult<UserEntity>> register({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    try {
      await remoteDataSource.registerWithEmail(
        email: email,
        password: password,
      );

      // Session is derived from Firebase — no fake token persistence.

      final user = await remoteDataSource.syncUser(
        email: email,
        name: name,
        phoneNumber: phone,
      );

      await secureStorage.saveUserId(user.id);

      return ApiSuccess(user);
    } on AuthException catch (e) {
      return ApiFailure(AuthFailure(message: e.message));
    } on ServerException catch (e) {
      return ApiFailure(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException {
      return const ApiFailure(NetworkFailure());
    } catch (e) {
      return ApiFailure(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<ApiResult<UserEntity?>> signInWithGoogle() async {
    try {
      final credential = await remoteDataSource.signInWithGoogle();
      if (credential == null || credential.user == null) {
        return const ApiSuccess(null);
      }

      final fbUser = credential.user!;
      final user = await remoteDataSource.syncUser(
        email: fbUser.email ?? '',
        name: fbUser.displayName ?? '',
        phoneNumber: fbUser.phoneNumber ?? '',
        avatarUrl: fbUser.photoURL,
      );

      await secureStorage.saveUserId(user.id);

      return ApiSuccess(user);
    } on AuthException catch (e) {
      return ApiFailure(AuthFailure(message: e.message));
    } on ServerException catch (e) {
      return ApiFailure(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException {
      return const ApiFailure(NetworkFailure());
    } catch (e) {
      return ApiFailure(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<ApiResult<void>> logout() async {
    try {
      // Revoke server-side push delivery before wiping local state — Firebase
      // sign-out alone does not remove the FCM token from the backend.
      await devicePushService.unregisterCurrentDevice();
      await remoteDataSource.logout();
      await secureStorage.clearAll();
      return const ApiSuccess(null);
    } on AuthException catch (e) {
      return ApiFailure(AuthFailure(message: e.message));
    } catch (e) {
      return ApiFailure(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<ApiResult<UserEntity>> getProfile() async {
    try {
      final user = await remoteDataSource.getProfile();
      return ApiSuccess(user);
    } on AuthException catch (e) {
      return ApiFailure(AuthFailure(message: e.message));
    } on ServerException catch (e) {
      return ApiFailure(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException {
      return const ApiFailure(NetworkFailure());
    } catch (e) {
      return ApiFailure(UnexpectedFailure(message: e.toString()));
    }
  }
}
