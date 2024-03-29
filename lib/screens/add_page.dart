// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:http/http.dart' as http;
import 'package:todo_list/screens/splash_screen.dart';
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
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  final List<int> _priorities = [2, 1, 0];
  late int _priority = _priorities[0];
  // List items = [];

  bool isEdit = false;
  bool isLoading = true;
  bool _validateTask = false;
  bool _validateDesc = false;
  
  DateTime _date = DateTime.now();
  final DateFormat _dateFormatter = DateFormat("yyyy-MM-dd HH:mm");
  String? isoDate;

   // Store the TextField value in here
  Map get body {
    final todo = titleController.text;
    final description = descriptionController.text;
    final priority = _priority;
    return {
      "todo": todo,
      "description": description,
      "status": false,
      "priority": priority,
      "date": isoDate ?? "",
    };
  }

  @override
  void initState() {
    super.initState();
    final todo = widget.todo;
    if (todo != null) {
      isEdit = true;
      final title = todo['todo'];
      final description = todo['description'];
      final date = todo['date'];
      final priority = todo['priority'];
      titleController.text = title;
      descriptionController.text = description;
      isoDate = date;
      _priority = priority;

      var parsedDate = DateTime.parse(todo['date']);
      _dateController.text =
          "${parsedDate.toString().substring(0, 10)} ${parsedDate.toString().substring(11, 16)}";
    } else {
      String nowDate = _date.toString();
      DateTime nt = DateTime.parse(nowDate);

      final convertToUTC = DateTime.utc(
          nt.year, nt.month, nt.day, nt.hour, nt.minute, nt.second);
      final iso = convertToUTC.toIso8601String();
      isoDate = iso;
    }
  }

  _handleDatePicker() async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      final time = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(_date),
          builder: (BuildContext context, child) {
            return MediaQuery(
              data:
                  MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
              child: child ?? Container(),
            );
          });
      String oldDateStr = _dateFormatter.format(date).substring(0, 10);
      List firstSplit = time.toString().split("TimeOfDay");
      List secondSplit = firstSplit[1].toString().split("(");
      List thirdSplit = secondSplit[1].toString().split(")");
      String oldTimeStr = thirdSplit[0].toString();

      String newDate = ("$oldDateStr $oldTimeStr:00.000");
      DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm');
      DateTime nt = DateTime.parse(newDate);

      final convertToUTC = DateTime.utc(
          nt.year, nt.month, nt.day, nt.hour, nt.minute, nt.second);
      final iso = convertToUTC.toIso8601String();
      isoDate = iso;

      // return time;
      setState(() {
        _date = nt;
      });
      _dateController.text = formatter.format(nt);
    }
    {
      _date = DateTime.now();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEdit ? "Edit Todo" : "Add Todo",
          style: const TextStyle(
            fontFamily: 'Airbnb',
          ),
        ),
      ),
      body: Form(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'Task Name',
                hintText: 'Enter Task',
                errorText: _validateTask ? 'Task Can\'t Be Empty' : null,
                labelStyle: const TextStyle(fontSize: 18.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            TextFormField(
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: 'Task Description',
                hintText: 'Enter Task Description',
                errorText: _validateDesc ? 'Desc Can\'t Be Empty' : null,
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
              items: _priorities.map((int priority) {
                return DropdownMenuItem(
                  value: priority,
                  child: Text(
                    priority == 2
                        ? "LOW"
                        : priority == 1
                            ? "MEDIUM"
                            : "HIGH",
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
                  _priority = value!;
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
                labelText: "Select Date",
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
              onPressed: () {
                //check the title and description is empty or not
                setState(() {
                  titleController.text.isEmpty
                      ? _validateTask = true
                      : _validateTask = false;
                  descriptionController.text.isEmpty
                      ? _validateDesc = true
                      : _validateDesc = false;
                });
                if (!_validateDesc && !_validateTask && isEdit) {
                  updateData();
                } else if (!_validateDesc && !_validateTask && !isEdit) {
                  submitData();
                } else {
                  null;
                }
              },
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
      ),
    );
  }

  // Navigate To TodoList Page
  navigateToDoPage() async {
    var duration = const Duration(seconds: 3);
    return Timer(duration, () {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) {
        return const TodoListPage();
      }));
    });
  }

  // Update the data to database
  Future<void> updateData() async {
    final todo = widget.todo;
    if (todo == null) {
      print("you can not call updated without todo data");
      return;
    }
    final id = todo['id'];
    final response = await TodoService.updateTodo(id, body);

    if (response) {
      showSuccessMessage(context, message: 'Update Success');
      navigateToDoPage();
    } else {
      showErrorMessage(context, message: 'Update Failed');
    }
  }

  navigateToSplashScreen() {
    final route = MaterialPageRoute(
      builder: (context) => const SplashScreen(type: "submit",),
    );
    Navigator.push(context, route);
  }

  // Submit data to database
  Future<void> submitData() async {
    // Get the data from form
    print(body);
    final response = await TodoService.addTodo(body);
    // Show success or fail message based on status
    if (response) {
      titleController.text = '';
      descriptionController.text = '';
      _dateController.text = '';
      _priority = _priorities[0];
      // showSuccessMessage(context, message: 'Success');
      navigateToSplashScreen();
    } else {
      showErrorMessage(context, message: 'Failed');
    }
  }
}
