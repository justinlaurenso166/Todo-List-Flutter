import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:intl/intl.dart';
import 'package:todo_list/utils/snackbar_helpers.dart';

import '../services/todo_service.dart';

class TodoCard extends StatefulWidget {
  final int index;
  final Map item;
  final Function(Map) navigateEdit;
  final Function(String) deleteById;
  final Function fetchTodo;
  final String id;
  final String page;
  const TodoCard(
      {super.key,
      required this.index,
      required this.item,
      required this.navigateEdit,
      required this.deleteById,
      required this.fetchTodo,
      required this.page,
      required this.id});

  @override
  State<TodoCard> createState() => _TodoCardState();
}

class _TodoCardState extends State<TodoCard> {
  @override
  Widget build(BuildContext context) {
    int index = widget.index;
    Map item = widget.item;
    String id = widget.id;
    DateTime date = DateTime.parse(item['date']);

    return Card(
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: item['priority'] == 1
                  ? const Color.fromRGBO(255, 212, 1, 1)
                  : item['priority'] == 0
                      ? Colors.redAccent
                      : Colors.green,
              // backgroundColor: const Color.fromRGBO(255, 212, 1, 1),
              child:
                  Text(
                  item['priority'] == 1
                  ? "M"
                  : item['priority'] == 0
                      ? "H"
                      : "L",
                    style: const TextStyle(color: Colors.black),
                  ),
              //     Text(
              //   "${index + 1}",
              //   style: const TextStyle(color: Colors.black),
              // ),
            ),
            title: Text(
              widget.item['todo'],
              style: const TextStyle(fontSize: 20),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['description'],
                  style: const TextStyle(fontSize: 15),
                ),
              ],
            ),
            trailing: PopupMenuButton(onSelected: (value) {
              if (value == 'edit') {
                //open edit
                widget.navigateEdit(item);
              } else if (value == 'delete') {
                //open delete
                showDialog(
                  context: context,
                  builder: (BuildContext context) => _buildPopupDialogDelete(
                      context, id, widget.deleteById, item),
                );
              }
            }, itemBuilder: (context) {
              return widget.page == "Todo"
                  ? [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Text('Edit'),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete'),
                      ),
                    ]
                  : [
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete'),
                      ),
                    ];
            }),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) => _buildPopupDialog(
                    context,
                    item,
                    changeStatusComplete,
                    changeStatusNotComplete,
                    widget.page),
              );
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Text(
                "${changeFormat(date)} ${date.hour}:${date.minute}"
              ),
              const SizedBox(
                width: 10,
              ),
              Text(
                item['status'] == false ? "Not Complete" : "Complete",
                style: TextStyle(
                    color: item["status"] == false
                        ? Color.fromARGB(255, 243, 97, 87)
                        : Colors.greenAccent),
              ),
              const SizedBox(width: 10),
            ],
          ),
          const SizedBox(
            height: 10,
          )
        ],
      ),
    );
  }

  changeFormat(date){
    return DateFormat("MMMEd").format(date);
  }

  Future<void> updateData() async {
    final todo = widget.item;
    if (todo == null) {
      print("You can not call updated without todo data");
      return;
    }
    final id = todo['id'];
    final response = await TodoService.updateTodo(id, todo);

    if (response) {
      widget.fetchTodo();
    }
  }

  void changeStatusComplete() {
    setState(() {
      widget.item['status'] = true;
    });
    // print(widget.item);
    updateData();
  }

  void changeStatusNotComplete() {
    setState(() {
      widget.item['status'] = false;
    });
    // print(widget.item);
    updateData();
  }
}

Widget _buildPopupDialog(
    BuildContext context,
    Map item,
    Function changeStatusComplete,
    Function changeStatusNotComplete,
    String page) {
  return AlertDialog(
    title: Text(page == 'Todo'
        ? 'Are you done with this task ?'
        : 'Are you sure want to undone this task ?'),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(item['todo']),
      ],
    ),
    actions: <Widget>[
      ElevatedButton(
        onPressed: () {
          page == "History"
              ? changeStatusNotComplete()
              : changeStatusComplete();
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

Widget _buildPopupDialogDelete(
    BuildContext context, String id, Function deleteById, Map item) {
  var parsedDate = DateTime.parse(item['date']);
  return AlertDialog(
    title: const Text('Are you sure want to delete this task ?'),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text("Title : ${item['todo']}"),
        Text("Description : ${item['description']}"),
        Text(
            "Date : ${parsedDate.toString().substring(0, 10)} ${parsedDate.toString().substring(11, 16)}"),
        Row(
          children: [
            const Text(
              "Status : ",
            ),
            Text(
              item['status'] == false ? "Not Complete" : "Complete",
              style: TextStyle(
                  color: item["status"] == false
                      ? const Color.fromARGB(255, 243, 97, 87)
                      : Colors.greenAccent),
            ),
          ],
        )
      ],
    ),
    actions: <Widget>[
      ElevatedButton(
        onPressed: () {
          deleteById(id);
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
