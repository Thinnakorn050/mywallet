import 'package:flutter/material.dart';
import 'package:mywallet/models/account.dart';
import 'package:mywallet/services/database_service.dart';

class AccountFormPage extends StatefulWidget {
  const AccountFormPage({Key? key, this.account}) : super(key: key);
  final Account? account;

  @override
  _AccountFormPageState createState() => _AccountFormPageState();
}

class _AccountFormPageState extends State<AccountFormPage> {
  final TextEditingController _nameController = TextEditingController();
  final DatabaseService _databaseService = DatabaseService();

  @override
  void initState() {
    super.initState();
    // If account is provided, populate the text controller with existing data
    if (widget.account != null) {
      _nameController.text = widget.account!.name;
    }
  }

  Future<void> _onSave() async {
    final name = _nameController.text;

    if (widget.account != null) {
      // If account is provided, it's an edit operation
      await _databaseService
          .updateAccount(Account(id: widget.account!.id, name: name));
    } else {
      // If account is not provided, it's an add operation
      await _databaseService.insertAccount(Account(name: name));
    }

    Navigator.pop(context);
  }

  Future<void> _onCancel() async {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.account != null ? 'Edit Account' : 'Add a new Account'),
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
                hintText: 'Enter name of the Account here',
              ),
            ),
            SizedBox(height: 16.0),
            SizedBox(
              height: 45.0,
              child: ElevatedButton(
                onPressed: _onSave,
                child: Text(
                  widget.account != null
                      ? 'Update Account'
                      : 'Save the Account',
                  style: TextStyle(
                    fontSize: 16.0,
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.0),
            SizedBox(
             height: 45.0,
             child: ElevatedButton(
             onPressed: _onCancel,
             style: ElevatedButton.styleFrom(
            primary: Color.fromARGB(255, 227, 25, 25), // Background color
            onPrimary: Colors.white, // Text color
    ),
    child: Text(
      'Cancel',
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
