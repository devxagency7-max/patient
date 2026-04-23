import 'package:dio/dio.dart';
import 'package:pharmacare/core/constants/app_strings.dart';

/// إعداد Dio للتعامل مع الـ API
/// يتضمن: Base URL, Headers, Interceptors, Timeout
class ApiClient {
  late final Dio dio;

  ApiClient() {
    dio = Dio(
      BaseOptions(
        // TODO: غيّر الـ Base URL للسيرفر بتاعك
        baseUrl: 'https://api.pharmacare.com/v1',
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

    // إضافة Interceptors
    dio.interceptors.addAll([_LoggingInterceptor()]);
  }

  /// إضافة الـ Token للـ Headers
  void setAuthToken(String token) {
    dio.options.headers['Authorization'] = 'Bearer $token';
  }

  /// إزالة الـ Token
  void removeAuthToken() {
    dio.options.headers.remove('Authorization');
  }
}

/// Interceptor لعرض الـ Logs في الـ Console
class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    print('🌐 REQUEST[${options.method}] => PATH: ${options.path}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print(
      '✅ RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print(
      '❌ ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}',
    );
    print('❌ MESSAGE: ${err.message}');
    handler.next(err);
  }
}
