import 'package:flutter_tts/flutter_tts.dart';

class VoiceOutputService {
  VoiceOutputService({FlutterTts? flutterTts})
    : _flutterTts = flutterTts ?? FlutterTts();

  final FlutterTts _flutterTts;

  Future<void> initialize({
    required VoidCallback onStart,
    required VoidCallback onComplete,
    required VoidCallback onCancel,
    required TtsErrorListener onError,
  }) async {
    _flutterTts.setStartHandler(onStart);
    _flutterTts.setCompletionHandler(onComplete);
    _flutterTts.setCancelHandler(onCancel);
    _flutterTts.setErrorHandler(onError);

    await _flutterTts.setLanguage('ko-KR');
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.awaitSpeakCompletion(true);
  }

  Future<void> speak(String text) async {
    await _flutterTts.stop();
    await _flutterTts.speak(text);
  }

  Future<void> stop() async {
    await _flutterTts.stop();
  }
}

typedef VoidCallback = void Function();

typedef TtsErrorListener = void Function(String message);
