import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Accrual Tracker'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class DataProvider {
  final String apiUrl;
  final String secret = "c0fa0758-b954-11ee-9a88-3baa8ec87383";
  DataProvider(this.apiUrl);

  Future<String> getData() async {
    final response = await http.get(Uri.parse(apiUrl));
    final Map<String, dynamic> responseBody = json.decode(response.body);
    return responseBody['origin'];
  }

  Future<String> postData(Map<String, dynamic> jsonData) async {
    var payload = <String, dynamic>{};
    payload["secret"] = secret;
    payload["records"] = [];
    payload["records"].add(jsonData);
    print("BEHOLD THIS: ${json.encode(payload)}");
    final http.Response response = await http.post(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: json.encode(payload),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to post data: ${response.statusCode}');
    }
    final Map<String, dynamic> responseBody = json.decode(response.body);
    return responseBody.toString();
  }
}

class AccrualRecord {
  DateTime day;
  String description;
  double amountEuro;
  String account;

  AccrualRecord({
    required this.day,
    required this.description,
    required this.amountEuro,
    required this.account,
  });

  @override
  String toString() {
    return 'day: $day, description: $description, amount: $amountEuro, account: $account';
  }

  Map<String, dynamic> toJson() {
    return {
      'day': day.toIso8601String(),
      'description': description,
      'amountEuro': amountEuro,
      'account': account,
    };
  }

  factory AccrualRecord.fromJson(Map<String, dynamic> json) {
    return AccrualRecord(
      day: DateTime.parse(json['day']),
      description: json['description'],
      amountEuro: json['amountEuros'],
      account: json['account'],
    );
  }
}

enum AccountTypes {
  ansparen,
  sabadell,
  heizen,
  lucy,
  taschengeld,
  cut,
  essen,
  strom,
  miete,
  telekom,
  sonstiges,
  orf
}

class _MyHomePageState extends State<MyHomePage> {
  final String _message = "n/a";
  final int _counter = 0;

  DateTime _selectedDate = DateTime.now();
  String _description = "";
  double _amount = 0.0;
  String _selectedAccount = AccountTypes.essen.name;

  Future<void> _createAccrualRecord() async {
    AccrualRecord ar = AccrualRecord(
        day: _selectedDate,
        description: _description,
        amountEuro: _amount,
        account: _selectedAccount);
    var jsonData = ar.toJson();
    final DataProvider dataProvider =
        DataProvider('http://localhost:7071/api/mk_acc_http_trigger');
    var response = await dataProvider.postData(jsonData);
    print(response);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.dark(), // Customize the date picker theme if needed
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: ListView(
                scrollDirection: Axis.vertical, // Change to vertical
                children: [
                  Container(
                    margin: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () => _selectDate(context),
                      style: ElevatedButton.styleFrom(
                          textStyle: const TextStyle(fontSize: 20.0)),
                      child: const Text('Select Date'),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.all(12.0),
                    child: Text(
                      _selectedDate.toLocal().toString().split(' ')[0],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                    child: TextField(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Description',
                      ),
                      onChanged: (value) {
                        _description = value;
                      },
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                    child: TextFormField(
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: "Amount",
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        _amount = double.parse(value);
                      },
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(
                        vertical: 4.0, horizontal: 8.0),
                    child: DropdownButton<String>(
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedAccount = newValue;
                          });
                        }
                      },
                      value: _selectedAccount,
                      items: AccountTypes.values.map((AccountTypes accType) {
                        return DropdownMenuItem<String>(
                          value: accType.name,
                          child: Text(accType.toString().split('.').last),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createAccrualRecord,
        tooltip: 'Create',
        child: const Icon(Icons.save),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
