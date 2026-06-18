import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract final class ApiConstants {
  static String get baseUrl => dotenv.env['API_BASE_URL'] ?? '';

  static const connectTimeout = Duration(seconds: 15);
  // The analyze flow runs Florence-2 + RAG + Gemini, so the response can take
  // a while; keep a generous receive window. Send covers the base64 upload.
  static const receiveTimeout = Duration(seconds: 60);
  static const sendTimeout = Duration(seconds: 30);
}
