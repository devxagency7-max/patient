import 'package:firebase_auth/firebase_auth.dart';
import 'package:pharmacare/features/auth/data/models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<String> loginWithEmail({
    required String email,
    required String password,
  });

  Future<String> registerWithEmail({
    required String email,
    required String password,
  });

  Future<UserCredential?> signInWithGoogle();

  Future<void> logout();

  Future<String?> getIdToken({bool forceRefresh = false});

  Future<UserModel> syncUser({
    required String email,
    required String name,
    required String phoneNumber,
    String? avatarUrl,
  });

  Future<UserModel> getProfile();
}
