import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

// Create a class to manage local storage
class LocalStorage {
  static Future<File> _getLocalFile(String filename) async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$filename');
  }

  static Future<void> saveData(String key, String value) async {
    final file = await _getLocalFile('app_settings.json');

    // Read existing data
    Map<String, dynamic> data = {};
    if (await file.exists()) {
      String contents = await file.readAsString();
      data = json.decode(contents);
    }

    // Update data
    data[key] = value;

    // Write back to file
    await file.writeAsString(json.encode(data));
  }

  static Future<String?> readData(String key) async {
    final file = await _getLocalFile('app_settings.json');

    if (await file.exists()) {
      String contents = await file.readAsString();
      Map<String, dynamic> data = json.decode(contents);
      return data[key];
    }

    return null;
  }
}

Future<Map<String, String?>> loadSavedCredentials() async {
  // try {
  final savedApiKey = await LocalStorage.readData('openai_api_key');
  final savedLanguage = await LocalStorage.readData('selected_language');

  return {"api": savedApiKey, "lang": savedLanguage};
  // } catch (e) {
  //   if (kDebugMode) {
  //     print('Error loading credentials: $e');
  //   }
  // }
}

Future<void> saveCredentials(api, lang) async {
  // try {
  await LocalStorage.saveData('openai_api_key', api);
  await LocalStorage.saveData('selected_language', lang);

  //   setState(() {
  //     openaiApiKey = apiKeyController.text.trim();
  //   });
  // } catch (e) {
  //   if (kDebugMode) {
  //     print('Error saving credentials: $e');
  //   }
  // }
}
