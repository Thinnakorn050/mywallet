import 'package:flutter/material.dart';
import 'package:mywallet/common_widgets/account_selector.dart';
import 'package:mywallet/common_widgets/category_selector.dart';
import 'package:mywallet/models/account.dart';
import 'package:mywallet/models/category.dart';
import 'package:mywallet/models/transfer.dart';
import 'package:mywallet/services/database_service.dart';

class TranFormPage extends StatefulWidget {
  const TranFormPage({Key? key, this.tran}) : super(key: key);
  final Transfer? tran;

  @override
  _TranFormPageState createState() => _TranFormPageState();
}

class _TranFormPageState extends State<TranFormPage> {
  final TextEditingController _moneyController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  List<Account> _accounts = [];
  List<Category> _categories = [];

  final DatabaseService _databaseService = DatabaseService();

  int _selectedAccount = 0;
  int _selectedCategory = 0;

  @override
  void initState() {
    super.initState();
    if (widget.tran != null) {
      _nameController.text = widget.tran!.memo;
      _moneyController.text = widget.tran!.money.toString();
    }
  }

  Future<List<Account>> _getAccounts() async {
    final accounts = await _databaseService.accountAll();

    _accounts = [];
    _accounts.addAll(accounts);

    if (widget.tran != null) {
      _selectedAccount =
          _accounts.indexWhere((e) => e.id == widget.tran!.accountId);
    }
    return Future.value(_accounts);
  }

  Future<List<Category>> _getCategories() async {
    final categories = await _databaseService.categoryAll();

    _categories = [];
    _categories.addAll(categories);

    if (widget.tran != null) {
      _selectedCategory =
          _categories.indexWhere((e) => e.id == widget.tran!.categoryId);
    }
    return Future.value(_categories); // Wrap the list inside Future.value()
  }

  Future<void> _onSave() async {
    final money =
        int.parse(_moneyController.text); // Replace with your actual value
    final date = DateTime.now();
    final memo = _nameController.text; // Use the value from the TextField
    final account = _accounts[_selectedAccount];
    final category = _categories[_selectedCategory];

    if (widget.tran == null) {
      // Insert Operation (new Transfer)
      await _databaseService.insertTranfer(
        Transfer(
          money: money,
          date: date,
          memo: memo,
          accountId: account.id!,
          categoryId: category.id!,
        ),
      );
    } else {
      // Update Operation (existing Transfer)
      await _databaseService.updateTran(
        Transfer(
          id: widget.tran!.id,
          money: money,
          date: date,
          memo: memo,
          accountId: account.id!,
          categoryId: category.id!,
        ),
      );
    }

    Navigator.pop(context);
  }

  Future<void> _onCancel() async {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Tran Record'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _moneyController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter Money here',
              ),
            ),
            SizedBox(height: 16.0),
            FutureBuilder<List<Account>>(
              future: _getAccounts(),
              builder: (context, accountSnapshot) {
                if (accountSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return Text("Loading accounts...");
                }
                return FutureBuilder<List<Category>>(
                  future: _getCategories(),
                  builder: (context, categorySnapshot) {
                    if (categorySnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return Text("Loading categories...");
                    }
                    return Column(
                      children: [
                        AccountSelector(
                          accounts: _accounts.map((e) => e.name).toList(),
                          selectedIndex: _selectedAccount,
                          onChanged: (value) {
                            setState(() {
                              _selectedAccount = value;
                            });
                          },
                        ),
                        SizedBox(height: 16.0),
                        CategorySelector(
                          categories: _categories.map((e) => e.name).toList(),
                          selectedIndex: _selectedCategory,
                          onChanged: (value) {
                            setState(() {
                              _selectedCategory = value;
                            });
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            SizedBox(height: 24.0),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter Memo here',
              ),
            ),
            SizedBox(height: 16.0),
            SizedBox(
              height: 45.0,
              child: ElevatedButton(
                onPressed: _onSave,
                child: Text(
                  'Save the Tran data',
                  style: TextStyle(
                    fontSize: 16.0,
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.0),
            SizedBox(
              height: 45.0,
              child: ElevatedButton(
                onPressed: _onCancel,
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 16.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
