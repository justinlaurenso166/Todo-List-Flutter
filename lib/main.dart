import 'package:flutter/material.dart';
import 'package:todo_list/screens/splash_screen.dart';
import 'package:todo_list/screens/todo_list.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

void main() {
  tz.initializeTimeZones();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Flutter Todo List",
      debugShowCheckedModeBanner: false,
      theme: ThemeClass.darkTheme,
      home: const SplashScreen(),
    );
  }
}

//Make dark theme
class ThemeClass {
  static ThemeData darkTheme = ThemeData.dark().copyWith(
    textTheme: ThemeData.dark().textTheme.apply(
      fontFamily: 'Airbnb',
    ),
    primaryTextTheme: ThemeData.dark().textTheme.apply(
      fontFamily: 'Airbnb',
    ),
    splashColor: Colors.transparent,
  );
}
