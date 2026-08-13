import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

import 'auth_service.dart';

class FavoritesService {
  static const String _boxName = 'favorites';
  static late final Box<bool> _box;

  static Future<void> init() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    Hive.init(documentsDirectory.path);
    _box = await Hive.openBox<bool>(_boxName);
  }

  // Data is scoped per local username since this is a local-only, single-device auth system (no server-side user separation).
  static String _userKeyPrefix() {
    final username = AuthService.getCurrentUser();
    return username == null || username.isEmpty ? '' : '${username}_';
  }

  // Data is scoped per local username since this is a local-only, single-device auth system (no server-side user separation).
  static Future<void> addFavorite(String phraseId) async {
    final prefix = _userKeyPrefix();
    if (prefix.isEmpty) return;
    await _box.put('$prefix$phraseId', true);
  }

  // Data is scoped per local username since this is a local-only, single-device auth system (no server-side user separation).
  static Future<void> removeFavorite(String phraseId) async {
    final prefix = _userKeyPrefix();
    if (prefix.isEmpty) return;
    await _box.delete('$prefix$phraseId');
  }

  // Data is scoped per local username since this is a local-only, single-device auth system (no server-side user separation).
  static bool isFavorite(String phraseId) {
    final prefix = _userKeyPrefix();
    if (prefix.isEmpty) return false;
    return _box.get('$prefix$phraseId', defaultValue: false) ?? false;
  }

  // Data is scoped per local username since this is a local-only, single-device auth system (no server-side user separation).
  static List<String> getFavoriteIds() {
    final prefix = _userKeyPrefix();
    if (prefix.isEmpty) return const [];

    return _box.keys
        .cast<String>()
        .where((key) => key.startsWith(prefix))
        .map((key) => key.substring(prefix.length))
        .toList();
  }
}
