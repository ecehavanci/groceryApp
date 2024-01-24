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
  bool _isLoading = true;
  String? error;

  @override
  void initState() {
    _loadItems();
    super.initState();
  }

  Future<void> _loadItems() async {
    final url = Uri.https(
        "shoppinglist-27c60-default-rtdb.firebaseio.com", "list.json");
    try {
      final response = await http.get(url);
      print(response.body);

      if (response.statusCode >= 400) {
        setState(() {
          error = "Failed to fetch data please try again.";
        });
      }

      if (response.body == "null") {
        //backend specific empty data
        setState(() {
          _isLoading = false;
        });
        return;
      }

      Map<String, dynamic> listData = jsonDecode(response.body);
      List<GroceryItem> loadedItems = [];

      for (final item in listData.entries) {
        final category = categories.entries
            .firstWhere(
                (catItem) => catItem.value.category == item.value["category"])
            .value;

        loadedItems.add(
          GroceryItem(
            id: item.key,
            name: item.value["name"],
            quantity: item.value["quantity"],
            category: category,
          ),
        );
      }

      setState(() {
        _groceryList = loadedItems;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
      });
    }
  }

  Future<void> _addItem() async {
    final newItem = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
        builder: (context) => const NewItem(),
      ),
    );

    if (newItem != null) {
      setState(() {
        _groceryList.add(newItem);
        _isLoading = false;
      });
    } else {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget showContent = const Center(
      child: Text("No items here.."),
    );

    if (_isLoading) {
      showContent = const Center(
        child: CircularProgressIndicator(),
      );
    } else {
      if (_groceryList.isNotEmpty) {
        showContent = ListView.builder(
          itemCount: _groceryList.length,
          itemBuilder: (context, index) => Dismissible(
            key: UniqueKey(),
            onDismissed: (direction) {
              _removeItem(_groceryList[index]);
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
        );
      }
    }

    if (error != null) {
      showContent = Center(
        child: Text(error!),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Categories"),
        actions: [IconButton(onPressed: _addItem, icon: const Icon(Icons.add))],
      ),
      body: showContent,
    );
  }

  Future<void> _removeItem(GroceryItem item) async {
    int index = _groceryList.indexOf(item);

    setState(() {
      _groceryList.remove(item);
    });

    final url = Uri.https("shoppinglist-27c60-default-rtdb.firebaseio.com",
        "list/${item.id}.json");
    final res = await http.delete(url);

    if (res.statusCode >= 400) {
      setState(() {
        _groceryList.insert(index, item);
      });
    }
  }
}
