import 'package:flutter/material.dart';
import 'package:mywallet/models/account.dart';
import 'package:mywallet/services/database_service.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final DatabaseService _databaseService = DatabaseService();
  late Future<List<Account>> _accounts;
  late Future<Map<int, int>> _sums;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    _accounts = _databaseService.accountAll();
    _sums = _databaseService.sumMoneyGroupedByAccountId();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('Dashboard'),
        ),
        body: FutureBuilder(
          future: Future.wait([_accounts, _sums]),
          builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              final List<Account> accounts = snapshot.data![0];
              final Map<int, int> sums = snapshot.data![1];

              return ListView.builder(
                itemCount: accounts.length,
                itemBuilder: (context, index) {
                  final account = accounts[index];
                  final sum = sums[account.id] ?? 0;
                  final color = sum >= 0 ? Colors.green : Colors.red;

                  return ListTile(
                    title: Text(account.name),
                    subtitle: Text(
                      'Total: $sum',
                      style: TextStyle(color: color),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
