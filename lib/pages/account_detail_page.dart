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

  Future<String> GetcategoryName(int ID) async {
    var temp = await _databaseService.categoryOne(ID);
    return temp.name;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.account!.name} Detail'),
      ),
      body: SingleChildScrollView(
        child: FutureBuilder(
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
              double actualBalance = calculateActualBalance(transfers);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Account Name: ${widget.account!.name}',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  _buildBalanceSection(actualBalance),
                  SizedBox(height: 15),
                  _buildTransactionSection('Transfers', transfers),
                  // Additional space for the button to avoid overlapping content
                ],
              );
            }
          },
        ),
      ),
    );
  }

  double calculateActualBalance(List<Transfer> transfers) {
    return transfers.fold(0, (double sum, Transfer transfer) {
      return sum + transfer.money;
    });
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
            physics:
                NeverScrollableScrollPhysics(), // Prevents the ListView from scrolling
            itemCount: transfers.length,
            itemBuilder: (context, index) {
              final transfer = transfers[index];

              return FutureBuilder<String>(
                future: GetcategoryName(transfer.categoryId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    final categoryName = snapshot.data;

                    return Column(
                      children: [
                        ListTile(
                          title: Text(
                            '${transfer.date.day}-${transfer.date.month}-${transfer.date.year}'
                            '  Category: $categoryName'
                            '  Memo: ${transfer.memo}',
                            style: TextStyle(
                                fontSize: 16), // Adjust the font size as needed
                          ),
                          trailing: Text(
                            '${transfer.money}',
                            style: TextStyle(
                              fontSize: 16, // Adjust the font size as needed
                              color: transfer.money < 0
                                  ? Colors.red
                                  : Colors.green,
                            ),
                          ),
                        ),
                        if (index < transfers.length - 1) Divider(),
                      ],
                    );
                  }
                },
              );
            },
          ),
      ],
    );
  }

  Widget _buildBalanceSection(double actualBalance) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Balance Summary',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Text('Balance : $actualBalance'),
        ],
      ),
    );
  }
}
