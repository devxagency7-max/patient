import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmacare/core/network/api_client.dart';
import 'package:pharmacare/core/services/secure_storage_service.dart';
import 'package:pharmacare/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:pharmacare/features/auth/data/datasources/auth_remote_datasource_impl.dart';
import 'package:pharmacare/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:pharmacare/features/auth/domain/repositories/auth_repository.dart';
import 'package:pharmacare/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:pharmacare/features/auth/domain/usecases/login_usecase.dart';
import 'package:pharmacare/features/auth/domain/usecases/logout_usecase.dart';
import 'package:pharmacare/features/auth/domain/usecases/register_usecase.dart';

/// ==================================================
/// حقن التبعيات المركزي — Dependency Injection
/// كل الـ Providers في مكان واحد
/// ==================================================

// ===== Core Services =====

/// API Client
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

/// Secure Storage
final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

// ===== Auth Feature =====

/// Auth DataSource
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl();
});

/// Auth Repository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remoteDataSource: ref.watch(authRemoteDataSourceProvider),
    secureStorage: ref.watch(secureStorageProvider),
  );
});

/// Login UseCase
final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(ref.watch(authRepositoryProvider));
});

/// Register UseCase
final registerUseCaseProvider = Provider<RegisterUseCase>((ref) {
  return RegisterUseCase(ref.watch(authRepositoryProvider));
});

/// Logout UseCase
final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  return LogoutUseCase(ref.watch(authRepositoryProvider));
});

/// Get Current User UseCase
final getCurrentUserUseCaseProvider = Provider<GetCurrentUserUseCase>((ref) {
  return GetCurrentUserUseCase(ref.watch(authRepositoryProvider));
});
