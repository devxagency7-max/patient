import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pharmacare/core/error/exceptions.dart';
import 'package:pharmacare/core/network/api_client.dart';
import 'package:pharmacare/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:pharmacare/features/auth/data/models/user_model.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;
  final FirebaseAuth firebaseAuth;

  AuthRemoteDataSourceImpl({
    required this.apiClient,
    required this.firebaseAuth,
  });

  @override
  Future<String> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user == null) {
        throw const AuthException(message: 'Login failed. User not found.');
      }
      return credential.user!.uid;
    } on FirebaseAuthException catch (e) {
      throw AuthException(message: e.message ?? 'Authentication failed');
    } catch (e) {
      throw AuthException(message: e.toString());
    }
  }

  @override
  Future<String> registerWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user == null) {
        throw const AuthException(message: 'Registration failed.');
      }
      return credential.user!.uid;
    } on FirebaseAuthException catch (e) {
      throw AuthException(message: e.message ?? 'Authentication failed');
    } catch (e) {
      throw AuthException(message: e.toString());
    }
  }

  @override
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      await googleSignIn
          .signOut(); // Force Google Account picker to show every time
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await firebaseAuth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw AuthException(message: e.message ?? 'Authentication failed');
    } catch (e) {
      throw AuthException(message: e.toString());
    }
  }

  @override
  Future<void> logout() async {
    try {
      await firebaseAuth.signOut();
      await GoogleSignIn().signOut();
    } catch (e) {
      throw AuthException(message: 'Logout failed: ${e.toString()}');
    }
  }

  @override
  Future<String?> getIdToken({bool forceRefresh = false}) async {
    final user = firebaseAuth.currentUser;
    if (user != null) {
      return await user.getIdToken(forceRefresh);
    }
    return null;
  }

  @override
  Future<UserModel> syncUser({
    required String email,
    required String name,
    required String phoneNumber,
    String? avatarUrl,
  }) async {
    try {
      final token = await getIdToken();
      if (token == null) {
        throw const AuthException(message: 'Firebase token not found.');
      }

      // التوكن يُضاف تلقائياً عبر _AuthInterceptor — لا حاجة لضبطه يدوياً.
      final response = await apiClient.dio.post(
        'users/sync',
        data: {
          'email': email,
          if (name.isNotEmpty) 'name': name,
          if (name.isNotEmpty) 'displayName': name,
          if (phoneNumber.isNotEmpty) 'phoneNumber': phoneNumber,
          if (avatarUrl != null && avatarUrl.isNotEmpty) 'avatarUrl': avatarUrl,
        },
      );

      if (response.data['success'] == true) {
        final user = UserModel.fromJson(response.data['data']);
        apiClient.setCurrentUserId(user.id);
        return user;
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to sync user',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] ?? e.message ?? 'Network error',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<UserModel> getProfile() async {
    try {
      final token = await getIdToken();
      if (token == null) {
        throw const AuthException(message: 'Firebase token not found.');
      }

      // التوكن يُضاف تلقائياً عبر _AuthInterceptor.
      final response = await apiClient.dio.get('users/me');

      if (response.data['success'] == true) {
        final user = UserModel.fromJson(response.data['data']);
        apiClient.setCurrentUserId(user.id);
        return user;
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to get profile',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] ?? e.message ?? 'Network error',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
