import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

import '../models/user_profile.dart';

class AuthService {
  static const String _usersBoxName = 'users';
  static const String _authBoxName = 'auth';

  static late final Box _usersBox;
  static late final Box _authBox;

  static Future<void> init() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    Hive.init(documentsDirectory.path);
    _usersBox = await Hive.openBox(_usersBoxName);
    _authBox = await Hive.openBox(_authBoxName);
  }

  static Future<bool> signUp({required String username, required String password, required String email}) async {
    if (_usersBox.containsKey(username)) {
      return false;
    }
    final profile = UserProfile(username: username, password: password, email: email);
    await _usersBox.put(username, profile.toMap());
    return true;
  }

  static Future<bool> signIn({required String username, required String password}) async {
    final stored = _usersBox.get(username);
    if (stored == null) return false;
    try {
      final map = Map<dynamic, dynamic>.from(stored as Map);
      final profile = UserProfile.fromMap(map);
      return profile.password == password;
    } catch (_) {
      return false;
    }
  }

  static Future<void> setCurrentUser(String username) async {
    await _authBox.put('currentUser', username);
  }

  static String? getCurrentUser() {
    final value = _authBox.get('currentUser');
    if (value is String) return value;
    return null;
  }

  static Future<void> logOut() async {
    await _authBox.delete('currentUser');
  }

  static UserProfile? getUserProfile(String username) {
    final stored = _usersBox.get(username);
    if (stored == null) return null;
    try {
      final map = Map<dynamic, dynamic>.from(stored as Map);
      return UserProfile.fromMap(map);
    } catch (_) {
      return null;
    }
  }
}
