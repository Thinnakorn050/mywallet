import 'package:mywallet/models/account.dart';
import 'package:mywallet/models/category.dart';
import 'package:mywallet/models/transfer.dart';
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

    //return new database
    _database = await _initDatabase();
    print('555 create database');
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

    //delete everytime program run
    deleteDatabase(path);

    //then create
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
    await db.execute(
      'CREATE TABLE account(id INTEGER PRIMARY KEY, name TEXT)',
    );
    await db.execute(
      'CREATE TABLE category(id INTEGER PRIMARY KEY, name TEXT)',
    );

    //no F key for now it's error
    await db.execute(
      'CREATE TABLE transfer('
      'id INTEGER PRIMARY KEY, '
      'money INTEGER, '
      'date TEXT, '
      'memo TEXT, '
      'accountId INTEGER, '
      'categoryId INTEGER, '
      'FOREIGN KEY(accountId) REFERENCES account(id), '
      'FOREIGN KEY(categoryId) REFERENCES category(id)'
      ')',
    );

    //insert base data
    await db.execute(
      'INSERT INTO account (name) VALUES ("💵Cash"), ("🟪SCB-Bank"), ("🟨KrungSri-Bank")',
    );
    await db.execute(
      'INSERT INTO category (name) VALUES ("💼Work"), ("🍛Food"), ("🛒Shopping")',
    );

    //base balance from work
    await db.execute(
      'INSERT INTO transfer (money, date, memo, accountId, categoryId) VALUES ("3000", "2024-01-01 11:11:11", "default", "1", "1")',
    );
    await db.execute(
      'INSERT INTO transfer (money, date, memo, accountId, categoryId) VALUES ("4000", "2024-01-01 11:11:11", "default", "2", "1")',
    );
    await db.execute(
      'INSERT INTO transfer (money, date, memo, accountId, categoryId) VALUES ("5000", "2024-01-01 11:11:11", "default", "3", "1")',
    );

    //base balance from food
    await db.execute(
      'INSERT INTO transfer (money, date, memo, accountId, categoryId) VALUES ("-120", "2024-01-01 11:11:11", "default", "1", "2")',
    );
    await db.execute(
      'INSERT INTO transfer (money, date, memo, accountId, categoryId) VALUES ("-60", "2024-01-02 11:11:11", "default", "1", "2")',
    );

    //base balance from shopping
    await db.execute(
      'INSERT INTO transfer (money, date, memo, accountId, categoryId) VALUES ("-3000", "2024-02-02 11:11:11", "default", "1", "3")',
    );
    await db.execute(
      'INSERT INTO transfer (money, date, memo, accountId, categoryId) VALUES ("-1000", "2024-02-03 11:11:11", "default", "1", "3")',
    );
  }

  Future<void> insertAccount(Account account) async {
    // Get a reference to the database.
    final db = await _databaseService.database;

    // In this case, replace any previous data.
    await db.insert(
      'account',
      account.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertCategory(Category category) async {
    // Get a reference to the database.
    final db = await _databaseService.database;
    await db.insert(
      'category',
      category.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertTranfer(Transfer tran) async {
    final db = await _databaseService.database;
    await db.insert(
      'transfer',
      tran.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // A method that retrieves all the breeds from the breeds table.
  Future<List<Account>> accountAll() async {
    // Get a reference to the database.
    final db = await _databaseService.database;

    // Query the table for all the Breeds.
    final List<Map<String, dynamic>> maps = await db.query('account');

    // Convert the List<Map<String, dynamic> into a List<Breed>.
    return List.generate(maps.length, (index) => Account.fromMap(maps[index]));
  }

  Future<Account> accountOne(int id) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps =
        await db.query('account', where: 'id = ?', whereArgs: [id]);
    return Account.fromMap(maps[0]);
  }

  Future<List<Category>> categoryAll() async {
    // Get a reference to the database.
    final db = await _databaseService.database;

    // Query the table for all the Breeds.
    final List<Map<String, dynamic>> maps = await db.query('category');

    // Convert the List<Map<String, dynamic> into a List<Breed>.
    return List.generate(maps.length, (index) => Category.fromMap(maps[index]));
  }

  Future<Category> categoryOne(int id) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps =
        await db.query('category', where: 'id = ?', whereArgs: [id]);
    return Category.fromMap(maps[0]);
  }

  Future<List<Transfer>> tranferAll() async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query('transfer');
    return List.generate(maps.length, (index) => Transfer.fromMap(maps[index]));
  }

  // A method that updates a breed data from the breeds table.
  Future<void> updateAccount(Account account) async {
    // Get a reference to the database.
    final db = await _databaseService.database;

    // Update the given breed
    await db.update(
      'account',
      account.toMap(),
      // Ensure that the Breed has a matching id.
      where: 'id = ?',
      // Pass the Breed's id as a whereArg to prevent SQL injection.
      whereArgs: [account.id],
    );
  }

  // A method that updates a breed data from the breeds table.
  Future<void> updateCategory(Category category) async {
    // Get a reference to the database.
    final db = await _databaseService.database;

    // Update the given breed
    await db.update(
      'category',
      category.toMap(),
      // Ensure that the Breed has a matching id.
      where: 'id = ?',
      // Pass the Breed's id as a whereArg to prevent SQL injection.
      whereArgs: [category.id],
    );
  }

  Future<void> updateTran(Transfer tran) async {
    final db = await _databaseService.database;
    await db.update('transfer', tran.toMap(),
        where: 'id = ?', whereArgs: [tran.id]);
  }

  Future<Transfer> transferOne(int id) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps =
        await db.query('transfer', where: 'id = ?', whereArgs: [id]);
    return Transfer.fromMap(maps[0]);
  }

  // A method that deletes a breed data from the breeds table.
  Future<void> deleteAccount(int id) async {
    // Get a reference to the database.
    final db = await _databaseService.database;

    // Remove the Breed from the database.
    await db.delete(
      'account',
      // Use a `where` clause to delete a specific breed.
      where: 'id = ?',
      // Pass the Breed's id as a whereArg to prevent SQL injection.
      whereArgs: [id],
    );
  }

  Future<void> deleteCategory(int id) async {
    // Get a reference to the database.
    final db = await _databaseService.database;

    // Remove the Breed from the database.
    await db.delete(
      'category',
      // Use a `where` clause to delete a specific breed.
      where: 'id = ?',
      // Pass the Breed's id as a whereArg to prevent SQL injection.
      whereArgs: [id],
    );
  }

  Future<void> deleteTran(int id) async {
    final db = await _databaseService.database;
    await db.delete('transfer', where: 'id = ?', whereArgs: [id]);
  }

  Future<Map<int, int>> sumMoneyGroupedByAccountId() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery(
        'SELECT accountId, SUM(money) AS totalMoney FROM transfer GROUP BY accountId');
    final Map<int, int> sums = {};
    for (final row in result) {
      sums[row['accountId'] as int] = row['totalMoney'] as int;
    }
    return sums;
  }
}
