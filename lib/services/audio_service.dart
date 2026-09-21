import 'package:flutter_tts/flutter_tts.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final FlutterTts _flutterTts = FlutterTts();

  Future<void> stop() async {
    await _audioPlayer.stop();
    await _flutterTts.stop();
  }

  Future<void> dispose() async {
    await stop();
    await _audioPlayer.dispose();
  }

  Future<void> playPronunciation(
    String phraseId,
    String text,
    String language,
  ) async {
    // English always uses TTS by design because it is reliable. For other languages,
    // recordings are the intended primary path and TTS is only a safety net when one is missing.
    if (language == 'English') {
      await _speak(text, language);
      return;
    }

    try {
      final extension = 'm4a';
      await _audioPlayer.play(
        AssetSource('audio/${phraseId}_$language.$extension'),
      );
    } catch (_) {
      await _speak(text, language);
    }
  }

  Future<void> _speak(String text, String language) async {
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
