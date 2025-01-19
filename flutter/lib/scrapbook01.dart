class _MyHomePageState extends State<MyHomePage> {
  // Add these lines
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  // Rest of your code...

  void _clearInputs() {
    _selectedDate = DateTime.now();

    setState(() {
      _descriptionController.clear(); // Clear description field
      _amountController.clear(); // Clear amount field
      _selectedAccount = AccountTypes.essen.name;
    });
  }

  // Rest of your code...

  @override
  Widget build(BuildContext context) {
    // Rest of your code...

    return Scaffold(
      // Rest of your code...

      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: ListView(
                // Rest of your code...

                children: [
                  // Rest of your code...

                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                    child: TextField(
                      controller: _descriptionController, // Add this line
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
                      controller: _amountController, // Add this line
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

                  // Rest of your code...
                ],
              ),
            ),
          ],
        ),
      ),

      // Rest of your code...
    );
  }
}
