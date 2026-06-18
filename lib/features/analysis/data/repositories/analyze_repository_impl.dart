import '../../domain/repositories/analyze_repository.dart';
import '../datasources/analyze_remote_datasource.dart';
import '../models/analyze_request.dart';
import '../models/analyze_response.dart';

class AnalyzeRepositoryImpl implements AnalyzeRepository {
  const AnalyzeRepositoryImpl(this._remoteDatasource);

  final AnalyzeRemoteDatasource _remoteDatasource;

  @override
  Future<AnalyzeResponse> analyze({required AnalyzeRequest request}) {
    return _remoteDatasource.analyze(request: request);
  }
}
