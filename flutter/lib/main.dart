import 'package:accrualtracker/file_data_provider.dart';
import 'package:flutter/material.dart';

import 'package:accrualtracker/domain_model.dart';
import 'package:accrualtracker/http_data_provider.dart';
import 'package:accrualtracker/data_provider.dart';

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
  String _recordId = "";
  final Map<String, double> _totals = {};

  DateTime _selectedDate = DateTime.now();

  String _description = "";
  double _amount = 0.0;
  String _selectedAccount = AccountTypes.essen.name;
  int _id = 0;

  Future<void> _createAccrualRecord() async {
    AccrualRecord ar = AccrualRecord(
        id: _id,
        day: _selectedDate,
        description: _description,
        amountEuro: _amount,
        account: _selectedAccount);
    var jsonData = ar.toJson();
    DataProvider dataProvider = FileDataProvider();
    // HttpDataProvider();

    var response = await dataProvider.postData(jsonData);
    _recordId = response.toString();

    var total = await dataProvider.getTotal(ar.account);

    setState(() {
      _recordId = response.toString();
      _totals[ar.account] = total.toDouble();
    });
    print("recordId is now $_recordId, totals is now $_totals");
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
                  Container(
                    margin: const EdgeInsets.symmetric(
                        vertical: 4.0, horizontal: 8.0),
                    child: Text(_recordId),
                  ),
                  Container(
                    color: Colors.blueGrey,
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
        onPressed: _createAccrualRecord,
        tooltip: 'Create',
        child: const Icon(Icons.save),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
