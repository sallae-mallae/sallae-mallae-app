import 'context_input.dart';

class AnalyzeRequest {
  const AnalyzeRequest({
    required this.imageBase64,
    required this.question,
    required this.context,
    required this.saveImage,
  });

  final String imageBase64;
  final String question;
  final ContextInput context;
  final bool saveImage;

  Map<String, dynamic> toJson() {
    return {
      'image_base64': imageBase64,
      'question': question,
      'context': context.toJson(),
      'save_image': saveImage,
    };
  }
}
