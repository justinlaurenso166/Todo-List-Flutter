import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:intl/intl.dart';

class PopUpWidget extends StatefulWidget {
  final Map item;
  final Function changeStatusComplete;
  final Function changeStatusNotComplete;
  final String page;
  final String status;
  final Function deleteById;
  final String id;
  const PopUpWidget({
    super.key,
    required this.changeStatusComplete,
    required this.changeStatusNotComplete,
    required this.item,
    required this.page,
    required this.status,
    required this.deleteById,
    required this.id,
  });

  @override
  State<PopUpWidget> createState() => _PopUpWidgetState();
}

class _PopUpWidgetState extends State<PopUpWidget> {
  @override
  Widget build(BuildContext context) {
    Map item = widget.item;
    var parsedDate = DateTime.parse(item['date']);
    return widget.status == "change"
        ? AlertDialog(
            title: Text(widget.page == 'Todo'
                ? 'Are you done with this task ?'
                : 'Are you sure want to undone this task ?'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text("Task Name : ${widget.item['todo']}"),
              ],
            ),
            actions: <Widget>[
              ElevatedButton(
                onPressed: () {
                  widget.page == "History"
                      ? widget.changeStatusNotComplete()
                      : widget.changeStatusComplete();
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
          )
        : AlertDialog(
            title: const Text('Are you sure want to delete this task ?'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text("Task Name : ${item['todo']}"),
                Text("Description : ${item['description']}"),
                Text(
                    "Date : ${changeFormat(parsedDate)} ${parsedDate.hour}:${formatMinute((parsedDate.minute).toString())}"),
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
                  widget.deleteById(widget.id);
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

  changeFormat(date) {
    return DateFormat("MMMEd").format(date);
  }

  formatMinute(String minute) {
    if (minute.length <= 1) {
      minute = "0$minute";
    } else {
      minute = minute;
    }
    return minute;
  }
}
