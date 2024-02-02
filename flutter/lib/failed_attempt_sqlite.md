```
void main() async {
  // Avoid errors caused by flutter upgrade.
// Importing 'package:flutter/widgets.dart' is required.
// WidgetsFlutterBinding.ensureInitialized();
// Open the database and store the reference.
// Avoid errors caused by flutter upgrade.
// Importing 'package:flutter/widgets.dart' is required.
  WidgetsFlutterBinding.ensureInitialized();
// Open the database and store the reference.
  final database = openDatabase(
    // Set the path to the database. Note: Using the `join` function from the
    // `path` package is best practice to ensure the path is correctly
    // constructed for each platform.
    databaseFactory = databaseFactoryFfi;
    join(await getDatabasesPath(), 'accruals.db'),
    // When the database is first created, create a table to store dogs.
    onCreate: (db, version) {
      // Run the CREATE TABLE statement on the database.
      return db.execute(
        'CREATE TABLE accruals (' +
            ' id INTEGER PRIMARY KEY AUTOINCREMENT,' +
            'day DATE,' +
            'description TEXT,' +
            'amount_euro REAL,' +
            'account TEXT)',
      );
    },
    // Set the version. This executes the onCreate function and provides a
    // path to perform database upgrades and downgrades.
    version: 1,
  );
  // Define a function that inserts dogs into the database
  Future<void> insertAccrual(AccrualRecord acc) async {
    // Get a reference to the database.
    final db = await database;

    // Insert the Dog into the correct table. You might also specify the
    // `conflictAlgorithm` to use in case the same dog is inserted twice.
    //
    // In this case, replace any previous data.
    await db.insert(
      'dogs',
      acc.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

// Create a Dog and add it to the dogs table
  var fido = AccrualRecord(
    id: 0,
    day: DateTime.now(),
    description: "Daily Billa",
    amountEuro: 2.34,
    account: AccountTypes.essen.name,
  );

  await insertAccrual(fido);

  // A method that retrieves all the dogs from the dogs table.
  Future<List<AccrualRecord>> accruals() async {
    // Get a reference to the database.
    final db = await database;

    // Query the table for all The Dogs.
    final List<Map<String, dynamic>> maps = await db.query('accruals');

    // Convert the List<Map<String, dynamic> into a List<Dog>.
    return List.generate(maps.length, (i) {
      return AccrualRecord(
        id: maps[i]['id'] as int,
        day: maps[i]['day'] as DateTime,
        description: maps[i]['description'] as String,
        amountEuro: maps[i]['amount_euro'] as double,
        account: maps[i]['account'] as String,
      );
    });
  }

  runApp(const MyApp());
}
```

and then this happened:
```
martin@martin-HP-EliteBook-830-G6:~/Documents/dev/github/accrualtracker/flutter$ flutter run
Launching lib/main.dart on Linux in debug mode...
Building Linux application...                                           

(accrualtracker:2905336): Gdk-CRITICAL **: 20:50:56.890: gdk_window_get_state: assertion 'GDK_IS_WINDOW (window)' failed
[ERROR:flutter/runtime/dart_vm_initializer.cc(41)] Unhandled Exception: Bad state: databaseFactory not initialized
databaseFactory is only initialized when using sqflite. When using `sqflite_common_ffi`
You must call `databaseFactory = databaseFactoryFfi;` before using global openDatabase API

#0      databaseFactory.<anonymous closure> (package:sqflite_common/src/sqflite_database_factory.dart:29:7)
#1      databaseFactory (package:sqflite_common/src/sqflite_database_factory.dart:33:6)
#2      getDatabasesPath (package:sqflite_common/sqflite.dart:105:38)
#3      main (package:accrualtracker/main.dart:21:16)
#4      _runMain.<anonymous closure> (dart:ui/hooks.dart:159:23)
#5      _delayEntrypointInvocation.<anonymous closure> (dart:isolate-patch/isolate_patch.dart:296:19)
#6      _RawReceivePort._handleMessage (dart:isolate-patch/isolate_patch.dart:189:12)
```