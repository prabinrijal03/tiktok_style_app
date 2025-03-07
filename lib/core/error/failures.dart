import 'package:freezed_annotation/freezed_annotation.dart';
part 'failures.freezed.dart';
@freezed
class Failure with _$Failure{
  const factory Failure.serverError() = ServerError;
  const factory Failure.networkError() = NetworkError;
  const factory Failure.authError(String message)= AuthError;
  const factory Failure.unexpectedError() = UnexpectedError;
}