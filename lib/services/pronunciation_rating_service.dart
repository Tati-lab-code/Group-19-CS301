import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

class PronunciationRatingService {
  static const String _boxName = 'pronunciation_ratings';
  static Box<dynamic>? _box;

  static Future<Box<dynamic>> _getBox() async {
    if (_box?.isOpen == true) return _box!;

    final documentsDirectory = await getApplicationDocumentsDirectory();
    Hive.init(documentsDirectory.path);
    _box = await Hive.openBox<dynamic>(_boxName);
    return _box!;
  }

  static Future<void> saveRating({
    required String username,
    required String phraseId,
    required String language,
    required int rating,
  }) async {
    if (username.isEmpty) return;

    final box = await _getBox();
    final key = '${username}_${phraseId}_$language';
    await box.put(key, {
      'rating': rating,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  static Future<Map<dynamic, dynamic>> getAllRatings() async {
    final box = await _getBox();
    return Map<dynamic, dynamic>.fromEntries(
      box.toMap().entries.map((entry) => MapEntry(entry.key, entry.value)),
    );
  }
}
