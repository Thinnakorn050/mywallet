import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mywallet/common_widgets/account_builder.dart';
import 'package:mywallet/common_widgets/category_builder.dart';
import 'package:mywallet/models/account.dart';
import 'package:mywallet/models/category.dart';
import 'package:mywallet/models/transfer.dart';
import 'package:mywallet/pages/account_form_page.dart';
import 'package:mywallet/pages/category_form_page.dart';
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
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Profile_page'),
          centerTitle: true,
          bottom: TabBar(
            tabs: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text('Account'),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text('Category'),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            AccountBuilder(
              future: _getAccounts(),
            ),
            CategoryBuilder(
              future: _getCategories(),
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
              child: FaIcon(FontAwesomeIcons.plus),
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
              child: FaIcon(FontAwesomeIcons.check),
            ),
          ],
        ),
      ),
    );
  }
}
