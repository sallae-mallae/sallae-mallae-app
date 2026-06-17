import '../../domain/entities/detected_product.dart';
import '../../domain/entities/vision_context.dart';

class VisionOverlayState {
  const VisionOverlayState({
    required this.products,
    required this.frameWidth,
    required this.frameHeight,
    required this.guideText,
    required this.canSuggestCapture,
  });

  factory VisionOverlayState.fromContext(VisionContext context) {
    return VisionOverlayState(
      products: context.detectedProducts.take(3).toList(growable: false),
      frameWidth: context.frameWidth,
      frameHeight: context.frameHeight,
      guideText: _guideText(context),
      canSuggestCapture: context.frameQuality.canSuggestCapture,
    );
  }

  final List<DetectedProduct> products;
  final double frameWidth;
  final double frameHeight;
  final String? guideText;
  final bool canSuggestCapture;

  bool get hasFrameSize => frameWidth > 0 && frameHeight > 0;

  bool get hasProducts => products.isNotEmpty;

  bool get hasGuideText => guideText != null && guideText!.isNotEmpty;

  static String? _guideText(VisionContext context) {
    final quality = context.frameQuality;

    if (!context.hasFrameSize) {
      return '상품을 화면 중앙에 맞춰주세요.';
    }

    if (context.isReadyForAiRequest) {
      return null;
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

    if (!context.hasDetectedProduct && !context.hasOcrCandidate) {
      return '상품을 화면 중앙에 맞춰주세요.';
    }

    if (!context.hasOcrCandidate && context.hasDetectedProduct) {
      return null;
    }

    return null;
  }
}
