import '../../data/models/analyze_request.dart';
import '../../data/models/analyze_response.dart';
import '../repositories/analyze_repository.dart';

class AnalyzeProductUseCase {
  const AnalyzeProductUseCase(this._repository);

  final AnalyzeRepository _repository;

  Future<AnalyzeResponse> call({required AnalyzeRequest request}) {
    return _repository.analyze(request: request);
  }
}
