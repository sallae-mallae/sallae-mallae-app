import '../../domain/entities/detected_product.dart';
import '../../domain/entities/frame_quality.dart';
import '../../domain/entities/ocr_candidate.dart';
import '../../domain/entities/vision_context.dart';

class VisionOverlayState {
  const VisionOverlayState({
    required this.products,
    required this.ocrCandidates,
    required this.frameWidth,
    required this.frameHeight,
    required this.guideText,
    required this.canSuggestCapture,
  });

  factory VisionOverlayState.fromContext(VisionContext context) {
    return VisionOverlayState(
      products: context.detectedProducts.take(3).toList(growable: false),
      ocrCandidates: context.ocrCandidates
          .where((candidate) => candidate.type != OcrCandidateType.unknown)
          .take(4)
          .toList(growable: false),
      frameWidth: context.frameWidth,
      frameHeight: context.frameHeight,
      guideText: _guideText(context),
      canSuggestCapture: context.frameQuality.canSuggestCapture,
    );
  }

  final List<DetectedProduct> products;
  final List<OcrCandidate> ocrCandidates;
  final double frameWidth;
  final double frameHeight;
  final String guideText;
  final bool canSuggestCapture;

  bool get hasFrameSize => frameWidth > 0 && frameHeight > 0;

  bool get hasProducts => products.isNotEmpty;

  bool get hasOcrCandidates => ocrCandidates.isNotEmpty;

  static String _guideText(VisionContext context) {
    final quality = context.frameQuality;

    if (!context.hasFrameSize) {
      return '상품과 가격표를 화면 중앙에 맞춰주세요.';
    }

    if (!quality.isBrightEnough) {
      return '조금 더 밝은 곳에서 촬영해주세요.';
    }

    if (!quality.isSharpEnough) {
      return '초점이 맞도록 잠시 멈춰주세요.';
    }

    if (!quality.isStable) {
      return '흔들림을 줄이고 상품을 중앙에 맞춰주세요.';
    }

    if (!context.hasDetectedProduct) {
      return '상품 전체가 보이도록 조금 뒤로 이동해주세요.';
    }

    if (!context.hasOcrCandidate) {
      return '가격표와 상품명이 보이게 가까이 이동해주세요.';
    }

    return '분석하기 좋은 상태입니다.';
  }
}
