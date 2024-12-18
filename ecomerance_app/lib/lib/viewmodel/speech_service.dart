import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechService {
  stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;

  Future<void> initSpeech() async {
    _isListening = await _speech.initialize();
  }

  bool get isListening => _isListening;

  Future<void> startListening(Function(String) onResult) async {
    if (_isListening) {
      _speech.listen(onResult: (result) {
        onResult(result.recognizedWords);
      });
    }
  }

  void stopListening() {
    if (_isListening) {
      _speech.stop();
    }
  }
}
