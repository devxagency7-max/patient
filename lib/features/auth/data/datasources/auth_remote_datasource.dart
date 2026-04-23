import 'package:pharmacare/features/auth/data/models/user_model.dart';

/// عقد مصدر البيانات عن بُعد - Auth Remote DataSource Contract
/// يحدد طريقة التواصل مع Firebase / API
abstract class AuthRemoteDataSource {
  /// تسجيل دخول بإيميل وباسورد عبر Firebase
  Future<UserModel> loginWithEmail({
    required String email,
    required String password,
  });

  /// إنشاء حساب جديد عبر Firebase
  Future<UserModel> registerWithEmail({
    required String name,
    required String email,
    required String password,
  });

  /// تسجيل الخروج
  Future<void> logout();

  /// جلب المستخدم الحالي (إن وُجد)
  Future<UserModel?> getCurrentUser();

  /// تسجيل الدخول بحساب Google
  Future<UserModel> loginWithGoogle();

  /// جلب Firebase ID Token (لإرساله للـ Backend API)
  Future<String?> getIdToken();
}
