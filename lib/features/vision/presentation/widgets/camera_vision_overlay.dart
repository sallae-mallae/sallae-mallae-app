import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../shared/widgets/camera_overlay_element.dart';
import '../../domain/entities/detected_product.dart';
import '../models/vision_overlay_state.dart';

class CameraVisionOverlay extends StatelessWidget {
  const CameraVisionOverlay({required this.state, super.key});

  final VisionOverlayState state;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _DetectionBoxPainter(
                products: state.products,
                frameWidth: state.frameWidth,
                frameHeight: state.frameHeight,
              ),
            ),
          ),
          if (state.hasGuideText)
            Positioned(
              left: 16,
              right: 16,
              top: AppSpacing.topBarHeight + 28,
              child: _QualityGuide(
                text: state.guideText!,
                canSuggestCapture: state.canSuggestCapture,
              ),
            ),
        ],
      ),
    );
  }
}

class _QualityGuide extends StatelessWidget {
  const _QualityGuide({required this.text, required this.canSuggestCapture});

  final String text;
  final bool canSuggestCapture;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = canSuggestCapture
        ? AppColors.buy.withValues(alpha: 0.92)
        : AppColors.textPrimary.withValues(alpha: 0.78);

    return Align(
      alignment: Alignment.center,
      child: CameraOverlayElement(
        backgroundColor: backgroundColor,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        child: Text(
          text,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.cardWhite,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _DetectionBoxPainter extends CustomPainter {
  const _DetectionBoxPainter({
    required this.products,
    required this.frameWidth,
    required this.frameHeight,
  });

  final List<DetectedProduct> products;
  final double frameWidth;
  final double frameHeight;

  @override
  void paint(Canvas canvas, Size size) {
    if (frameWidth <= 0 || frameHeight <= 0) {
      return;
    }

    final strokePaint = Paint()
      ..color = AppColors.buy
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    final fillPaint = Paint()
      ..color = AppColors.buy.withValues(alpha: 0.12)
      ..style = PaintingStyle.fill;

    for (final product in products) {
      final box = product.boundingBox;
      final rect = Rect.fromLTWH(
        box.normalizedLeft * size.width,
        box.normalizedTop * size.height,
        box.normalizedWidth * size.width,
        box.normalizedHeight * size.height,
      );
      final roundedRect = RRect.fromRectAndRadius(
        rect,
        const Radius.circular(8),
      );

      canvas.drawRRect(roundedRect, fillPaint);
      canvas.drawRRect(roundedRect, strokePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _DetectionBoxPainter oldDelegate) {
    return oldDelegate.products != products ||
        oldDelegate.frameWidth != frameWidth ||
        oldDelegate.frameHeight != frameHeight;
  }
}
