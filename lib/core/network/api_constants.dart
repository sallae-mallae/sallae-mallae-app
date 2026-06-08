import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract final class ApiConstants {
  static String get baseUrl => dotenv.env['API_BASE_URL'] ?? '';

  static const connectTimeout = Duration(seconds: 10);
  static const receiveTimeout = Duration(seconds: 10);
  static const sendTimeout = Duration(seconds: 10);
}
