import 'package:pharmacare/core/error/failures.dart';

/// Sealed class for handling API results cleanly without throwing exceptions in the domain layer
sealed class ApiResult<T> {
  const ApiResult();
}

/// Represents a successful API call
class ApiSuccess<T> extends ApiResult<T> {
  final T data;
  const ApiSuccess(this.data);
}

/// Represents a failed API call, containing the Failure object
class ApiFailure<T> extends ApiResult<T> {
  final Failure failure;
  const ApiFailure(this.failure);
}
