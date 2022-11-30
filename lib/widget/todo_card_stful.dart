import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:intl/intl.dart';
import 'package:todo_list/services/notification_services.dart';
import 'package:todo_list/utils/snackbar_helpers.dart';
import 'package:todo_list/widget/popup_widget.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
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
  NotificationsServices notificationsServices = NotificationsServices();

  @override
  void initState() {
    super.initState();
    notificationsServices.initialiseNotification();
  }

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
              child: Text(
                item['priority'] == 1
                    ? "M"
                    : item['priority'] == 0
                        ? "H"
                        : "L",
                style: const TextStyle(color: Colors.black),
              ),
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
                    builder: (BuildContext context) => PopUpWidget(
                        changeStatusComplete: changeStatusComplete,
                        changeStatusNotComplete: changeStatusNotComplete,
                        item: item,
                        page: widget.page,
                        status: "delete",
                        deleteById: widget.deleteById,
                        id: id));
              } else if (value == "notification") {
                changeStatusNotification(
                    widget.item['notification'], index, item);
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
                      if(convertTime(item['date']))...[
                        PopupMenuItem(
                            value: 'notification',
                            child: Text(!widget.item['notification']
                                ? "Set Notification"
                                : "Cancel Notification"),
                          ),
                      ],
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
                  builder: (BuildContext context) => PopUpWidget(
                      changeStatusComplete: changeStatusComplete,
                      changeStatusNotComplete: changeStatusNotComplete,
                      item: item,
                      page: widget.page,
                      status: "change",
                      deleteById: widget.deleteById,
                      id: id));
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Text(
                  "${changeFormat(date)} ${date.hour}:${formatMinute((date.minute).toString())}"),
              const SizedBox(
                width: 12,
              ),
              Text(
                item['status'] == false ? "Not Complete" : "Complete",
                style: TextStyle(
                    color: item["status"] == false
                        ? const Color.fromARGB(255, 243, 97, 87)
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

  changeFormat(date) {
    return DateFormat("MMMEd").format(date);
  }

  formatMinute(String minute) {
    if (minute.length <= 1) {
      minute = "0${minute.toString()}";
    } else {
      minute = minute.toString();
    }
    return minute;
  }

  Future<void> updateData() async {
    final todo = widget.item;
    // ignore: unnecessary_null_comparison
    if (todo.isEmpty) {
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

  bool convertTime(String date) {
      DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
      DateTime nt = DateTime.parse(widget.item['date']);
      var checkDate = formatter.format(nt);
      var status;
      if(tz.TZDateTime.parse(tz.local, checkDate).isAfter(DateTime.now())){
        status = true;
      }else{
        status = false;
      }

      return status;
    }

  void changeStatusNotification(bool notification, int index, Map item) {
    // ignore: no_leading_underscores_for_local_identifiers
      setState(() {
        widget.item['notification'] = !widget.item['notification'];
      });
      showSuccessMessage(context, message: "Successfully added a notification on this task");
      updateData();

      if (widget.item['notification']) {
        notificationsServices.scheduleNotification(
            index,
            "Reminder for your task",
            "Task Name : ${item['description']}",
            item['date']);
      } else {
        notificationsServices.cancelNotification(index);
      }
  }
}
