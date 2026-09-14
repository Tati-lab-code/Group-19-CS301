import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

class LanguagePreferenceService {
  static const String _boxName = 'language_preference';
  static const String _languageKey = 'selected_language';
  static const String _defaultLanguage = 'Bemba';

  static late final Box<String> _box;

  static Future<void> init() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    Hive.init(documentsDirectory.path);
    _box = await Hive.openBox<String>(_boxName);
  }

  static Future<void> setLanguage(String language) async {
    await _box.put(_languageKey, language);
  }

  static String getLanguage() {
    final stored = _box.get(_languageKey, defaultValue: _defaultLanguage);
    if (stored is String && stored.isNotEmpty) {
      return stored;
    }
    return _defaultLanguage;
  }
}
