import 'package:flutter_tts/flutter_tts.dart';

import '../data/models/tts_voice.dart';

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

  /// Korean voices available on the device.
  Future<List<TtsVoice>> getKoreanVoices() async {
    final raw = await _flutterTts.getVoices;
    if (raw is! List) {
      return const [];
    }

    return raw
        .whereType<Map>()
        .map(TtsVoice.fromMap)
        .where(
          (voice) =>
              voice.name.isNotEmpty &&
              voice.locale.toLowerCase().startsWith('ko'),
        )
        .toList();
  }

  Future<void> setVoice(TtsVoice voice) async {
    await _flutterTts.setVoice(voice.toTtsMap());
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

typedef TtsErrorListener = void Function(dynamic message);
