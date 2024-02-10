import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';

class SettingsProvider {
  static Future<File> _getFile() async {
    return File(await _getFileLocation());
  }

  static Future<String> _getFileLocation() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    final settingsLocation = "$path/accrualtrackersettings.json";
    print("settingsprovider: file settingslocation $settingsLocation");
    return settingsLocation;
  }

  static Future<String> getSettingsLocation() async {
    print("settingsprovider: file location ${await _getFileLocation()}");
    return _getFileLocation();
  }

  static Future<bool> save(Map<String, dynamic> jsonData) async {
    // Convert the JSON object to a string
    var current = await load();
    current["totalBudget"] = jsonData["totalBudget"];

    // Convert the sorted JSON object to a string
    String jsonString = jsonEncode(current);

    // Generate the SHA-1 hash of the string
    final file = await _getFile();

    await file.writeAsString('$jsonString\n', mode: FileMode.write);
    return Future.value(true);
  }

  static Future<Map<String, dynamic>> load() async {
    final file = await _getFile();
    final fileContent = await file.readAsString();
    print("settingsprovider: read file $file and found $fileContent");
    final jsonData = json.decode(fileContent);
    return jsonData;
  }
}
