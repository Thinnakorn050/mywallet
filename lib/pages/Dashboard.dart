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
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Dashboard', style: theme.textTheme.headline6),
      ),
      body: FutureBuilder(
        future: Future.wait([_accounts, _sums]),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('No data available'));
          } else {
            final List<Account> accounts = snapshot.data![0];
            final Map<int, int> sums = snapshot.data![1];

            return ListView.builder(
              itemCount: accounts.length,
              itemBuilder: (context, index) {
                final account = accounts[index];
                final sum = sums[account.id] ?? 0;
                final color = sum >= 0 ? theme.colorScheme.secondary : theme.colorScheme.error;

                return Card(
                  margin: EdgeInsets.all(8.0),
                  child: ListTile(
                    leading: Icon(
                      Icons.account_balance_wallet, // Consider dynamically changing this icon based on account type
                      size: 30.0,
                      color: color,
                    ),
                    title: Text(
                      account.name,
                      style: theme.textTheme.subtitle1,
                    ),
                    subtitle: Text(
                      'Total: $sum',
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: Icon(Icons.chevron_right),
                    onTap: () {
                      // Navigate to account details or perform another action
                    },
                  ),
                  elevation: 4.0,
                  shadowColor: Colors.black45,
                );
              },
            );
          }
        },
      ),
    );
  }
}
