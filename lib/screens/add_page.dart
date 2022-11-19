// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:http/http.dart' as http;
import 'package:todo_list/screens/todo_list.dart';
import 'package:todo_list/services/todo_service.dart';
import 'package:intl/intl.dart';

import '../utils/snackbar_helpers.dart';
import 'history.dart';

class AddTodoPage extends StatefulWidget {
  final Map? todo;
  const AddTodoPage({super.key, this.todo});

  @override
  State<AddTodoPage> createState() => _AddTodoPageState();
}

class _AddTodoPageState extends State<AddTodoPage> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  bool isEdit = false;
  final List<String> _priorities = ['Low', 'Medium', 'High'];
  late String _priority = _priorities[0];
  DateTime _date = DateTime.now();
  final TextEditingController _dateController = TextEditingController();
  final DateFormat _dateFormatter = DateFormat('MMM dd, yyyy');
  bool isLoading = true;
  List items = [];

  @override
  void initState() {
    super.initState();
    final todo = widget.todo;
    if (todo != null) {
      isEdit = true;
      final title = todo['title'];
      final description = todo['description'];
      // final date = todo['date'];
      // final priority = todo['priority'];
      titleController.text = title;
      descriptionController.text = description;
      // _dateController.text = date;
      // _priority = priority;
    }
  }

  _handleDatePicker() async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date != null && date != _date) {
      setState(() {
        _date = date;
      });
      _dateController.text = _dateFormatter.format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? "Edit Todo" : "Add Todo"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: titleController,
            decoration: InputDecoration(
              labelText: 'Task Name',
              hintText: 'Enter Task',
              labelStyle: const TextStyle(fontSize: 18.0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          TextField(
            controller: descriptionController,
            decoration: InputDecoration(
              labelText: 'Task Description',
              hintText: 'Enter Task Description',
              labelStyle: const TextStyle(fontSize: 18.0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            keyboardType: TextInputType.multiline,
            minLines: 5,
            maxLines: 8,
          ),
          const SizedBox(
            height: 20,
          ),
          DropdownButtonFormField(
            isDense: true,
            icon: const Icon(Icons.arrow_drop_down_circle),
            iconSize: 22.0,
            iconEnabledColor: Theme.of(context).primaryColor,
            items: _priorities.map((String priority) {
              return DropdownMenuItem(
                value: priority,
                child: Text(
                  priority,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                  ),
                ),
              );
            }).toList(),
            style: const TextStyle(fontSize: 18.0),
            decoration: InputDecoration(
              labelText: 'Priority',
              labelStyle: const TextStyle(fontSize: 18.0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            validator: (input) =>
                // ignore: unnecessary_null_comparison
                _priority == null ? 'Please select a priority level' : null,
            onChanged: (value) {
              setState(() {
                _priority = value.toString();
              });
            },
            value: _priority,
          ),
          const SizedBox(
            height: 20,
          ),
          TextFormField(
            readOnly: true,
            controller: _dateController,
            style: const TextStyle(fontSize: 18.0),
            onTap: _handleDatePicker,
            decoration: InputDecoration(
              labelText: 'Date',
              labelStyle: const TextStyle(fontSize: 18.0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          ElevatedButton(
            onPressed: !isEdit ? submitData : updateData,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromRGBO(255, 212, 1, 1),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                !isEdit ? "Submit" : "Update",
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> updateData() async {
    final todo = widget.todo;
    if (todo == null) {
      print("you can not call updated without todo data");
      return;
    }
    final id = todo['_id'];
    final response = await TodoService.updateTodo(id, body);

    if (response) {
      showSuccessMessage(context, message: 'Update Success');
    } else {
      showErrorMessage(context, message: 'Update Failed');
    }
  }

  Future<void> submitData() async {
    // Get the data from form
    print(body);
    final response = await TodoService.addTodo(body);
    // // Show success or fail message based on status
    if (response) {
      titleController.text = '';
      descriptionController.text = '';
      showSuccessMessage(context, message: 'Success');
    } else {
      showErrorMessage(context, message: 'Failed');
    }
  }

  Map get body {
    final title = titleController.text;
    final description = descriptionController.text;
    final date = _dateController.text;
    final priority = _priority;
    return {
      "title": title,
      "description": description,
      "is_completed": false,
      "priority": priority,
      "date": date,
    };
  }
}
