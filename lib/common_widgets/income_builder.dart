import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mywallet/models/transaction.dart';
import 'package:mywallet/services/database_service.dart';

class IncomeBuilder extends StatelessWidget {
  const IncomeBuilder({
    Key? key,
    required this.future,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);
  final Future<List<Income>> future;
  final Function(Income) onEdit;
  final Function(Income) onDelete;

  Future<String> getPaymentName(int id) async {
    final DatabaseService _databaseService = DatabaseService();
    final payment = await _databaseService.payment(id);
    return payment.name;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Income>>(
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
              final income = snapshot.data![index];
              return _buildIncomeCard(income, context);
            },
          ),
        );
      },
    );
  }

  Widget _buildIncomeCard(Income income, BuildContext context) {
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
                    income.name,
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4.0),
                  FutureBuilder<String>(
                    future: getPaymentName(income.paymentId),
                    builder: (context, snapshot) {
                      return Text('Payment: ${snapshot.data}');
                    },
                  ),
                  SizedBox(height: 4.0),
                  Row(
                    children: [
                      Text('Age: ${income.age.toString()}, Color: '),
                      Container(
                        height: 15.0,
                        width: 15.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4.0),
                          color: income.color,
                          border: Border.all(
                            color: Colors.black,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: 20.0),
            GestureDetector(
              onTap: () => onEdit(income),
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
              onTap: () => onDelete(income),
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
