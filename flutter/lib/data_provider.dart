abstract class DataProvider {
  final String secret;
//  final String apiUrl = 'http://localhost:7071/api/mk_acc_http_trigger';
  final String apiUrl;
  DataProvider(this.secret, this.apiUrl);

  Future<String> getData();

  Future<String> postData(Map<String, dynamic> jsonData);
  Future<double> getTotal(String account);
}
