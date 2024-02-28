import 'package:flutter/material.dart';
import 'package:mywallet/models/category.dart';
import 'package:mywallet/services/database_service.dart';

class CategoryFormPage extends StatefulWidget {
  const CategoryFormPage({Key? key, this.category}) : super(key: key);
  final Category? category;

  @override
  _CategoryFormPageState createState() => _CategoryFormPageState();
}

class _CategoryFormPageState extends State<CategoryFormPage> {
  final TextEditingController _nameController = TextEditingController();
  final DatabaseService _databaseService = DatabaseService();

  @override
  void initState() {
    super.initState();
    // If category is provided, populate the text controller with existing data
    if (widget.category != null) {
      _nameController.text = widget.category!.name;
    }
  }

  Future<void> _onSave() async {
    final name = _nameController.text;

    if (widget.category != null) {
      // If category is provided, it's an edit operation
      await _databaseService
          .updateCategory(Category(id: widget.category!.id, name: name));
    } else {
      // If category is not provided, it's an add operation
      await _databaseService.insertCategory(Category(name: name));
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
        title: Text(
            widget.category != null ? 'Edit Category' : 'Add a new Category'),
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
                hintText: 'Enter name of the Category here',
              ),
            ),
            SizedBox(height: 16.0),
            SizedBox(
              height: 45.0,
              child: ElevatedButton(
                onPressed: _onSave,
                child: Text(
                  widget.category != null
                      ? 'Update Category'
                      : 'Save the Category',
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
