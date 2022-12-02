import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/material.dart';
import 'package:todo_list/screens/history.dart';

class DrawerWidget extends StatefulWidget {
  const DrawerWidget({super.key});

  @override
  State<DrawerWidget> createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
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
                leading: const Icon(Icons.exit_to_app),
                title: const Text(
                  'Exit',
                  style: TextStyle(fontSize: 20),
                ),
                onTap: () {
                    SystemNavigator.pop();
                },
              ),
            ],
          ),
      );
  }
}