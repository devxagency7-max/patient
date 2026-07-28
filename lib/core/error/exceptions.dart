/// الاستثناءات المخصصة - Exceptions
/// تُستخدم في الـ Data Layer فقط ويتم تحويلها لـ Failures

/// استثناء من السيرفر
class ServerException implements Exception {
  final String message;
  final int? statusCode;
  // معرّف خطأ ثابت من الباك إند (زي "CONVERSATION_CLOSED") — دايمًا null
  // إلا في حالات محددة موثّقة. يُفضّل الاعتماد عليه بدل مقارنة نص message
  // الحر (اللي ممكن يكون بالعربي).
  final String? errorCode;

  const ServerException({
    required this.message,
    this.statusCode,
    this.errorCode,
  });
}

/// استثناء الاتصال بالإنترنت
class NetworkException implements Exception {
  final String message;

  const NetworkException({this.message = 'لا يوجد اتصال بالإنترنت'});
}

/// استثناء المصادقة
class AuthException implements Exception {
  final String message;

  const AuthException({required this.message});
}

/// استثناء التخزين المحلي
class CacheException implements Exception {
  final String message;

  const CacheException({this.message = 'خطأ في التخزين المحلي'});
}
