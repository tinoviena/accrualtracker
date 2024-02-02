import 'dart:io';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:path_provider/path_provider.dart';
import 'package:accrualtracker/data_provider.dart';

class FileDataProvider implements DataProvider {
  static Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    return File('$path/records.csv');
  }

  @override
  Future<String> postData(Map<String, dynamic> jsonData) async {
    // Convert the JSON object to a string

    // Convert the sorted JSON object to a string
    String jsonString = jsonEncode(jsonData);

    // Generate the SHA-1 hash of the string
    String sha1Hash = sha1.convert(utf8.encode(jsonString)).toString();
    final file = await _getFile();
    final exists = await file.exists();
    final csv =
        "$sha1Hash,${jsonData["day"]},${jsonData["description"]},${jsonData["amountEuro"]},${jsonData["account"]}";
    await file.writeAsString('$csv\n',
        mode: exists ? FileMode.append : FileMode.write);
    return Future.value("Hello");
  }

  @override
  Future<String> getData() {
    return Future.value("hello");
  }

  static Future<List<Map<String, dynamic>>> readAllRecords() async {
    final file = await _getFile();
    final exists = await file.exists();
    if (!exists) {
      return [];
    }
    final csv = await file.readAsString();
    final lines = csv.split('\n').where((line) => line.isNotEmpty);
    final records = lines.map((line) {
      final parts = line.split(',');
      return Map.fromIterables(['key', 'value'], parts);
    });
    return records.toList();
  }

  @override
  // TODO: implement apiUrl
  String get apiUrl => throw UnimplementedError();

  @override
  Future<double> getTotal(String account) {
    return Future.value(100.2);
  }

  @override
  // TODO: implement secret
  String get secret => throw UnimplementedError();
}
