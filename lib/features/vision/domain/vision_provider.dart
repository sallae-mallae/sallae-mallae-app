import 'dart:async';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/parsers/ocr_candidate_parser.dart';
import '../data/services/basic_open_cv_quality_service.dart';
import '../data/services/camera_input_image_converter.dart';
import '../data/services/mlkit_object_detection_service.dart';
import '../data/services/mlkit_text_recognition_service.dart';
import 'entities/crop_candidate.dart';
import 'entities/detected_product.dart';
import 'entities/frame_quality.dart';
import 'entities/product_bounding_box.dart';
import 'entities/vision_context.dart';
import 'services/object_detection_service.dart';
import 'services/open_cv_quality_service.dart';
import 'services/text_recognition_service.dart';

final visionProvider = NotifierProvider<VisionNotifier, VisionContext>(
  VisionNotifier.new,
);

class VisionNotifier extends Notifier<VisionContext> {
  final CameraInputImageConverter _imageConverter =
      const CameraInputImageConverter();
  final OcrCandidateParser _ocrCandidateParser = const OcrCandidateParser();
  ObjectDetectionService? _objectDetectionService;
  TextRecognitionService? _textRecognitionService;
  OpenCvQualityService? _qualityService;

  bool _isProcessing = false;

  bool get isProcessing => _isProcessing;

  @override
  VisionContext build() {
    ref.onDispose(() {
      unawaited(_releaseResources(resetState: false));
    });

    return const VisionContext.empty();
  }

  Future<void> analyzeCameraImage({
    required CameraImage image,
    required CameraDescription camera,
  }) async {
    if (_isProcessing) {
      return;
    }

    final inputImage = _imageConverter.convert(image: image, camera: camera);

    if (inputImage == null) {
      return;
    }

    _isProcessing = true;

    try {
      final objectDetectionService = _objectDetectionService ??=
          MlKitObjectDetectionService();
      final textRecognitionService = _textRecognitionService ??=
          MlKitTextRecognitionService();
      final qualityService = _qualityService ??=
          const BasicOpenCvQualityService();
      final imageSize = Size(image.width.toDouble(), image.height.toDouble());
      final detectedProducts = await objectDetectionService.detectProducts(
        image: inputImage,
        imageSize: imageSize,
      );
      final textRecognitionResult = await textRecognitionService.recognizeText(
        image: inputImage,
        imageSize: imageSize,
      );
      final frameQuality = await qualityService.inspectFrame(image);
      final parsedOcrCandidates = _ocrCandidateParser.parse(
        textRecognitionResult.candidates,
      );

      state = VisionContext(
        analyzedAt: DateTime.now(),
        frameWidth: imageSize.width,
        frameHeight: imageSize.height,
        detectedProducts: detectedProducts,
        ocrCandidates: parsedOcrCandidates,
        frameQuality: frameQuality,
        cropCandidates: _buildCropCandidates(detectedProducts, imageSize),
      );
    } catch (_) {
      state = state.copyWith(analyzedAt: DateTime.now());
    } finally {
      _isProcessing = false;
    }
  }

  Future<void> disposeVision() async {
    await _releaseResources(resetState: true);
  }

  Future<void> _releaseResources({required bool resetState}) async {
    _isProcessing = false;
    final objectDetectionService = _objectDetectionService;
    final textRecognitionService = _textRecognitionService;
    final qualityService = _qualityService;
    _objectDetectionService = null;
    _textRecognitionService = null;
    _qualityService = null;

    await Future.wait([
      if (objectDetectionService != null) objectDetectionService.dispose(),
      if (textRecognitionService != null) textRecognitionService.dispose(),
      if (qualityService != null) qualityService.dispose(),
    ]);

    if (resetState) {
      state = const VisionContext.empty();
    }
  }

  List<CropCandidate> _buildCropCandidates(
    List<DetectedProduct> detectedProducts,
    Size imageSize,
  ) {
    final candidates = <CropCandidate>[];

    for (var index = 0; index < detectedProducts.length; index++) {
      final product = detectedProducts[index];
      final sourceBox = product.boundingBox;
      final cropBox = _expandToSquare(sourceBox, imageSize);

      candidates.add(
        CropCandidate(
          sourceBox: sourceBox,
          cropBox: cropBox,
          score: product.confidence,
          priority: index,
        ),
      );
    }

    candidates.sort((a, b) {
      final scoreCompare = b.score.compareTo(a.score);

      if (scoreCompare != 0) {
        return scoreCompare;
      }

      return a.priority.compareTo(b.priority);
    });

    return candidates;
  }

  ProductBoundingBox _expandToSquare(
    ProductBoundingBox sourceBox,
    Size imageSize,
  ) {
    final side = sourceBox.width > sourceBox.height
        ? sourceBox.width
        : sourceBox.height;
    final paddedSide = side * 1.2;
    final constrainedSide = paddedSide
        .clamp(
          1,
          imageSize.width < imageSize.height
              ? imageSize.width
              : imageSize.height,
        )
        .toDouble();
    final centerX = sourceBox.centerX;
    final centerY = sourceBox.centerY;
    final left = (centerX - paddedSide / 2).clamp(
      0,
      imageSize.width - constrainedSide,
    );
    final top = (centerY - paddedSide / 2).clamp(
      0,
      imageSize.height - constrainedSide,
    );

    return ProductBoundingBox(
      left: left.toDouble(),
      top: top.toDouble(),
      width: constrainedSide,
      height: constrainedSide,
      imageWidth: imageSize.width,
      imageHeight: imageSize.height,
    );
  }
}
