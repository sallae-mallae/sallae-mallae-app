import '../domain/entities/analysis_failure.dart';
import '../domain/entities/analysis_result.dart';

enum AnalysisStatus { idle, loading, success, failure }

class AnalysisState {
  const AnalysisState({required this.status, this.result, this.failure});

  const AnalysisState.idle()
    : status = AnalysisStatus.idle,
      result = null,
      failure = null;

  final AnalysisStatus status;
  final AnalysisResult? result;
  final AnalysisFailure? failure;

  bool get isLoading => status == AnalysisStatus.loading;

  bool get hasResult => result != null;

  String? get errorMessage => failure?.message;

  AnalysisState copyWith({
    AnalysisStatus? status,
    AnalysisResult? result,
    AnalysisFailure? failure,
    bool clearResult = false,
    bool clearFailure = false,
  }) {
    return AnalysisState(
      status: status ?? this.status,
      result: clearResult ? null : result ?? this.result,
      failure: clearFailure ? null : failure ?? this.failure,
    );
  }
}
