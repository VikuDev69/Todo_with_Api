// ignore_for_file: prefer_const_constructors

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddTodoPage extends StatefulWidget {
  final Map? todo;
  const AddTodoPage({super.key, this.todo});

  @override
  State<AddTodoPage> createState() => _AddTodoPageState();
}

class _AddTodoPageState extends State<AddTodoPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  bool isEdit = false;
  @override
  void initState() {
    super.initState();
    final todo = widget.todo;
    if (todo != null) {
      isEdit = true;
      final title = todo['title'];
      final description = todo['description'];
      _titleController.text = title;
      _descController.text = description;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.deepPurple.shade200,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.deepPurple.shade500,
          title: Text(
            isEdit ? "Edit Note" : "Add Todo",
            style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 24,
                color: Colors.white60),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          // ignore: prefer_const_literals_to_create_immutables
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(hintText: "Tittle"),
            ),
            SizedBox(
              height: 20,
            ),
            TextField(
              controller: _descController,
              decoration: InputDecoration(hintText: "Description"),
              keyboardType: TextInputType.multiline,
              minLines: 5,
              maxLines: 8,
            ),
            SizedBox(
              height: 20,
            ),
            ElevatedButton(
                onPressed: () {
                  isEdit ? UpdateData() : submitData();
                },
                child: Text(isEdit ? "Update" : "Add"))
          ],
        ));
  }

  Future<void> UpdateData() async {
    final todo = widget.todo;
    if (todo == null) {
      print("You can not update todo with empty data");
      return;
    }

    final id = todo['_id'];
    final isCompleted = todo['is_completed'];

    // get data from form
    final title = _titleController.text;
    final description = _descController.text;
    final body = {
      "title": title,
      "description": description,
      "is_completed": isCompleted
    };

    // and Then Will submit to server
    final url = 'https://api.nstack.in/v1/todos/$id';
    final uri = Uri.parse(url);
    final response = await http.put(uri,
        body: jsonEncode(body), headers: {'Content-Type': "application/json"});
    if (response.statusCode == 200) {
      showSuccessMessage('Updated Successfully');
    } else {
      showErrorMessage('Updation Error');
    }
  }

  Future<void> submitData() async {
    // get data from form

    final title = _titleController.text;
    final description = _descController.text;
    final body = {
      "title": title,
      "description": description,
      "is_completed": false
    };

    // and Then Will submit to server
    final url = 'https://api.nstack.in/v1/todos';
    final uri = Uri.parse(url);
    final response = await http.post(uri,
        body: jsonEncode(body), headers: {'Content-Type': "application/json"});
    if (response.statusCode == 201) {
      _titleController.text = "";
      _descController.text = "";
      showSuccessMessage('Created Successfully');
    } else {
      showErrorMessage('Creation Error');
    }
  }

  // also a Success of Failing msg will be Shown
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
