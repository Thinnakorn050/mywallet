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

  String? _moneyErrorText; // Error text for money input field
  int _selectedAccount = 0;
  int _selectedCategory = 0;
  DateTime _selectedDate = DateTime.now(); // Initialize with current date
  bool initAcc = false;
  bool initCat = false;
  bool _isExpense = false; // Track whether it's an expense or income

  @override
  void initState() {
    super.initState();

    // Update
    if (widget.tran != null) {
      _nameController.text = widget.tran!.memo;
      _moneyController.text =
          widget.tran!.money.abs().toString(); // Ensure positive value
      _selectedDate = widget.tran!.date;
      // Check if it's an expense or income
      _isExpense = widget.tran!.money < 0;
    }
  }

  Future<List<Account>> _getAccounts() async {
    final accounts = await _databaseService.accountAll();

    _accounts = [];
    _accounts.addAll(accounts);

    if (widget.tran != null && !initAcc) {
      _selectedAccount =
          _accounts.indexWhere((e) => e.id == widget.tran!.accountId);
      initAcc = true;
    }
    return Future.value(_accounts);
  }

  Future<List<Category>> _getCategories() async {
    final categories = await _databaseService.categoryAll();

    _categories = [];
    _categories.addAll(categories);

    if (widget.tran != null && !initCat) {
      _selectedCategory =
          _categories.indexWhere((e) => e.id == widget.tran!.categoryId);
      initCat = true;
    }
    return Future.value(_categories);
  }

  Future<void> _onSave() async {
    // Check for money input
    if (_moneyController.text.isEmpty) {
      setState(() {
        _moneyErrorText = 'Cannot be empty';
      });
      return;
    }

    // Check for number only money input
    final RegExp numberRegex = RegExp(r'^-?[0-9]+$');
    if (!numberRegex.hasMatch(_moneyController.text)) {
      setState(() {
        _moneyErrorText = 'Please enter a valid number';
      });
      return;
    }

    // Reset error text
    //setState(() {_moneyErrorText = null; });

    final money =
        int.parse(_moneyController.text.trim()) * (_isExpense ? -1 : 1);
    final date = _selectedDate;
    final memo =
        _nameController.text.trim(); // Use the value from the TextField
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
        title: const Text('New Transfer'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 30.0),
              // Button to toggle between expense and income
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isExpense = !_isExpense;
                  });
                },
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.resolveWith<Color>((states) {
                    if (_isExpense) {
                      // Return red color if _isExpense is true
                      return Colors.red;
                    } else {
                      // Return green color if _isExpense is false
                      return Colors.green;
                    }
                  }),
                ),
                child: Text(
                  _isExpense ? 'Expense' : 'Income',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Color.fromRGBO(255, 255, 255, 1),
                  ),
                ),
              ),

              const SizedBox(height: 16.0),
              TextField(
                controller: _moneyController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter Money here ',
                  errorText: _moneyErrorText,
                ),
              ),
              const SizedBox(height: 16.0),
              FutureBuilder<List<Account>>(
                future: _getAccounts(),
                builder: (context, accountSnapshot) {
                  if (accountSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Text("Loading accounts...");
                  }
                  return FutureBuilder<List<Category>>(
                    future: _getCategories(),
                    builder: (context, categorySnapshot) {
                      if (categorySnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Text("Loading categories...");
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
                          const SizedBox(height: 16.0),
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
              const SizedBox(height: 24.0),
              _buildDatePicker(),
              const SizedBox(height: 24.0),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Memo',
                ),
              ),
              SizedBox(height: 16.0),
              SizedBox(
                height: 45.0,
                child: ElevatedButton(
                  onPressed: _onSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green, // Background color
                    foregroundColor: Colors.white, // Text color
                  ),
                  child: const Text(
                    'Save',
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              SizedBox(
                height: 45.0,
                child: ElevatedButton(
                  onPressed: _onCancel,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Color.fromARGB(255, 227, 25, 25), // Background color
                    foregroundColor: Colors.white, // Text color
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 300),
            ],
          ),
        ),
      ),
    );
  }

  // Date Picker Widget
  Widget _buildDatePicker() {
    return ListTile(
      title: Text(
        "Select Date",
        style: TextStyle(
          fontSize: 16.0,
        ),
      ),
      subtitle: Text(
          "${_selectedDate.toLocal()}".split(' ')[0]), // Display selected date
      onTap: () async {
        final DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (pickedDate != null && pickedDate != _selectedDate)
          setState(() {
            _selectedDate = pickedDate;
          });
      },
    );
  }
}
