import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/material.dart';

class TodoCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    // final id = item['_id'];
    return Card(
      child: ListTile(
        leading: CircleAvatar(child: Text('${index + 1}')),
        title: Text(item['title']),
        subtitle: Text(item['description']),
        trailing: PopupMenuButton(onSelected: (value) {
          if (value == 'edit') {
            //open edit
            navigateEdit(item);
          } else if (value == 'delete') {
            //open delete
            deleteById(id);
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
            builder: (BuildContext context) => _buildPopupDialog(context, id),
          );
        },
      ),
    );
  }
}

Widget _buildPopupDialog(BuildContext context, String id) {
  return AlertDialog(
    title: const Text('Are you finished with this task ?'),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text("$id"),
      ],
    ),
    actions: <Widget>[
      ElevatedButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: const Text('Yes'),
      ),
      ElevatedButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: const Text('No'),
        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
      ),
    ],
  );
}
