import 'package:sallae_mallae_app/core/errors/app_exception.dart';

class AnalysisFailure {
  const AnalysisFailure({
    required this.message,
    required this.type,
    this.statusCode,
  });

  final String message;
  final AppExceptionType type;
  final int? statusCode;

  factory AnalysisFailure.fromException(AppException exception) {
    return AnalysisFailure(
      message: exception.message,
      type: exception.type,
      statusCode: exception.statusCode,
    );
  }
}
