import 'dart:async';

import 'package:google_mlkit_genai_speech_recognition/google_mlkit_genai_speech_recognition.dart';

/// Google ML Kit GenAI Speech Recognition wrapper.
///
/// MVP use case:
/// user speaks pantry items -> transcript -> app parses comma-like food terms.
///
/// Note: the current plugin exposes real-time streaming recognition. Platform
/// availability must be checked at runtime before showing the voice button.
class VoiceInputService {
  VoiceInputService({SpeechRecognizer? speechRecognizer})
      : _speechRecognizer = speechRecognizer ?? SpeechRecognizer();

  final SpeechRecognizer _speechRecognizer;

  Future<bool> isAvailable() async {
    final status = await _speechRecognizer.checkStatus();
    return status == FeatureStatus.available;
  }

  Stream<String> startListening() {
    return _speechRecognizer.startRecognition();
  }

  Future<void> stopListening() async {
    await _speechRecognizer.stopRecognition();
  }

  Future<void> close() async {
    await _speechRecognizer.close();
  }
}
