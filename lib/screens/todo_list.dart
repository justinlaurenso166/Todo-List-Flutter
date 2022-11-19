// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:todo_list/screens/add_page.dart';
import 'package:http/http.dart' as http;
import 'package:todo_list/screens/history.dart';
import 'package:todo_list/services/todo_service.dart';
import 'package:todo_list/widget/todo_card_stful.dart';
import '../utils/snackbar_helpers.dart';

class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
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
        drawer: Drawer(
          child: ListView(
            children: [
              const DrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.black26,
                  ),
                  child: Center(
                    child: Text(
                      "TODO LIST",
                      style: TextStyle(
                        fontSize: 30,
                        letterSpacing: 5,
                        color: Color.fromRGBO(255, 212, 1, 1),
                      ),
                    ),
                  )),
              ListTile(
                leading: const Icon(Icons.history),
                title: const Text(
                  'History',
                  style: TextStyle(fontSize: 20),
                ),
                onTap: () {
                  // Update the state of the app
                  final route = MaterialPageRoute(
                    builder: (context) => History(),
                  );
                  Navigator.pop(context);
                  Navigator.push(context, route);
                  // Then close the drawer
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text(
                  'Settings',
                  style: TextStyle(fontSize: 20),
                ),
                onTap: () {
                  // Update the state of the app
                  // ...
                  // Then close the drawer
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
        appBar: AppBar(
          title: const Text(
            "TODO LIST APP",
            style: TextStyle(
                color: Color.fromRGBO(255, 212, 1, 1),
                fontFamily: 'BreeSerif',
                letterSpacing: 1.5),
          ),
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
                    const Text("No Task Available",
                      style: TextStyle(fontSize: 20, letterSpacing: 2))
                ],
              )),
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index] as Map;
                  final id = item['_id'] as String;
                  return TodoCard(
                    id: id,
                    index: index,
                    item: item,
                    navigateEdit: navigateToEditPage,
                    deleteById: deleteById,
                  );
                },
              ),
            ),
          ),
          child: const Center(child: CircularProgressIndicator()),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            navigateToAddPage();
          },
          backgroundColor: const Color.fromRGBO(255, 212, 1, 1),
          label: const Icon(Icons.add, size: 25.0),
        ));
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

  Future<void> navigateToHistory() async {
    final route = MaterialPageRoute(
      builder: (context) => History(),
    );
    await Navigator.push(context, route);
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
      final filtered = items.where((element) => element['_id'] != id).toList();
      setState(() {
        items = filtered;
      });
      showSuccessMessage(context, message: "Delete Success");
    } else {
      showErrorMessage(context, message: "Delete fail");
    }
  }

  Future<void> fetchTodo() async {
    final response = await TodoService.fetchTodos();
    if (response != null) {
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
