import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

/// Google ML Kit OCR wrapper for recipe screenshots.
///
/// MVP use case:
/// image path -> extracted caption/recipe text -> saved recipe import flow.
class OcrService {
  OcrService({TextRecognizer? textRecognizer})
      : _textRecognizer = textRecognizer ?? TextRecognizer(script: TextRecognitionScript.latin);

  final TextRecognizer _textRecognizer;

  Future<String> extractTextFromImagePath(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final recognizedText = await _textRecognizer.processImage(inputImage);
    return recognizedText.text.trim();
  }

  Future<void> close() async {
    await _textRecognizer.close();
  }
}
