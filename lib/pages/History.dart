import 'package:flutter/material.dart';
import 'package:mywallet/common_widgets/account_viewer.dart';
import 'package:mywallet/models/account.dart';
import 'package:mywallet/models/category.dart';
import 'package:mywallet/models/transfer.dart';
import 'package:mywallet/pages/account_detail_page.dart';
import 'package:mywallet/services/database_service.dart';

class History extends StatefulWidget {
  const History({Key? key}) : super(key: key);

  @override
  _HistoryState createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  final DatabaseService _databaseService = DatabaseService();

  Future<List<Account>> _getAccounts() async {
    return await _databaseService.accountAll();
  }

  Future<List<Category>> _getCategories() async {
    return await _databaseService.categoryAll();
  }

  Future<void> _onTransferDelete(Transfer tran) async {
    await _databaseService.deleteTran(tran.id!);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 1,
      child: Scaffold(
        appBar: AppBar(
          title: Text('History'),
          centerTitle: true,
          bottom: TabBar(
            tabs: [
              Tab(
                icon: Icon(Icons.account_balance_wallet_outlined),
                text: 'Account',
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            AccountViewer(
              future: _getAccounts(),
              onDetail: (value) {
                {
                  Navigator.of(context)
                      .push(
                        MaterialPageRoute(
                          builder: (_) => AccountDetailPage(account: value),
                          fullscreenDialog: true,
                        ),
                      )
                      .then((_) => setState(() {}));
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
