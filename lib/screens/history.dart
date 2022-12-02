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
          style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 66, 66, 66)),
          child: const Icon(Icons.arrow_back_outlined),
          ),
          title: const Text(
            "History",
            style: TextStyle(
                fontFamily: 'Airbnb',
            ) ,
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
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            if(items.isNotEmpty)...[
                FloatingActionButton.extended(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) => _buildPopupDialog(context),
                      );
                  },
                  backgroundColor: const Color.fromARGB(255, 243, 97, 87),
                  label: const Icon(Icons.delete_forever, size: 25.0, color: Colors.white,),
                )
            ]
          ],
        )
      );
  }

  Widget _buildPopupDialog(
    BuildContext context) {
  return AlertDialog(
    title: const Text("Are you sure want to clear the history ?"),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const <Widget>[
        Text("This action cannot be undone."),
      ],
    ),
    actions: <Widget>[
      ElevatedButton(
        onPressed: () {
          clearAllHistory();
          Navigator.of(context).pop();
        },
        child: const Text('Yes'),
      ),
      ElevatedButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
        child: const Text('No'),
      ),
    ],
  );
}

  Future<void> navigateToTodo() async {
    final route = MaterialPageRoute(
      builder: (context) => const TodoListPage(),
    );
    await Navigator.push(context, route);
    setState(() {
      isLoading = true;
    });
    fetchTodo();
  }

  Future<void> clearAllHistory() async {
      final isCleared = await TodoService.clearAllHistory();

      if(isCleared){
        fetchTodo();
      }
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
