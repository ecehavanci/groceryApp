import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shopping_app/data/categories.dart';
import 'package:shopping_app/model/grocery_item.dart';
import 'package:shopping_app/widget/new_item.dart';
import 'package:http/http.dart' as http;

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> _groceryList = [];

  @override
  void initState() {
    _loadItems();
    super.initState();
  }

  Future<void> _loadItems() async {
    final url = Uri.https(
        "shoppinglist-27c60-default-rtdb.firebaseio.com", "list.json");
    final response = await http.get(url);
    print(response.body);

    Map<String, dynamic> listData = jsonDecode(response.body);
    List<GroceryItem> _loadedItems = [];

    for (final item in listData.entries) {
      final category = categories.entries
          .firstWhere(
              (catItem) => catItem.value.category == item.value["category"])
          .value;

      _loadedItems.add(
        GroceryItem(
          id: item.key,
          name: item.value["name"],
          quantity: item.value["quantity"],
          category: category,
        ),
      );
    }

    setState(() {
      _groceryList = _loadedItems;
    });
  }

  Future<void> _addItem() async {
    await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
        builder: (context) => const NewItem(),
      ),
    );

    _loadItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Categories"),
        actions: [IconButton(onPressed: _addItem, icon: const Icon(Icons.add))],
      ),
      body: _groceryList.isEmpty
          ? const Center(
              child: Text("No items here.."),
            )
          : ListView.builder(
              itemCount: _groceryList.length,
              itemBuilder: (context, index) => Dismissible(
                key: UniqueKey(),
                onDismissed: (direction) {
                  _removeItem(index);
                },
                child: ListTile(
                  leading: Container(
                      height: 25,
                      width: 25,
                      color: _groceryList[index].category.color),
                  title: Text(_groceryList[index].name),
                  trailing: Text(_groceryList[index].quantity.toString()),
                ),
              ),
            ),
    );
  }

  bool _removeItem(int index) => _groceryList.remove(_groceryList[index]);
}
