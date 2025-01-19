import 'package:accrualtracker/file_data_provider.dart';
import 'package:accrualtracker/settings_provider.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:accrualtracker/domain_model.dart';
import 'package:accrualtracker/http_data_provider.dart';
import 'package:accrualtracker/data_provider.dart';
import 'package:accrualtracker/settings_screen.dart';

void main() async {
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

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  double _totalBudget = 0.0;

  String _recordId = "";
  Map<String, double> _totals = {};

  DateTime _selectedDate = DateTime.now();

  String _description = "";
  double _amount = 0.0;
  String _selectedAccount = AccountTypes.essen.name;

  String _message = "";

  DataProvider _dataProvider = FileDataProvider();

  Map<String, double> _budgets = {};
  bool didInitialize = false;

  @override
  void initState() {
    super.initState();
    if (!didInitialize) {
      didInitialize = true;
      // Your one-time initialization code here
      SettingsProvider.load().then((settings) async {
        var budgets =
            Map.castFrom<String, dynamic, String, double>(settings["budgets"]);
        setState(() {
          _budgets = budgets;
        });
      });
    }
  }

  Future<AccrualResponse> _createAccrualRecord() async {
    AccrualRecord ar = AccrualRecord(
        id: "",
        day: _selectedDate,
        description: _description,
        amountEuro: _amount,
        account: _selectedAccount);
    var jsonData = ar.toJson();

    var response = await _dataProvider.postData(jsonData);
    _recordId = response.toString();

    return AccrualResponse(
        id: _recordId, totalAmountEuro: 0.0, account: ar.account);
  }

  Future<void> _onSubmitButtonPressed() async {
    if (_amount == 0.0) {}
    AccrualResponse ar = await _createAccrualRecord();
    var totals = await _dataProvider.getAllTotals();

    setState(() {
      _totals = totals;
      _recordId = ar.id.toString();
      _descriptionController.clear();
      _description = "";
      _amountController.clear();
      _amount = 0.0;
      _selectedAccount = AccountTypes.essen.name;
    });
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
    // _dataProvider.getAllTotals().then((value) {
    //   setState(() {
    //     _totals = value;
    //   });
    // });

    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.share), // Add your button icon here
            onPressed: () async {
              // Add your button onPressed callback here
              // Get the application documents directory
              Directory appDocDir = await getApplicationDocumentsDirectory();
              String appDocPath = appDocDir.path;

              // Construct the file path
              String filePath = '$appDocPath/accruals.csv';

              // Check if the file exists
              if (File(filePath).existsSync()) {
                // Share the file
                Share.shareXFiles([XFile(filePath)]);
              } else {
                print('File not found');
              }
            },
          ),
          IconButton(
              onPressed: _showSettings, icon: const Icon(Icons.settings)),
        ],
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
                      controller: _descriptionController,
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
                      controller: _amountController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: "Amount",
                        border: OutlineInputBorder(),
                      ),
                      onChanged: _saveAmount,
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
                  Container(
                    margin: const EdgeInsets.symmetric(
                        vertical: 4.0, horizontal: 8.0),
                    child: Text(_message),
                  ),
                  Container(
                    color: const Color.fromARGB(255, 167, 214, 237),
                    margin: const EdgeInsets.symmetric(
                        vertical: 4.0, horizontal: 8.0),
                    child: Table(
                      border: TableBorder.all(),
                      children: _totals.entries.map((entry) {
                        return TableRow(
                          children: [
                            Text(entry.key,
                                style:
                                    Theme.of(context).textTheme.displaySmall),
                            Text(entry.value.toString(),
                                style:
                                    Theme.of(context).textTheme.displaySmall),
                            Text(_budgets[entry.key].toString(),
                                style:
                                    Theme.of(context).textTheme.displaySmall),
                          ],
                        );
                      }).toList(),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onSubmitButtonPressed,
        tooltip: 'Create',
        child: const Icon(Icons.save),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void _saveAmount(value) {
    _amount = double.parse(value);
  }

  void _showSettings() async {
    SettingsScreen ss = SettingsScreen();
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ss,
        )).then((context) {
      SettingsProvider.load().then((value) => setState(() {
            _totalBudget = value["totalBudget"];
            _message = "read setting _totalBudget=$_totalBudget";
          }));
    });
  }
}
