import 'dart:io';

import 'package:mywallet/models/account.dart';
import 'package:mywallet/models/category.dart';
import 'package:mywallet/models/transfer.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

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

  Future<List<Account>> accountAll() async {
    // Get a reference to the database.
    final db = await _databaseService.database;

    // Query the table for all
    final List<Map<String, dynamic>> maps = await db.query('account');

    // Convert the List<Map<String, dynamic> into a List<Account>.
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

    final List<Map<String, dynamic>> maps = await db.query('category');

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

  Future<List<Transfer>> tranfer10Newest() async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transfer',
      orderBy: 'date DESC',
      limit: 10,
    );
    return List.generate(maps.length, (index) => Transfer.fromMap(maps[index]));
  }

  Future<void> updateAccount(Account account) async {
    // Get a reference to the database.
    final db = await _databaseService.database;

    await db.update(
      'account',
      account.toMap(),
      // Ensure that the account has a matching id.
      where: 'id = ?',
      // Pass the account's id as a whereArg to prevent SQL injection.
      whereArgs: [account.id],
    );
  }

  Future<void> updateCategory(Category category) async {
    // Get a reference to the database.
    final db = await _databaseService.database;

    await db.update(
      'category',
      category.toMap(),
      where: 'id = ?',
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

  Future<void> deleteAccount(int id) async {
    // Get a reference to the database.
    final db = await _databaseService.database;

    await db.delete(
      'account',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteCategory(int id) async {
    // Get a reference to the database.
    final db = await _databaseService.database;

    await db.delete(
      'category',
      where: 'id = ?',
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

  Future<List<Transfer>> transfersByAccountId(int accountId) async {
    final Database db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      'transfer', // Correct table name
      where: 'accountId = ?',
      whereArgs: [accountId],
    );

    return List.generate(maps.length, (i) {
      return Transfer(
        id: maps[i]['id'],
        money: maps[i]['money'],
        date: DateTime.parse(maps[i]['date']),
        memo: maps[i]['memo'],
        accountId: maps[i]['accountId'],
        categoryId: maps[i]['categoryId'],
        // Add other fields based on your Transfer model
      );
    });
  }

  Future<void> exportDataToCSV() async {
    //CSV file exported to: /storage/emulated/0/Android/data/com.example.mywallet/files/transfers.csv
    Permission.storage.request();
    // Retrieve data from the database
    List<Transfer> transfers = await tranferAll();

    // Convert data to CSV format
    List<List<dynamic>> csvData = [];
    // Add header row
    csvData.add(['ID', 'Money', 'Date', 'Memo', 'Account', 'Category']);
    // Add data rows
    for (var transfer in transfers) {
      Account acc = await accountOne(transfer.accountId);
      Category cat = await categoryOne(transfer.categoryId);
      String datetime = (transfer.date.day.toString() +
          "-" +
          transfer.date.month.toString() +
          "-" +
          transfer.date.year.toString());

      csvData.add([
        transfer.id,
        transfer.money,
        datetime,
        transfer.memo,
        acc.name,
        cat.name,
      ]);
    }

    // Generate CSV string
    String csvString = const ListToCsvConverter().convert(csvData);

    // Get external storage directory
    Directory? directory = await getExternalStorageDirectory();
    if (directory != null) {
      String filePath = '/storage/emulated/0/Download/transfers.csv';
      // Write CSV data to file
      File file = File(filePath);
      await file.writeAsString(csvString);

      print('CSV file exported to: /Download/transfers.csv');
    } else {
      print('Error: External storage directory not found.');
    }
  }
}
