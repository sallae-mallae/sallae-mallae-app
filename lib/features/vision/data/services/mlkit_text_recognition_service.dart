import 'dart:ui';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../../domain/entities/ocr_candidate.dart';
import '../../domain/entities/product_bounding_box.dart';
import '../../domain/services/text_recognition_service.dart';

class MlKitTextRecognitionService implements TextRecognitionService {
  MlKitTextRecognitionService({TextRecognizer? recognizer})
    : _recognizer =
          recognizer ?? TextRecognizer(script: TextRecognitionScript.korean);

  final TextRecognizer _recognizer;

  @override
  Future<TextRecognitionResult> recognizeText({
    required InputImage image,
    required Size imageSize,
  }) async {
    final recognizedText = await _recognizer.processImage(image);
    final candidates = <OcrCandidate>[];

    for (final block in recognizedText.blocks) {
      for (final line in block.lines) {
        final normalizedText = line.text.trim();

        if (normalizedText.isEmpty) {
          continue;
        }

        candidates.add(
          OcrCandidate(
            rawText: line.text,
            normalizedText: normalizedText,
            type: OcrCandidateType.unknown,
            confidence: line.confidence ?? 1.0,
            boundingBox: ProductBoundingBox.fromLTRB(
              left: line.boundingBox.left,
              top: line.boundingBox.top,
              right: line.boundingBox.right,
              bottom: line.boundingBox.bottom,
              imageWidth: imageSize.width,
              imageHeight: imageSize.height,
            ),
          ),
        );
      }
    }

    return TextRecognitionResult(
      rawText: recognizedText.text,
      candidates: candidates
          .where((candidate) => candidate.isValid)
          .toList(growable: false),
    );
  }

  @override
  Future<void> dispose() {
    return _recognizer.close();
  }
}
