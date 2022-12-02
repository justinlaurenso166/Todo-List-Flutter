import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:todo_list/screens/todo_list.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  final String type;
  const SplashScreen({
    super.key,
    required this.type,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    startSplashScreen();
  }

  @override
  Widget build(BuildContext context) {
    return widget.type == "default"
        ? const Scaffold(
            body: Center(
              child: Image(
                image: AssetImage(
                  "assets/images/TodoList.png",
                ),
                // width: 200,
                // height: 200,
              ),
            ),
          )
        : Scaffold(
            body: Center(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              // ignore: prefer_const_literals_to_create_immutables
              children: <Widget>[
                const Image(
                  image: AssetImage(
                    "assets/images/success.png",
                  ),
                  width: 300,
                  height: 300,
                ),
                const Text(
                  "Success add a new Task",
                  style: TextStyle(
                    fontSize: 20,
                    letterSpacing: 1.2,
                  ),
                )
              ],
            )),
          );
  }

  // Show splashscreen for 3 seconds and go to TodoListPage
  startSplashScreen() async {
    var duration = const Duration(seconds: 3);
    return Timer(duration, () {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) {
        return const TodoListPage();
      }));
    });
  }
}
