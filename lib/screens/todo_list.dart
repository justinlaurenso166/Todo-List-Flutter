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
  List<String> dropDown = <String>[
    "Default",
    "A-Z",
    "Z-A",
    "LOW-HIGH",
    "HIGH-LOW"
  ];

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
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
        appBar: AppBar(
            title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "TODO LIST APP",
              style: TextStyle(
                  color: Color.fromRGBO(255, 212, 1, 1),
                  fontFamily: 'Airbnb',
                  letterSpacing: 1.5),
            ),
            Theme(
                data: ThemeData(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                ),
                child: DropdownButton(
                  underline: Container(),
                  icon: const Icon(
                    Icons.sort,
                    color: Colors.white,
                  ),
                  // value: selectedValue,
                  items: dropDown.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (Object? value) {
                    var sortResult;
                    setState(() {
                      isLoading = true;
                      if (value == "A-Z") {
                        items.sort((a, b) {
                          return a['todo']
                              .toLowerCase()
                              .compareTo(b['todo'].toLowerCase());
                        });
                        isLoading = false;
                      } else if (value == "Z-A") {
                        items.sort((a, b) {
                          return b['todo']
                              .toLowerCase()
                              .compareTo(a['todo'].toLowerCase());
                        });
                        print(items);
                        isLoading = false;
                      } else if (value == "LOW-HIGH") {
                        items.sort((a, b) {
                          return b['priority'].compareTo(a['priority']);
                        });
                        isLoading = false;
                      } else if (value == "HIGH-LOW") {
                        items.sort((a, b) {
                          return a['priority'].compareTo(b['priority']);
                        });
                        isLoading = false;
                      } else {
                        fetchTodo();
                      }
                    });
                  },
                )),
          ],
        )),
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
                  final id = item['id'] as String;
                  return TodoCard(
                    id: id,
                    index: index,
                    item: item,
                    navigateEdit: navigateToEditPage,
                    deleteById: deleteById,
                    fetchTodo: fetchTodo,
                    page: "Todo",
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
            FloatingActionButton.extended(
              heroTag: 'add',
              onPressed: () {
                navigateToAddPage();
              },
              backgroundColor: const Color.fromRGBO(255, 212, 1, 1),
              label: const Icon(Icons.add, size: 25.0),
            ),
            const Padding(padding: EdgeInsets.fromLTRB(0, 10, 0, 10)),
            if(items.isNotEmpty)...[
              FloatingActionButton.extended(
                heroTag: 'delete',
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) => _buildPopupDialog(context),
                  );
                },
                backgroundColor: const Color.fromARGB(255, 243, 97, 87),
                label: const Icon(
                  Icons.delete_forever,
                  size: 25.0,
                  color: Colors.white,
                ),
              )
            ],
          ],
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
    final response = await TodoService.fetchTodos();
    if (response != null) {
      // print(response);
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

    Future<void> clearAllTask() async {
      final isCleared = await TodoService.clearAllTask();

      if(isCleared){
        fetchTodo();
      }
  }

  Widget _buildPopupDialog(
    BuildContext context) {
  return AlertDialog(
    title: const Text("Are you sure want to clear all the task ?"),
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
          clearAllTask();
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

}
