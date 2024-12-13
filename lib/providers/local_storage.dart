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

