import 'context_input.dart';

/// Body for `POST /api/v1/chat/analyze`.
///
/// [sessionId] null starts a new chat session on the server. [imageBase64] null
/// reuses the session's last photo. [proMode] sends the image straight to
/// Gemini for a more capable verdict.
class AnalyzeRequest {
  const AnalyzeRequest({
    required this.question,
    required this.context,
    required this.proMode,
    this.sessionId,
    this.userId,
    this.imageBase64,
  });

  final int? sessionId;
  final int? userId;
  final String question;
  final String? imageBase64;
  final bool proMode;
  final ContextInput context;

  Map<String, dynamic> toJson() {
    return {
      if (sessionId != null) 'session_id': sessionId,
      if (userId != null) 'user_id': userId,
      'question': question,
      if (imageBase64 != null) 'image_base64': imageBase64,
      'pro_mode': proMode,
      'context': context.toJson(),
    };
  }
}
