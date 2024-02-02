import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:accrualtracker/data_provider.dart';

class HttpDataProvider implements DataProvider {
  @override
  final String secret = "c0fa0758-b954-11ee-9a88-3baa8ec87383";
//  final String apiUrl = 'http://localhost:7071/api/mk_acc_http_trigger';
  @override
  final String apiUrl =
      'https://mk-acc-http-trigger.azurewebsites.net/api/mk_acc_http_trigger';

  @override
  Future<String> getData() async {
    final response = await http.get(Uri.parse(apiUrl));
    final Map<String, dynamic> responseBody = json.decode(response.body);
    return responseBody['origin'];
  }

  @override
  Future<String> postData(Map<String, dynamic> jsonData) async {
    var payload = <String, dynamic>{};
    payload["secret"] = secret;
    payload["records"] = [];
    payload["records"].add(jsonData);
    print("Post data: ${json.encode(payload)}");
    final http.Response response = await http.post(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'x-functions-key':
            '9tENKgiLoUmZ-cgpGzaRTj5uHq05w_uFwSgNU2eb9sDGAzFuE_UvPA==',
      },
      body: json.encode(payload),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to post data: ${response.statusCode}');
    }
    final Map<String, dynamic> responseBody = json.decode(response.body);
    return responseBody.toString();
  }

  @override
  Future<double> getTotal(String account) async {
    var payload = <String, dynamic>{
      "secret": secret,
      "account": account,
    };

    final http.Response response = await http.post(
      Uri.parse("${apiUrl}_read"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'x-functions-key':
            '9tENKgiLoUmZ-cgpGzaRTj5uHq05w_uFwSgNU2eb9sDGAzFuE_UvPA==',
      },
      body: json.encode(payload),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to post data: ${response.statusCode}');
    }
    final Map<String, dynamic> responseBody = json.decode(response.body);
    var total = 0.0;
    if (responseBody.containsKey("total")) {
      total = responseBody['total'];
    }
    return total;
  }
}
