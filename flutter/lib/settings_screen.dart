import 'package:flutter/material.dart';
import 'package:accrualtracker/settings_provider.dart';

class SettingsScreen extends StatefulWidget {
  final double fertig = 223.4;

  const SettingsScreen({super.key});
  get() => fertig;
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  double _totalBudget = 0.0;
  bool didInitialize = false;
  String _message = "";

  @override
  void initState() {
    super.initState();
    if (!didInitialize) {
      didInitialize = true;
      // Your one-time initialization code here
      SettingsProvider.load().then((settings) async {
        String awaitedMessage = await SettingsProvider.getSettingsLocation();
        setState(() {
          _totalBudget = settings["totalBudget"];
          _message =
              "INIT: loaded total budget: $_totalBudget from $awaitedMessage";
          _amountController.text = _totalBudget.toString();
        });
      });
      print('Initialized once!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: ListView(scrollDirection: Axis.vertical, children: [
        Row(
          children: [
            const SizedBox(
                width: 16.0), // Add some spacing between TextField and Button
            Expanded(
              child: TextFormField(
                controller: _amountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: "Amount",
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => _totalBudget = double.parse(value),
              ),
            ),

            const SizedBox(
                width: 16.0), // Add some spacing between TextField and Button
          ],
        ),
        const Row(
          children: [
            SizedBox(
                width: 16.0), // Add some spacing between TextField and Button
            Text("Budget Essen"),
            SizedBox(
                width: 16.0), // Add some spacing between TextField and Button
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Enter something...',
                ),
              ),
            ),
            SizedBox(
                width: 16.0), // Add some spacing between TextField and Button
          ],
        ),
        const Row(
          children: [
            SizedBox(
                width: 16.0), // Add some spacing between TextField and Button
            Text("Budget Sonstiges"),
            SizedBox(
                width: 16.0), // Add some spacing between TextField and Button
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Enter something...',
                ),
              ),
            ),
            SizedBox(
                width: 16.0), // Add some spacing between TextField and Button
          ],
        ),
        ElevatedButton(
          onPressed: () async {
            bool success =
                await SettingsProvider.save({"totalBudget": _totalBudget});
            String awaitedMessage =
                '${success ? "saved settings to" : "couldn't save settings to "} ${await SettingsProvider.getSettingsLocation()}';

            setState(() {
              _message = awaitedMessage;
            });
          },
          child: const Text('Save Settings'),
        ),
        Text(_message),
      ]),
    );
  }
}
