import 'package:speech_to_text/speech_to_text.dart';

class VoiceRecorderService {
  final SpeechToText _speechToText = SpeechToText();
  bool _isAvailable = false;

  Future<bool> initialize({Function(String)? onStatus}) async {
    _isAvailable = await _speechToText.initialize(
      onError: (error) => print('STT Error: $error'),
      onStatus: (status) {
        print('STT Status: $status');
        if (onStatus != null) onStatus(status);
      },
    );
    return _isAvailable;
  }

  Future<void> startListening({
    required Function(String, bool) onResult,
    required Function(double) onSoundLevelChanged,
    Function(String)? onStatus,
  }) async {
    // If status callback is provided, we need to re-initialize to attach it if not already done,
    // or just rely on the one from initialize. Most reliable is to re-initialize or have a dedicated listener.
    if (!_isAvailable || onStatus != null) {
      bool initialized = await initialize(onStatus: onStatus);
      if (!initialized) return;
    }

    await _speechToText.listen(
      onResult: (result) {
        onResult(result.recognizedWords, result.finalResult);
      },
      onSoundLevelChange: onSoundLevelChanged,
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 5),
      partialResults: true,
      localeId: 'ko_KR',
      cancelOnError: true,
      listenMode: ListenMode.dictation,
    );
  }

  Future<void> stopListening() async {
    await _speechToText.stop();
  }

  bool get isListening => _speechToText.isListening;
  bool get isAvailable => _isAvailable;
}
