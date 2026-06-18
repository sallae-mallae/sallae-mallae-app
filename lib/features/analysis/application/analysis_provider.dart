import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sallae_mallae_app/core/errors/app_exception.dart';
import 'package:sallae_mallae_app/core/network/dio_provider.dart';

import '../../vision/domain/entities/vision_context.dart';
import '../data/datasources/analyze_remote_datasource.dart';
import '../data/mappers/vision_context_input_mapper.dart';
import '../data/models/analyze_request.dart';
import '../data/repositories/analyze_repository_impl.dart';
import '../data/services/analysis_image_preparer.dart';
import '../domain/entities/analysis_failure.dart';
import '../domain/entities/analysis_result.dart';
import '../domain/repositories/analyze_repository.dart';
import '../domain/usecases/analyze_product_usecase.dart';
import 'analysis_state.dart';

final analysisImagePreparerProvider = Provider<AnalysisImagePreparer>((ref) {
  return const AnalysisImagePreparer();
});

final visionContextInputMapperProvider = Provider<VisionContextInputMapper>((
  ref,
) {
  return const VisionContextInputMapper();
});

final analyzeRemoteDatasourceProvider = Provider<AnalyzeRemoteDatasource>((
  ref,
) {
  return DioAnalyzeRemoteDatasource(ref.read(dioProvider));
});

final analyzeRepositoryProvider = Provider<AnalyzeRepository>((ref) {
  return AnalyzeRepositoryImpl(ref.read(analyzeRemoteDatasourceProvider));
});

final analyzeProductUseCaseProvider = Provider<AnalyzeProductUseCase>((ref) {
  return AnalyzeProductUseCase(ref.read(analyzeRepositoryProvider));
});

final analysisProvider = NotifierProvider<AnalysisNotifier, AnalysisState>(
  AnalysisNotifier.new,
);

class AnalysisNotifier extends Notifier<AnalysisState> {
  AnalysisImagePreparer get _imagePreparer =>
      ref.read(analysisImagePreparerProvider);

  VisionContextInputMapper get _contextMapper =>
      ref.read(visionContextInputMapperProvider);

  AnalyzeProductUseCase get _analyzeProductUseCase =>
      ref.read(analyzeProductUseCaseProvider);

  @override
  AnalysisState build() {
    return const AnalysisState.idle();
  }

  Future<void> analyzeProduct({
    required String question,
    required VisionContext visionContext,
    XFile? imageFile,
    int? sessionId,
    int? userId,
    bool proMode = false,
  }) async {
    final normalizedQuestion = question.trim();

    if (normalizedQuestion.isEmpty) {
      state = const AnalysisState(
        status: AnalysisStatus.failure,
        failure: AnalysisFailure(
          message: '질문을 입력해주세요.',
          type: AppExceptionType.badRequest,
        ),
      );
      return;
    }

    state = const AnalysisState(status: AnalysisStatus.loading);

    try {
      // A null image tells the server to reuse the session's last photo.
      final imageBase64 = imageFile == null
          ? null
          : await _imagePreparer.prepareBase64(imageFile);
      final request = AnalyzeRequest(
        sessionId: sessionId,
        userId: userId,
        question: normalizedQuestion,
        imageBase64: imageBase64,
        proMode: proMode,
        context: _contextMapper.map(visionContext),
      );
      final response = await _analyzeProductUseCase(request: request);

      state = AnalysisState(
        status: AnalysisStatus.success,
        result: AnalysisResult.fromResponse(response),
      );
    } on AppException catch (error) {
      state = AnalysisState(
        status: AnalysisStatus.failure,
        failure: AnalysisFailure.fromException(error),
      );
    } catch (_) {
      state = const AnalysisState(
        status: AnalysisStatus.failure,
        failure: AnalysisFailure(
          message: '상품 분석에 실패했습니다. 잠시 후 다시 시도해주세요.',
          type: AppExceptionType.unknown,
        ),
      );
    }
  }

  void failWithMessage(String message) {
    state = AnalysisState(
      status: AnalysisStatus.failure,
      failure: AnalysisFailure(
        message: message,
        type: AppExceptionType.unknown,
      ),
    );
  }

  void reset() {
    state = const AnalysisState.idle();
  }
}
