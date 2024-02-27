import 'package:flutter/material.dart';
import 'package:mywallet/models/account.dart';
import 'package:mywallet/models/transfer.dart';
import 'package:mywallet/services/database_service.dart';

class AccountDetailPage extends StatefulWidget {
  const AccountDetailPage({Key? key, this.account}) : super(key: key);
  final Account? account;

  @override
  _AccountDetailPageState createState() => _AccountDetailPageState();
}

class _AccountDetailPageState extends State<AccountDetailPage> {
  final DatabaseService _databaseService = DatabaseService();

  late Future<List<Transfer>> _incomeTransfers;
  late Future<List<Transfer>> _expenseTransfers;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    _incomeTransfers = _databaseService.transfersByAccountId(
      widget.account!.id!,
      isIncome: true,
    );
    _expenseTransfers = _databaseService.transfersByAccountId(
      widget.account!.id!,
      isIncome: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.account!.name} Detail'),
      ),
      body: FutureBuilder(
        future: Future.wait([_incomeTransfers, _expenseTransfers]),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final List<Transfer> incomeTransfers = snapshot.data![0];
            final List<Transfer> expenseTransfers = snapshot.data![1];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Account Name: ${widget.account!.name}',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                _buildTransactionSection('Income', incomeTransfers),
                _buildTransactionSection('Expense', expenseTransfers),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildTransactionSection(String title, List<Transfer> transfers) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: transfers.length,
            itemBuilder: (context, index) {
              final transfer = transfers[index];

              return ListTile(
                title: Text('Money: ${transfer.money}'),
                subtitle: Text('Date: ${transfer.date}'),
                // Add more details based on your Transfer model
              );
            },
          ),
        ),
        Divider(),
      ],
    );
  }
}
