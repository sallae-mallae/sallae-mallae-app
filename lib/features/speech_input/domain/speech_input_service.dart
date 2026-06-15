import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SpeechInputService {
  SpeechInputService({SpeechToText? speechToText})
    : _speechToText = speechToText ?? SpeechToText();

  final SpeechToText _speechToText;

  bool get isListening => _speechToText.isListening;

  Future<bool> initialize({
    required SpeechStatusListener onStatus,
    required SpeechErrorListener onError,
  }) {
    return _speechToText.initialize(
      onStatus: onStatus,
      onError: onError,
      options: [SpeechToText.androidNoBluetooth],
    );
  }

  Future<void> startListening({required SpeechResultListener onResult}) {
    return _speechToText.listen(
      onResult: onResult,
      listenOptions: SpeechListenOptions(
        partialResults: true,
        cancelOnError: true,
        listenMode: ListenMode.dictation,
        listenFor: const Duration(seconds: 20),
        pauseFor: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> stopListening() {
    return _speechToText.stop();
  }

  Future<void> cancelListening() {
    return _speechToText.cancel();
  }
}

typedef SpeechStatusListener = void Function(String status);

typedef SpeechErrorListener = void Function(SpeechRecognitionError error);

typedef SpeechResultListener = void Function(SpeechRecognitionResult result);
