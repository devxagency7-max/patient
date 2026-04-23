/// الاستثناءات المخصصة - Exceptions
/// تُستخدم في الـ Data Layer فقط ويتم تحويلها لـ Failures

/// استثناء من السيرفر
class ServerException implements Exception {
  final String message;
  final int? statusCode;

  const ServerException({required this.message, this.statusCode});
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
