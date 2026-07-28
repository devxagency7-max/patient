import 'package:equatable/equatable.dart';

/// الكلاس الأساسي للأخطاء - Failure Base Class
/// كل أنواع الأخطاء في التطبيق بتورث من هنا
abstract class Failure extends Equatable {
  final String message;
  final int? statusCode;

  const Failure({required this.message, this.statusCode});

  @override
  List<Object?> get props => [message, statusCode];
}

/// خطأ من السيرفر (API Error)
class ServerFailure extends Failure {
  const ServerFailure({required super.message, super.statusCode});
}

/// خطأ في الاتصال بالإنترنت
class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'لا يوجد اتصال بالإنترنت. يرجى التحقق من الاتصال.',
  });
}

/// خطأ في المصادقة (Unauthorized)
class AuthFailure extends Failure {
  const AuthFailure({
    super.message = 'فشل في المصادقة. يرجى تسجيل الدخول مرة أخرى.',
  });
}

/// خطأ ممنوع الوصول (403) - غالبًا بسبب انتهاء العلاقة بين المريض والصيدلي
class ForbiddenFailure extends Failure {
  const ForbiddenFailure({
    super.message = 'لا تملك صلاحية لتنفيذ هذا الإجراء.',
  }) : super(statusCode: 403);
}

/// خطأ المحادثة مقفولة بسبب انتهاء العلاقة بين المريض والصيدلي
class ConversationClosedFailure extends Failure {
  const ConversationClosedFailure({
    super.message = 'هذه المحادثة مقفولة.',
  }) : super(statusCode: 400);
}

/// خطأ في التخزين المحلي (Cache)
class CacheFailure extends Failure {
  const CacheFailure({super.message = 'حدث خطأ في التخزين المحلي.'});
}

/// خطأ في Firebase
class FirebaseFailure extends Failure {
  const FirebaseFailure({required super.message});
}

/// خطأ غير متوقع
class UnexpectedFailure extends Failure {
  const UnexpectedFailure({
    super.message = 'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى.',
  });
}
