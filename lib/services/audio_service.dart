import 'package:flutter_tts/flutter_tts.dart';

class AudioService {
  final FlutterTts _flutterTts = FlutterTts();

  Future<void> playPronunciation(String text, String language) async {
    final locale = _localeForLanguage(language);
    await _flutterTts.setLanguage(locale);
    await _flutterTts.speak(text);
  }

  String _localeForLanguage(String language) {
    switch (language.toLowerCase()) {
      case 'english':
        return 'en-US';
      case 'bemba':
      case 'nyanja':
      case 'tonga':
        // Placeholder: use the default engine until real recorded audio is available.
        return 'en-US';
      default:
        return 'en-US';
    }
  }
}
