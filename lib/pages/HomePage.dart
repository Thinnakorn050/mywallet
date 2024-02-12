import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mywallet/common_widgets/income_builder.dart';
import 'package:mywallet/common_widgets/payment_builder.dart';
import 'package:mywallet/models/transaction.dart';
import 'package:mywallet/models/account.dart';
import 'package:mywallet/pages/income_form_page.dart';
import 'package:mywallet/pages/payment_form_page.dart';
import 'package:mywallet/services/database_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DatabaseService _databaseService = DatabaseService();

  Future<List<Income>> _getIncomes() async {
    return await _databaseService.incomes();
  }

  Future<List<Payment>> _getBreeds() async {
    return await _databaseService.payments();
  }

  Future<void> _onIncomeDelete(Income income) async {
    await _databaseService.deleteIncome(income.id!);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Income Database'),
          centerTitle: true,
          bottom: TabBar(
            tabs: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text('Incomes'),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text('Payment'),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            IncomeBuilder(
              future: _getIncomes(),
              onEdit: (value) {
                {
                  Navigator.of(context)
                      .push(
                        MaterialPageRoute(
                          builder: (_) => IncomeFormPage(income: value),
                          fullscreenDialog: true,
                        ),
                      )
                      .then((_) => setState(() {}));
                }
              },
              onDelete: _onIncomeDelete,
            ),
            PaymentBuilder(
              future: _getBreeds(),
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
                        builder: (_) => PaymentFormPage(),
                        fullscreenDialog: true,
                      ),
                    )
                    .then((_) => setState(() {}));
              },
              heroTag: 'addPayment',
              child: FaIcon(FontAwesomeIcons.plus),
            ),
            SizedBox(height: 12.0),
            FloatingActionButton(
              onPressed: () {
                Navigator.of(context)
                    .push(
                      MaterialPageRoute(
                        builder: (_) => IncomeFormPage(),
                        fullscreenDialog: true,
                      ),
                    )
                    .then((_) => setState(() {}));
              },
              heroTag: 'addIncome',
              child: FaIcon(FontAwesomeIcons.paw),
            ),
          ],
        ),
      ),
    );
  }
}
