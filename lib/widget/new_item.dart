import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shopping_app/data/categories.dart';
import 'package:shopping_app/model/category.dart';
import 'package:http/http.dart' as http;

class NewItem extends StatefulWidget {
  const NewItem({super.key});

  @override
  State<NewItem> createState() => _NewItemState();
}

class _NewItemState extends State<NewItem> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _enteredName = '';
  int _enteredQuantity = 1;
  var _selectedCategory = categories[Categories.vegetables];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add new item"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(label: Text("Name")),
                initialValue: _enteredName,
                maxLines: 1,
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      value.trim().length == 1 ||
                      value.trim().length > 50) {
                    return 'Must be between 1 and 50';
                  }
                  return null;
                },
                onSaved: (newValue) {
                  _enteredName = newValue!;
                },
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: _enteredQuantity.toString(),
                      keyboardType: TextInputType.number,
                      decoration:
                          const InputDecoration(label: Text("Quantity")),
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            int.tryParse(value) == null ||
                            int.tryParse(value)! >= 50) {
                          return 'Must be between 1 and 50';
                        }
                        return null;
                      },
                      onSaved: (newValue) {
                        _enteredQuantity = int.parse(newValue!);
                      },
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: DropdownButtonFormField(
                      value: _selectedCategory,
                      items: [
                        for (final category in categories.entries)
                          DropdownMenuItem(
                            value: category.value,
                            child: Row(
                              children: [
                                Container(
                                  color: category.value.color,
                                  width: 25,
                                  height: 25,
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Text(category.value.category)
                              ],
                            ),
                          )
                      ],
                      onChanged: ((value) {
                        setState(() {
                          _selectedCategory = value!;
                        });
                      }),
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 12,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: _reset, child: const Text("Reset")),
                  ElevatedButton(
                      onPressed: _saveItem, child: const Text("Add Item"))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  void _reset() {
    _formKey.currentState!.reset();
  }

  Future<void> _saveItem() async {
    bool isValidated = _formKey.currentState!.validate();
    if (isValidated) {
      _formKey.currentState!.save();

      final url = Uri.https(
          "shoppinglist-27c60-default-rtdb.firebaseio.com", "list.json");
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(
          {
            "name": _enteredName,
            "quantity": _enteredQuantity,
            "category": _selectedCategory!.category
          },
        ),
      );

      print(response.body);

      print(response.statusCode);
      if (!context.mounted) {
        return;
      }
      Navigator.of(context).pop();
    }
  }
}
