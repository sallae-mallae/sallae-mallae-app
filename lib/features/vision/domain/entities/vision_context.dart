import 'crop_candidate.dart';
import 'detected_product.dart';
import 'frame_quality.dart';
import 'ocr_candidate.dart';

class VisionContext {
  const VisionContext({
    required this.analyzedAt,
    required this.frameWidth,
    required this.frameHeight,
    required this.detectedProducts,
    required this.ocrCandidates,
    required this.frameQuality,
    required this.cropCandidates,
  });

  const VisionContext.empty()
    : analyzedAt = null,
      frameWidth = 0,
      frameHeight = 0,
      detectedProducts = const [],
      ocrCandidates = const [],
      frameQuality = const FrameQuality.unknown(),
      cropCandidates = const [];

  final DateTime? analyzedAt;
  final double frameWidth;
  final double frameHeight;
  final List<DetectedProduct> detectedProducts;
  final List<OcrCandidate> ocrCandidates;
  final FrameQuality frameQuality;
  final List<CropCandidate> cropCandidates;

  bool get hasFrameSize => frameWidth > 0 && frameHeight > 0;

  bool get hasDetectedProduct => detectedProducts.isNotEmpty;

  bool get hasOcrCandidate => ocrCandidates.isNotEmpty;

  DetectedProduct? get primaryProduct =>
      detectedProducts.isEmpty ? null : detectedProducts.first;

  CropCandidate? get primaryCropCandidate =>
      cropCandidates.isEmpty ? null : cropCandidates.first;

  bool get isReadyForAiRequest =>
      hasFrameSize &&
      frameQuality.canSuggestCapture &&
      (hasDetectedProduct || hasOcrCandidate);

  VisionContext copyWith({
    DateTime? analyzedAt,
    double? frameWidth,
    double? frameHeight,
    List<DetectedProduct>? detectedProducts,
    List<OcrCandidate>? ocrCandidates,
    FrameQuality? frameQuality,
    List<CropCandidate>? cropCandidates,
    bool clearAnalyzedAt = false,
  }) {
    return VisionContext(
      analyzedAt: clearAnalyzedAt ? null : analyzedAt ?? this.analyzedAt,
      frameWidth: frameWidth ?? this.frameWidth,
      frameHeight: frameHeight ?? this.frameHeight,
      detectedProducts: detectedProducts ?? this.detectedProducts,
      ocrCandidates: ocrCandidates ?? this.ocrCandidates,
      frameQuality: frameQuality ?? this.frameQuality,
      cropCandidates: cropCandidates ?? this.cropCandidates,
    );
  }
}
