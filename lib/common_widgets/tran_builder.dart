import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mywallet/models/transfer.dart';
import 'package:mywallet/services/database_service.dart';

class TranBuilder extends StatelessWidget {
  const TranBuilder({
    Key? key,
    required this.future,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  final Future<List<Transfer>> future;
  final Function(Transfer) onEdit;
  final Function(Transfer) onDelete;

  Future<String> getAccountName(int id) async {
    final DatabaseService _databaseService = DatabaseService();
    final account = await _databaseService.accountOne(id);
    return account.name;
  }

  Future<String> getCategorytName(int id) async {
    final DatabaseService _databaseService = DatabaseService();
    final category = await _databaseService.categoryOne(id);
    return category.name;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Transfer>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final tran = snapshot.data![index];
              return _buildTranCard(tran, context);
            },
          ),
        );
      },
    );
  }

  Widget _buildTranCard(Transfer tran, BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Container(
              height: 40.0,
              width: 40.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[200],
              ),
              alignment: Alignment.center,
              child: FaIcon(FontAwesomeIcons.dog, size: 18.0),
            ),
            SizedBox(width: 20.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Money: ${tran.money.toString()} ',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4.0),
                  FutureBuilder<String>(
                    future: getAccountName(tran.accountId),
                    builder: (context, snapshot) {
                      return Text(
                        'Account: ${snapshot.data}',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 4.0),
                  FutureBuilder<String>(
                    future: getCategorytName(tran.categoryId),
                    builder: (context, snapshot) {
                      return Text(
                        'Category: ${snapshot.data}',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 4.0),
                  Text(
                    'Date: ${tran.date.year.toString() + "-" + tran.date.month.toString() + "-" + tran.date.day.toString()} ',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4.0),
                  Text(
                    'Memo: ${tran.memo} ',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 20.0),
            GestureDetector(
              onTap: () => onEdit(tran),
              child: Container(
                height: 40.0,
                width: 40.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[200],
                ),
                alignment: Alignment.center,
                child: Icon(Icons.edit, color: Colors.orange[800]),
              ),
            ),
            SizedBox(width: 20.0),
            GestureDetector(
              onTap: () => onDelete(tran),
              child: Container(
                height: 40.0,
                width: 40.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[200],
                ),
                alignment: Alignment.center,
                child: Icon(Icons.delete, color: Colors.red[800]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
