import 'package:shared_preferences/shared_preferences.dart';

Future<List<String>> loadThemes() async {
  final prefs = await SharedPreferences.getInstance();
  final savedThemes = prefs.getStringList('selectedThemes') ?? [];
  return savedThemes;
}

Future<void> saveThemes(List<String> themes) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setStringList('selectedThemes', themes);
}

Future<void> saveLanguage(String lang) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('language', lang);
}

Future<String> loadLanguage() async {
  final prefs = await SharedPreferences.getInstance();
  final lang = prefs.getString('language') ?? "";
  return lang;
}