import 'package:mywallet/models/Transaction.dart';
import 'package:mywallet/models/account.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  // Singleton pattern
  static final DatabaseService _databaseService = DatabaseService._internal();
  factory DatabaseService() => _databaseService;
  DatabaseService._internal();

  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    // Initialize the DB first time it is accessed
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();

    // Set the path to the database. Note: Using the `join` function from the
    // `path` package is best practice to ensure the path is correctly
    // constructed for each platform.
    final path = join(databasePath, 'flutter_sqflite_database.db');

    // Set the version. This executes the onCreate function and provides a
    // path to perform database upgrades and downgrades.
    return await openDatabase(
      path,
      onCreate: _onCreate,
      version: 1,
      onConfigure: (db) async => await db.execute('PRAGMA foreign_keys = ON'),
    );
  }

  // When the database is first created, create a table to store breeds
  // and a table to store dogs.
  Future<void> _onCreate(Database db, int version) async {
    // Run the CREATE {breeds} TABLE statement on the database.
    await db.execute(
      'CREATE TABLE accounts(id INTEGER PRIMARY KEY, name TEXT)',
    );
    // Run the CREATE {dogs} TABLE statement on the database.
    await db.execute(
      'CREATE TABLE transactions(id INTEGER PRIMARY KEY, money INTEGER, category INTEGER, date TEXT, memo TEXT, FOREIGN KEY (accountId) REFERENCES accounts(id) ON DELETE SET NULL)',
    );
  }

  // Define a function that inserts breeds into the database
  Future<void> insertAccount(Account account) async {
    // Get a reference to the database.
    final db = await _databaseService.database;

    // Insert the Breed into the correct table. You might also specify the
    // `conflictAlgorithm` to use in case the same breed is inserted twice.
    //
    // In this case, replace any previous data.
    await db.insert(
      'accounts',
      account.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertTransaction(Transaction transaction) async {
    final db = await _databaseService.database;
    await db.insert(
      'transactions',
      transaction.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // A method that retrieves all the breeds from the breeds table.
  Future<List<Account>> accounts() async {
    // Get a reference to the database.
    final db = await _databaseService.database;

    // Query the table for all the Breeds.
    final List<Map<String, dynamic>> maps = await db.query('accounts');

    // Convert the List<Map<String, dynamic> into a List<Breed>.
    return List.generate(maps.length, (index) => Account.fromMap(maps[index]));
  }

  Future<Account> account(int id) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps =
        await db.query('accounts', where: 'id = ?', whereArgs: [id]);
    return Account.fromMap(maps[0]);
  }

  Future<List<Transaction>> transactions() async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query('transactions');
    return List.generate(
        maps.length, (index) => Transaction.fromMap(maps[index]));
  }

  // A method that updates a breed data from the breeds table.
  Future<void> updateAccount(Account account) async {
    // Get a reference to the database.
    final db = await _databaseService.database;

    // Update the given breed
    await db.update(
      'accounts',
      account.toMap(),
      // Ensure that the Breed has a matching id.
      where: 'id = ?',
      // Pass the Breed's id as a whereArg to prevent SQL injection.
      whereArgs: [account.id],
    );
  }

  Future<void> updateTransaction(Transaction transaction) async {
    final db = await _databaseService.database;
    await db.update('transactions', transaction.toMap(),
        where: 'id = ?', whereArgs: [transaction.id]);
  }

  // A method that deletes a breed data from the breeds table.
  Future<void> deleteAccount(int id) async {
    // Get a reference to the database.
    final db = await _databaseService.database;

    // Remove the Breed from the database.
    await db.delete(
      'accounts',
      // Use a `where` clause to delete a specific breed.
      where: 'id = ?',
      // Pass the Breed's id as a whereArg to prevent SQL injection.
      whereArgs: [id],
    );
  }

  Future<void> deleteTransaction(int id) async {
    final db = await _databaseService.database;
    await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }
}
