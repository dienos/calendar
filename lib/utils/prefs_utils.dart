import 'package:shared_preferences/shared_preferences.dart';

class PrefsUtils {
  static late final SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static const String _keyTheme = 'theme_name';

  static String? getThemeName() {
    return _prefs.getString(_keyTheme);
  }

  static Future<void> setThemeName(String themeName) async {
    await _prefs.setString(_keyTheme, themeName);
  }

  static String? getString(String key) => _prefs.getString(key);
  static Future<void> setString(String key, String value) => _prefs.setString(key, value);

  static int? getInt(String key) => _prefs.getInt(key);
  static Future<void> setInt(String key, int value) => _prefs.setInt(key, value);

  static bool? getBool(String key) => _prefs.getBool(key);
  static Future<void> setBool(String key, bool value) => _prefs.setBool(key, value);

  static Future<void> remove(String key) => _prefs.remove(key);
}
