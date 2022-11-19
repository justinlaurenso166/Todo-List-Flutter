import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:todo_list/screens/todo_list.dart';

import '../services/todo_service.dart';
import '../utils/snackbar_helpers.dart';
import 'add_page.dart';


class History extends StatefulWidget {
  const History({super.key});
  

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  bool isLoading = true;
  List items = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("History"),
      ),
      body: Center(
        child: Text("Ini adalah page history"),
      ),
    );
  }
}