import 'package:flutter/material.dart';
import 'package:mywallet/models/account.dart';
import 'package:mywallet/pages/account_form_page.dart';
import 'package:mywallet/services/database_service.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final DatabaseService _databaseService = DatabaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FutureBuilder<List<Account>>(
          future: _databaseService.accountAll(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // Display a loading indicator while waiting for data
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              // Display an error message if data fetching fails
              return Text('Error: ${snapshot.error}');
            } else {
              // Data has been loaded successfully, display the account list
              List<Account>? accounts = snapshot.data;
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 20),
                  Text(
                    'Add Account button : ',
                    style: TextStyle(fontSize: 20),
                  ),
                  ElevatedButton(
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
                    child: Icon(
                      Icons.account_balance_wallet,
                      size: 100,
                      color: Colors.blue,
                    ),
                  ),
                  Text(
                    'Account List : ',
                    style: TextStyle(fontSize: 20),
                  ),
                  // Display account names from the fetched data
                  if (accounts != null)
                    ...accounts.map((account) => Text(
                          'Account: ${account.toString()}',
                          style: TextStyle(fontSize: 20),
                        )),
                  SizedBox(height: 20),
                  Text(
                    'Add category button : ',
                    style: TextStyle(fontSize: 20),
                  ),
                  Text(
                    'category List : ',
                    style: TextStyle(fontSize: 20),
                  ),
                  Text(
                    'category 1 : Food',
                    style: TextStyle(fontSize: 20),
                  ),
                  Text(
                    'category 2 : Shopping',
                    style: TextStyle(fontSize: 20),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
