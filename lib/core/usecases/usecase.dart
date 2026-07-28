import 'package:pharmacare/core/network/api_result.dart';

abstract class UseCase<T, Params> {
  Future<ApiResult<T>> call(Params params);
}

class NoParams {
  const NoParams();
}
