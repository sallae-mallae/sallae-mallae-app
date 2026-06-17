import '../../data/models/analyze_request.dart';
import '../../data/models/analyze_response.dart';

abstract interface class AnalyzeRepository {
  Future<AnalyzeResponse> analyze({
    required AnalyzeRequest request,
    String? aiModel,
  });
}
