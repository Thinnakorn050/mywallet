import 'package:flutter/material.dart';
import 'package:mywallet/common_widgets/age_slider.dart';
import 'package:mywallet/common_widgets/color_picker.dart';
import 'package:mywallet/common_widgets/payment_selector.dart';
import 'package:mywallet/models/income.dart';
import 'package:mywallet/models/payment.dart';
import 'package:mywallet/services/database_service.dart';

class IncomeFormPage extends StatefulWidget {
  const IncomeFormPage({Key? key, this.income}) : super(key: key);
  final Income? income;

  @override
  _IncomeFormPageState createState() => _IncomeFormPageState();
}

class _IncomeFormPageState extends State<IncomeFormPage> {
  final TextEditingController _nameController = TextEditingController();
  static final List<Color> _colors = [
    Color(0xFF000000),
    Color(0xFFFFFFFF),
    Color(0xFF947867),
    Color(0xFFC89234),
    Color(0xFF862F07),
    Color(0xFF2F1B15),
  ];
  static final List<Payment> _payments = [];

  final DatabaseService _databaseService = DatabaseService();

  int _selectedAge = 0;
  int _selectedColor = 0;
  int _selectedBreed = 0;

  @override
  void initState() {
    super.initState();
    if (widget.income != null) {
      _nameController.text = widget.income!.name;
      _selectedAge = widget.income!.age;
      _selectedColor = _colors.indexOf(widget.income!.color);
    }
  }

  Future<List<Payment>> _getPayments() async {
    final payments = await _databaseService.payments();
    if (_payments.length == 0) _payments.addAll(payments);
    if (widget.income != null) {
      _selectedBreed =
          _payments.indexWhere((e) => e.id == widget.income!.paymentId);
    }
    return _payments;
  }

  Future<void> _onSave() async {
    final name = _nameController.text;
    final age = _selectedAge;
    final color = _colors[_selectedColor];
    final payment = _payments[_selectedBreed];

    // Add save code here
    widget.income == null
        ? await _databaseService.insertIncome(
            Income(name: name, age: age, color: color, paymentId: payment.id!),
          )
        : await _databaseService.updateIncome(
            Income(
              id: widget.income!.id,
              name: name,
              age: age,
              color: color,
              paymentId: payment.id!,
            ),
          );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Income Record'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter name of the Income here',
              ),
            ),
            SizedBox(height: 16.0),
            // Age Slider
            AgeSlider(
              max: 30.0,
              selectedAge: _selectedAge.toDouble(),
              onChanged: (value) {
                setState(() {
                  _selectedAge = value.toInt();
                });
              },
            ),
            SizedBox(height: 16.0),
            // Color Picker
            ColorPicker(
              colors: _colors,
              selectedIndex: _selectedColor,
              onChanged: (value) {
                setState(() {
                  _selectedColor = value;
                });
              },
            ),
            SizedBox(height: 24.0),
            // Breed Selector
            FutureBuilder<List<Payment>>(
              future: _getPayments(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Text("Loading payments...");
                }
                return PaymentSelector(
                  breeds: _payments.map((e) => e.name).toList(),
                  selectedIndex: _selectedBreed,
                  onChanged: (value) {
                    setState(() {
                      _selectedBreed = value;
                    });
                  },
                );
              },
            ),
            SizedBox(height: 24.0),
            SizedBox(
              height: 45.0,
              child: ElevatedButton(
                onPressed: _onSave,
                child: Text(
                  'Save the Dog data',
                  style: TextStyle(
                    fontSize: 16.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
