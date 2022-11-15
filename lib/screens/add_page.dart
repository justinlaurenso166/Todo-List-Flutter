import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:http/http.dart' as http;
import 'package:todo_list/services/todo_service.dart';

import '../utils/snackbar_helpers.dart';

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

  @override
  void initState(){
    super.initState();
    final todo = widget.todo;
    if(todo != null){
      isEdit = true;
      final title = todo['title'];
      final description = todo['description'];
      titleController.text = title;
      descriptionController.text = description;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? "Edit Todo" : "Add Todo"),
      ),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          TextField(
            controller: titleController,
            decoration: InputDecoration(
              hintText: ('Title'),
            ),
          ),
          SizedBox(height: 20,),
          TextField(
            controller: descriptionController,
            decoration: InputDecoration(
              hintText: ('Placeholder'),
            ),
            keyboardType: TextInputType.multiline,
            minLines: 5,
            maxLines: 8,
          ),
          SizedBox(height: 20,),
          ElevatedButton(
            onPressed: !isEdit ? submitData : updateData,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(!isEdit ? "Submit" : "Update"),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> updateData() async{
    final todo = widget.todo;
    if(todo == null){
      print("you can not call updated without todo data");
      return;
    }
    final id = todo['_id'];
    final response = await TodoService.updateTodo(id, body);

    if(response){
      showSuccessMessage(context,message:'Update Success');
    }else{
      showErrorMessage(context, message:'Update Failed');
    }
  }

  Future<void> submitData() async{
    // Get the data from form

    final response = await TodoService.addTodo(body);
    // Show success or fail message based on status
    if(response){
      titleController.text = '';
      descriptionController.text = '';
      showSuccessMessage(context,message:'Success');
    }else{
      showErrorMessage(context, message:'Failed');
    }
  }

  Map get body {
    final title = titleController.text;
    final description = descriptionController.text;
    return {
      "title": title,
      "description": description,
      "is_completed": false,
    };
  }
  
}
