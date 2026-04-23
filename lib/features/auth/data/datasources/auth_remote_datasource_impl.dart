import 'package:pharmacare/core/error/exceptions.dart';
import 'package:pharmacare/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:pharmacare/features/auth/data/models/user_model.dart';

/// تنفيذ مصدر البيانات عن بُعد باستخدام Firebase Auth
/// هنا بس المكان اللي بيعرف Firebase!
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  // TODO: إضافة FirebaseAuth instance لما يتم تهيئة Firebase
  // final FirebaseAuth _firebaseAuth;
  // AuthRemoteDataSourceImpl(this._firebaseAuth);

  @override
  Future<UserModel> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      // TODO: ربط مع Firebase Auth
      // final credential = await _firebaseAuth.signInWithEmailAndPassword(
      //   email: email,
      //   password: password,
      // );
      // final user = credential.user!;
      // return UserModel(
      //   id: user.uid,
      //   email: user.email ?? '',
      //   displayName: user.displayName ?? '',
      //   photoUrl: user.photoURL,
      //   phoneNumber: user.phoneNumber,
      // );

      // بيانات وهمية مؤقتاً للتطوير
      await Future.delayed(const Duration(seconds: 1));
      return UserModel(
        id: 'user_123',
        email: email,
        displayName: 'أحمد محمد',
        createdAt: DateTime.now(),
      );
    } catch (e) {
      throw AuthException(message: _mapFirebaseError(e.toString()));
    }
  }

  @override
  Future<UserModel> registerWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      // TODO: ربط مع Firebase Auth
      await Future.delayed(const Duration(seconds: 1));
      return UserModel(
        id: 'user_new_${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        displayName: name,
        createdAt: DateTime.now(),
      );
    } catch (e) {
      throw AuthException(message: _mapFirebaseError(e.toString()));
    }
  }

  @override
  Future<void> logout() async {
    try {
      // TODO: await _firebaseAuth.signOut();
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      throw const AuthException(message: 'فشل في تسجيل الخروج');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      // TODO: final user = _firebaseAuth.currentUser;
      // if (user == null) return null;
      // return UserModel(...)
      return null;
    } catch (e) {
      throw AuthException(message: e.toString());
    }
  }

  @override
  Future<UserModel> loginWithGoogle() async {
    try {
      // TODO: Google Sign-In
      throw const AuthException(
        message: 'تسجيل الدخول بـ Google غير متاح حالياً',
      );
    } catch (e) {
      throw AuthException(message: _mapFirebaseError(e.toString()));
    }
  }

  @override
  Future<String?> getIdToken() async {
    try {
      // TODO: return await _firebaseAuth.currentUser?.getIdToken();
      return null;
    } catch (e) {
      return null;
    }
  }

  /// تحويل أخطاء Firebase لرسائل عربية واضحة
  String _mapFirebaseError(String error) {
    if (error.contains('user-not-found')) {
      return 'لا يوجد حساب مسجّل بهذا البريد الإلكتروني';
    } else if (error.contains('wrong-password')) {
      return 'كلمة المرور غير صحيحة';
    } else if (error.contains('email-already-in-use')) {
      return 'البريد الإلكتروني مسجّل بالفعل';
    } else if (error.contains('weak-password')) {
      return 'كلمة المرور ضعيفة جداً';
    } else if (error.contains('invalid-email')) {
      return 'البريد الإلكتروني غير صالح';
    } else if (error.contains('too-many-requests')) {
      return 'محاولات كثيرة. يرجى المحاولة لاحقاً';
    } else if (error.contains('network-request-failed')) {
      return 'فشل الاتصال بالإنترنت';
    }
    return 'حدث خطأ غير متوقع: $error';
  }
}
