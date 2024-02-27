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

  late Future<List<Transfer>> _transfers;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    _transfers = _databaseService.transfersByAccountId(widget.account!.id!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.account!.name} Detail'),
      ),
      body: FutureBuilder(
        future: _transfers,
        builder: (context, AsyncSnapshot<List<Transfer>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text('Error loading transfers. Please try again.'),
                    ),
                  );
                  _loadData(); // Retry on button press
                },
                child: Text('Retry'),
              ),
            );
          } else {
            final List<Transfer> transfers = snapshot.data!;

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
                _buildTransactionSection('Transfers', transfers),
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
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        if (transfers.isEmpty)
          Center(
            child: Text('No transfers available.'),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            itemCount: transfers.length,
            itemBuilder: (context, index) {
              final transfer = transfers[index];

              return Column(
                children: [
                  ListTile(
                    title: Text('Money: ${transfer.money}'),
                    subtitle: Text('Date: ${transfer.date}'),
                    // Add more details based on your Transfer model
                  ),
                  if (index < transfers.length - 1) Divider(),
                ],
              );
            },
          ),
      ],
    );
  }
}
