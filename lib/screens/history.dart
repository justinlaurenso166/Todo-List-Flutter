// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:todo_list/screens/add_page.dart';
import 'package:http/http.dart' as http;
import 'package:todo_list/screens/history.dart';
import 'package:todo_list/screens/todo_list.dart';
import 'package:todo_list/services/todo_service.dart';
import 'package:todo_list/widget/todo_card_stful.dart';
import '../utils/snackbar_helpers.dart';

class History extends StatefulWidget {
  const History({super.key});

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
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
        appBar: AppBar(
          leading: ElevatedButton(
            onPressed: () { navigateToTodo(); },
          child: Icon(Icons.arrow_back_outlined),
          style: ElevatedButton.styleFrom(backgroundColor: Color.fromARGB(255, 66, 66, 66)),
          ),
          title: const Text(
            "History",
          ),
          automaticallyImplyLeading: false,
        ),
        body: Visibility(
          visible: isLoading,
          replacement: RefreshIndicator(
            onRefresh: fetchTodo,
            child: Visibility(
              visible: items.isNotEmpty,
              replacement: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  // ignore: prefer_const_literals_to_create_immutables
                  children: [
                    const Image(
                      image: AssetImage("assets/images/NoData.png"),
                    ),
                    const Text("No Task Completed",
                      style: TextStyle(fontSize: 20, letterSpacing: 2))
                ],
              )),
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index] as Map;
                  final id = item['id'] as String;
                  return TodoCard(
                    id: id,
                    index: index,
                    item: item,
                    navigateEdit: navigateToEditPage,
                    deleteById: deleteById,
                    fetchTodo: fetchTodo,
                    page: "History",
                  );
                },
              ),
            ),
          ),
          child: const Center(child: CircularProgressIndicator()),
        ),
      );
  }

  Future<void> navigateToTodo() async {
    final route = MaterialPageRoute(
      builder: (context) => TodoListPage(),
    );
    await Navigator.push(context, route);
    setState(() {
      isLoading = true;
    });
    fetchTodo();
  }

  Future<void> navigateToAddPage() async {
    final route = MaterialPageRoute(
      builder: (context) => AddTodoPage(),
    );
    await Navigator.push(context, route);
    setState(() {
      isLoading = true;
    });
    fetchTodo();
  }

  Future<void> navigateToEditPage(Map item) async {
    final route = MaterialPageRoute(
      builder: (context) => AddTodoPage(todo: item),
    );
    await Navigator.push(context, route);
    setState(() {
      isLoading = true;
    });
    fetchTodo();
  }

  Future<void> deleteById(String id) async {
    //Delete the task
    final isSuccess = await TodoService.deleteById((id));
    if (isSuccess) {
      final filtered = items.where((element) => element['id'] != id).toList();
      setState(() {
        items = filtered;
      });
      showSuccessMessage(context, message: "Delete Success");
    } else {
      showErrorMessage(context, message: "Delete fail");
    }
  }

  Future<void> fetchTodo() async {
    final response = await TodoService.fetchTodosCompleted();
    if (response != null) {
      print(response);
      setState(() {
        items = response;
      });
    } else {
      showErrorMessage(context, message: "Something went wrong");
    }

    setState(() {
      isLoading = false;
    });
  }
}
