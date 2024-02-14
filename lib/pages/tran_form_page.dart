import 'package:flutter/material.dart';
import 'package:mywallet/common_widgets/payment_selector.dart';
import 'package:mywallet/models/account.dart';
import 'package:mywallet/models/transfer.dart';
import 'package:mywallet/services/database_service.dart';

class TranFormPage extends StatefulWidget {
  const TranFormPage({Key? key, this.tran}) : super(key: key);
  final Transfer? tran;

  @override
  _TranFormPageState createState() => _TranFormPageState();
}

class _TranFormPageState extends State<TranFormPage> {
  final TextEditingController _nameController = TextEditingController();
  static final List<Color> _colors = [
    Color(0xFF000000),
    Color(0xFFFFFFFF),
    Color(0xFF947867),
    Color(0xFFC89234),
    Color(0xFF862F07),
    Color(0xFF2F1B15),
  ];
  static final List<Account> _accounts = [];

  final DatabaseService _databaseService = DatabaseService();

  int _selectedAccount = 0;

  @override
  void initState() {
    super.initState();
    if (widget.tran != null) {
      _nameController.text = widget.tran!.memo;
    }
  }

  Future<List<Account>> _getAccounts() async {
    final accounts = await _databaseService.accountAll();
    if (_accounts.isEmpty) _accounts.addAll(accounts);
    if (widget.tran != null) {
      _selectedAccount =
          _accounts.indexWhere((e) => e.id == widget.tran!.accountId);
    }
    return _accounts;
  }

  Future<void> _onSave() async {
    final account = _accounts[_selectedAccount];

    // Assuming money and category are of type int
    final money = 100; // Replace with your actual value
    final category = 1; // Replace with your actual value
    final date = DateTime.now(); // Replace with your actual value
    final memo = "SomeMemo"; // Replace with your actual value

    widget.tran == null
        ? await _databaseService.insertTranfer(
            Transfer(
              money: money,
              categoryId: category,
              date: date,
              memo: memo,
              accountId: account.id!,
            ),
          )
        : await _databaseService.updateTran(
            Transfer(
              id: widget.tran!.id,
              money: money,
              categoryId: category,
              date: date,
              memo: memo,
              accountId: account.id!,
            ),
          );

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
              controller: _nameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter name of the Tran here',
              ),
            ),
            SizedBox(height: 16.0),

            // Breed Selector
            FutureBuilder<List<Account>>(
              future: _getAccounts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Text("Loading accounts...");
                }
                return PaymentSelector(
                  breeds: _accounts.map((e) => e.name).toList(),
                  selectedIndex: _selectedAccount,
                  onChanged: (value) {
                    setState(() {
                      _selectedAccount = value;
                    });
                  },
                );
              },
            ),
            SizedBox(height: 24.0),
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
          ],
        ),
      ),
    );
  }
}
