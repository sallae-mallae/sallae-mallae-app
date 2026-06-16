import 'dart:ui';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../entities/ocr_candidate.dart';

class TextRecognitionResult {
  const TextRecognitionResult({
    required this.rawText,
    required this.candidates,
  });

  const TextRecognitionResult.empty() : rawText = '', candidates = const [];

  final String rawText;
  final List<OcrCandidate> candidates;

  bool get hasText => rawText.trim().isNotEmpty;
}

abstract class TextRecognitionService {
  Future<TextRecognitionResult> recognizeText({
    required InputImage image,
    required Size imageSize,
  });

  Future<void> dispose();
}
