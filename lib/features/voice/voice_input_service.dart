import 'dart:async';

import 'package:google_mlkit_genai_speech_recognition/google_mlkit_genai_speech_recognition.dart';

class VoiceInputService {
  VoiceInputService({SpeechRecognizer? recognizer})
      : _recognizer = recognizer ?? SpeechRecognizer();

  final SpeechRecognizer _recognizer;

  Future<bool> isAvailable() async {
    final status = await _recognizer.checkStatus();
    return status == FeatureStatus.available;
  }

  Stream<String> startListening() {
    return _recognizer.startRecognition();
  }

  Future<void> stopListening() async {
    await _recognizer.stopRecognition();
  }

  void close() {
    _recognizer.close();
  }
}
