import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:pharmacare/core/config/app_config.dart';
import 'package:pharmacare/core/constants/app_strings.dart';

/// إعداد Dio للتعامل مع الـ API
/// يتضمن: Base URL, Headers, Interceptors, Timeout, وإعادة تحديث التوكن عند 401
class ApiClient {
  late final Dio dio;
  final FirebaseAuth _firebaseAuth;

  // The backend's own user id (UserEntity.id from /users/sync or /users/me)
  // — NOT the same value as the Firebase UID. Set by AuthRemoteDataSourceImpl
  // right after it parses a UserModel, so it's populated before the user can
  // reach any screen that needs it (chat is reached only after
  // AuthCubit.fetchProfile() runs at app start).
  String? _resolvedUserId;

  ApiClient(this._firebaseAuth) {
    dio = Dio(
      BaseOptions(
        // Base URL from central config (.env) — single source of truth.
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'App-Name': AppStrings.appName,
        },
      ),
    );

    // ترتيب الـ Interceptors مهم: المصادقة أولاً، ثم معالجة 401، ثم اللوج.
    dio.interceptors.addAll([
      _AuthInterceptor(_firebaseAuth),
      _TokenRefreshInterceptor(dio, _firebaseAuth),
      if (kDebugMode) _LoggingInterceptor(),
    ]);
  }

  /// جلب الـ Token الحالي من Firebase لمصادقة الـ SignalR WebSockets
  Future<String?> getFirebaseToken() async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      return await user.getIdToken();
    }
    return null;
  }

  /// معرّف المستخدم الحقيقي عند الباك إند — هو نفسه `senderId` اللي بيرجعه
  /// الباك إند لرسائل الشات، ويُستخدم لتحديد "هل الرسالة مني أنا؟".
  ///
  /// **مش Firebase UID**: الـ backend بيرجّع `id` و`firebaseUid` كحقلين
  /// منفصلين تمامًا في UserEntity (شوف user_entity.dart) — استخدام
  /// Firebase UID هنا كان بيخلي كل رسايل المريض تتنسب غلط للصيدلي في الـ UI،
  /// لأن `senderId` مقارن بقيمة تانية غير اللي الباك إند فعليًا بيبعتها.
  /// الـ fallback لـ Firebase UID هنا بس احتياطي للحظة القصيرة قبل ما
  /// [setCurrentUserId] يتنفذ أول مرة بعد تسجيل الدخول/استرجاع الجلسة.
  String? get currentUserId =>
      _resolvedUserId ?? _firebaseAuth.currentUser?.uid;

  void setCurrentUserId(String id) => _resolvedUserId = id;
}

/// Interceptor لإضافة الـ Token تلقائياً من Firebase على كل طلب.
///
/// المصدر الوحيد لهيدر Authorization — لا نضبطه يدوياً على `dio.options`
/// حتى لا يتسرّب توكن مستخدم إلى مستخدم آخر بعد تسجيل الخروج.
class _AuthInterceptor extends Interceptor {
  final FirebaseAuth _firebaseAuth;

  _AuthInterceptor(this._firebaseAuth);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        // جلب الـ Token (يقوم بتحديثه تلقائياً إذا شارف على الانتهاء)
        final token = await user.getIdToken();
        options.headers['Authorization'] = 'Bearer $token';
      }
      handler.next(options);
    } catch (e) {
      // في حالة فشل جلب الـ Token، نستمر في الطلب (قد ينجح إذا كان الـ Endpoint عام)
      debugPrint('⚠️ AuthInterceptor: Failed to get ID token: $e');
      handler.next(options);
    }
  }
}

/// عند استلام 401: نجبر تحديث توكن Firebase مرة واحدة ونعيد الطلب الأصلي.
/// إذا فشل مجدداً بـ 401 نترك الخطأ يمر (الطبقة الأعلى تُسجّل الخروج).
class _TokenRefreshInterceptor extends Interceptor {
  final Dio _dio;
  final FirebaseAuth _firebaseAuth;

  _TokenRefreshInterceptor(this._dio, this._firebaseAuth);

  static const _retriedFlag = 'x-retried-after-401';

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final response = err.response;
    final alreadyRetried = err.requestOptions.extra[_retriedFlag] == true;

    if (response?.statusCode != 401 || alreadyRetried) {
      return handler.next(err);
    }

    final user = _firebaseAuth.currentUser;
    if (user == null) {
      return handler.next(err);
    }

    try {
      // إجبار تحديث التوكن (getIdToken(true)).
      final freshToken = await user.getIdToken(true);
      if (freshToken == null) {
        return handler.next(err);
      }

      final options = err.requestOptions;
      options.headers['Authorization'] = 'Bearer $freshToken';
      options.extra[_retriedFlag] = true;

      final retried = await _dio.fetch(options);
      return handler.resolve(retried);
    } catch (_) {
      // فشل التحديث أو إعادة المحاولة — نمرّر الخطأ الأصلي.
      return handler.next(err);
    }
  }
}

/// Interceptor لعرض الـ Logs في الـ Console — يعمل في وضع الـ Debug فقط
/// ويُخفي البيانات الحساسة (توكنات/بيانات صحية) من اللوج.
class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint('🌐 REQUEST[${options.method}] => PATH: ${options.path}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint(
      '✅ RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint(
      '❌ ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}',
    );
    debugPrint('❌ MESSAGE: ${err.message}');
    if (err.response?.data != null) {
      debugPrint('❌ RESPONSE DATA: ${err.response?.data}');
    }
    handler.next(err);
  }
}
