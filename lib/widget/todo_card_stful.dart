import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:todo_list/utils/snackbar_helpers.dart';

class TodoCard extends StatefulWidget {
  final int index;
  final Map item;
  final Function(Map) navigateEdit;
  final Function(String) deleteById;
  final String id;
  const TodoCard(
      {super.key,
      required this.index,
      required this.item,
      required this.navigateEdit,
      required this.deleteById,
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

    return Card(
      child: ListTile(
        leading: CircleAvatar(backgroundColor: const Color.fromRGBO(255, 212, 1, 1),child: Text('${index + 1}'),),
        title: Text(widget.item['title'], style: const TextStyle(fontSize: 20),),
        subtitle: Text(item['description'], style: const TextStyle(fontSize: 15),),
        trailing: PopupMenuButton(onSelected: (value) {
          if (value == 'edit') {
            //open edit
            widget.navigateEdit(item);
          } else if (value == 'delete') {
            //open delete
            showDialog(
              context: context,
              builder: (BuildContext context) => _buildPopupDialogDelete(context, id, widget.deleteById, item),
            );
          }
        }, itemBuilder: (context) {
          return [
            const PopupMenuItem(
              value: 'edit',
              child: Text('Edit'),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Text('Delete'),
            ),
          ];
        }),
        onTap: () {
          showDialog(
            context: context,
            builder: (BuildContext context) => _buildPopupDialog(context, item, changeStatus),
          );
        },
      ),
    );
  }

  void changeStatus(){
    setState(() {
      widget.item['is_completed'] = !widget.item['is_completed'];
    });
    showSuccessMessage(context, message: "Task is completed");
  }
}

Widget _buildPopupDialog(BuildContext context, Map item, Function changeStatus) {
  return AlertDialog(
    title: const Text('Are you finished with this task ?'),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(item['title']),
      ],
    ),
    actions: <Widget>[
      ElevatedButton(
        onPressed: () {
          changeStatus();
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

Widget _buildPopupDialogDelete(BuildContext context, String id, Function deleteById, Map item){
  return AlertDialog(
    title: const Text('Are you sure want to delete this task ?'),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text("Title : " + item['title']),
        Text("Description : " + item['title']),
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