import 'package:flutter/material.dart';
import 'package:mywallet/common_widgets/account_builder.dart';
import 'package:mywallet/common_widgets/category_builder.dart';
import 'package:mywallet/models/account.dart';
import 'package:mywallet/models/category.dart';
import 'package:mywallet/models/transfer.dart';
import 'package:mywallet/form_page/account_form_page.dart';
import 'package:mywallet/form_page/category_form_page.dart';
import 'package:mywallet/services/database_service.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
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
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Profile'),
          centerTitle: true,
          bottom: TabBar(
            tabs: [
              Tab(
                icon: Icon(Icons.account_balance_wallet_outlined),
                text: 'Account',
              ),
              Tab(
                icon: Icon(Icons.category),
                text: 'Category',
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            AccountBuilder(
              future: _getAccounts(),
              onEdit: (value) {
                {
                  Navigator.of(context)
                      .push(
                        MaterialPageRoute(
                          builder: (_) => AccountFormPage(account: value),
                          fullscreenDialog: true,
                        ),
                      )
                      .then((_) => setState(() {}));
                }
              },
            ),
            CategoryBuilder(
              future: _getCategories(),
              onEdit: (value) {
                {
                  Navigator.of(context)
                      .push(
                        MaterialPageRoute(
                          builder: (_) => CategoryFormPage(category: value),
                          fullscreenDialog: true,
                        ),
                      )
                      .then((_) => setState(() {}));
                }
              },
            ),
          ],
        ),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              onPressed: () {
                Navigator.of(context)
                    .push(
                      MaterialPageRoute(
                        builder: (_) => AccountFormPage(),
                        fullscreenDialog: true,
                      ),
                    )
                    .then((_) => setState(() {}));
              },
              heroTag: 'addAccount',
              child: Icon(Icons.account_balance_wallet_outlined),
            ),
            SizedBox(height: 12.0),
            FloatingActionButton(
              onPressed: () {
                Navigator.of(context)
                    .push(
                      MaterialPageRoute(
                        builder: (_) => CategoryFormPage(),
                        fullscreenDialog: true,
                      ),
                    )
                    .then((_) => setState(() {}));
              },
              heroTag: 'addCategory',
              child: Icon(Icons.category),
            ),
          ],
        ),
      ),
    );
  }
}
