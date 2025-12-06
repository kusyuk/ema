import 'result.dart';

/// Base use case interface
abstract class UseCase<T, Params> {
  Future<Result<T>> call(Params params);
}

/// Use case with no parameters
abstract class UseCaseNoParams<T> {
  Future<Result<T>> call();
}

/// No parameters class
class NoParams {
  const NoParams();
}

