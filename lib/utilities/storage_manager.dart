import 'package:shared_preferences/shared_preferences.dart';

class PreferencesManager {
  static final PreferencesManager _instance = PreferencesManager._internal();
  SharedPreferences? _prefs;

  PreferencesManager._internal();

  static PreferencesManager get instance => _instance;

  // Initialize the SharedPreferences instance
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Save themes
  Future<void> saveThemes(List<String> themes) async {
    await _prefs?.setStringList('selectedThemes', themes);
  }

  // Load themes
  List<String> loadThemes() {
    return _prefs?.getStringList('selectedThemes') ?? [];
  }

  // Save language
  Future<void> saveLanguage(String lang) async {
    await _prefs?.setString('language', lang);
  }

  // Load language
  String loadLanguage() {
    return _prefs?.getString('language') ?? "";
  }
}
