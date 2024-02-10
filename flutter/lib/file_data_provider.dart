import 'dart:io';
import 'dart:convert';
import 'package:share/share.dart';
import 'package:crypto/crypto.dart';
import 'package:path_provider/path_provider.dart';
import 'package:accrualtracker/data_provider.dart';

class FileDataProvider implements DataProvider {
  static Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    return File('$path/accruals.csv');
  }

  @override
  Future<String> postData(Map<String, dynamic> jsonData) async {
    // Convert the JSON object to a string

    // Convert the sorted JSON object to a string
    String jsonString = jsonEncode(jsonData);

    // Generate the SHA-1 hash of the string
    String sha1Hash = sha1.convert(utf8.encode(jsonString)).toString();
    final file = await _getFile();
    final fileExists = await file.exists();

    final csv =
        "$sha1Hash,${jsonData["day"]},${jsonData["description"]},${jsonData["amountEuro"]},${jsonData["account"]}";
    await file.writeAsString('$csv\n',
        mode: fileExists ? FileMode.append : FileMode.write);
    return sha1Hash;
  }

  Future<int> countNomberOfLines(File file) async {
    int lineCount = 0;
    final fileExists = await file.exists();
    if (fileExists) {
      final content = await file.readAsString();
      lineCount = content.split('\n').length;
    } else {
      print('File does not exist');
    }
    return lineCount;
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
      return Map.fromIterables(
          ['id', 'day', 'description', 'amountEuro', 'account'], parts);
    });
    return records.toList();
  }

  @override
  String get apiUrl => throw UnimplementedError();

  @override
  Future<double> getTotal(String account) async {
    var recs = await readAllRecords();

    double total = _calulateTotalForAccount(recs, account);

    return total;
  }

  double _calulateTotalForAccount(
      List<Map<String, dynamic>> recs, String account) {
    var total = recs
        .where(
            (recs) => DateTime.parse(recs["day"]).month == DateTime.now().month)
        .where((recs) => recs["account"] == account)
        .map((rec) => double.parse(rec["amountEuro"]))
        .reduce((a, b) => a + b);
    return total;
  }

  @override
  // TODO: implement secret
  String get secret => throw UnimplementedError();

  @override
  Future<Map<String, double>> getAllTotals() async {
    var recs = await readAllRecords();
    var accounts = recs.map((rec) => rec["account"]).toSet().toList();
    var totals = <String, double>{};

    var grandTotal = 0.0;
    for (var acc in accounts) {
      var accountTotal = _calulateTotalForAccount(recs, acc);
      grandTotal += accountTotal;
      totals[acc] = accountTotal;
    }
    totals["TOTAL"] = grandTotal;
    return totals;
  }
}
