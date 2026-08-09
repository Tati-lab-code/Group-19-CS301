import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

class FavoritesService {
  static const String _boxName = 'favorites';
  static late final Box<bool> _box;

  static Future<void> init() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    Hive.init(documentsDirectory.path);
    _box = await Hive.openBox<bool>(_boxName);
  }

  static Future<void> addFavorite(String phraseId) async {
    await _box.put(phraseId, true);
  }

  static Future<void> removeFavorite(String phraseId) async {
    await _box.delete(phraseId);
  }

  static bool isFavorite(String phraseId) {
    return _box.get(phraseId, defaultValue: false) ?? false;
  }

  static List<String> getFavoriteIds() {
    return _box.keys.cast<String>().toList();
  }
}
