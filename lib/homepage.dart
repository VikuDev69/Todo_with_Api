import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:todo_with_api/add_tod0.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isLoading = true;
  List items = [];

  @override
  void initState() {
    super.initState();
    fetchTodo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.deepPurple.shade200,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.deepPurple.shade500,
          title: const Text(
            "Todo",
            style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 24,
                color: Colors.white60),
          ),
          centerTitle: true,
        ),
        body: Visibility(
          visible: isLoading,
          replacement: RefreshIndicator(
            onRefresh: fetchTodo,
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index] as Map;
                final id = item['_id'] as String;
                return Card(
                  margin: const EdgeInsets.all(15),
                  child: ListTile(
                    tileColor: Colors.deepPurple.shade100,
                    splashColor: Colors.deepPurple,
                    title: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Text(
                        item['title'],
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w600),
                      ),
                    ),
                    subtitle: Text(
                      item['description'],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                            onPressed: () {
                              navigateToEditPage(item);
                            },
                            icon: const Icon(
                              Icons.edit,
                              color: Colors.deepPurple,
                            )),
                        IconButton(
                            onPressed: () {
                              deletedById(id);
                            },
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.red,
                            )),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          child: const Center(
              child: CircularProgressIndicator(
            color: Colors.white,
          )),
        ),
        floatingActionButton: FloatingActionButton(
          tooltip: "Add",
          splashColor: Colors.deepPurple,
          onPressed: () => navigateToAddPage(),
          child: const Icon(
            Icons.add,
            size: 30,
          ),
        ));
  }

  // Go To Add Page
  Future<void> navigateToAddPage() async {
    final rout = MaterialPageRoute(
      builder: (context) => AddTodoPage(),
    );
    await Navigator.push(context, rout);
    setState(() {
      isLoading = true;
    });
    fetchTodo();
  }

  //Go To Edit page
  Future<void> navigateToEditPage(Map item) async {
    final rout = MaterialPageRoute(
      builder: (context) => AddTodoPage(todo: item),
    );
    Navigator.push(context, rout);
    setState(() {
      isLoading = true;
    });
    fetchTodo();
  }

  // Delete Todo
  Future<void> deletedById(String id) async {
    //1 we will Delete The Item from server
    final url = "https://api.nstack.in/v1/todos/$id";
    final uri = await Uri.parse(url);
    final response = await http.delete(uri);
    // Delete The Item From list
    if (response.statusCode == 200) {
      final filteredItem =
          items.where((element) => element['_id'] != id).toList();
      setState(() {
        items = filteredItem;
        showSuccessMessage('Todo Deleted');
      });
    } else {
      //Show Error
      showErrorMessage('Failed To Delete');
    }
  }

  // Get All Todo
  Future<void> fetchTodo() async {
    final url = "https://api.nstack.in/v1/todos?page=1&limit=10";
    final uri = await Uri.parse(url);
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map;
      final result = json['items'] as List;
      // print(response.body);
      setState(() {
        items = result;
      });
    }
    setState(() {
      isLoading = false;
    });
  }

  void showSuccessMessage(String message) {
    final snackBar =
        SnackBar(duration: Duration(seconds: 1), content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void showErrorMessage(String message) {
    final snackBar = SnackBar(
      duration: Duration(seconds: 1),
      content: Text(
        message,
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.red,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
