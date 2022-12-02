import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/standalone.dart' as tz;
import 'package:intl/intl.dart';

class NotificationsServices {
  final jkt = tz.getLocation('Asia/Jakarta');

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final AndroidInitializationSettings _androidInitializationSettings =
      const AndroidInitializationSettings('app_icon');

  void initialiseNotification() async {
    InitializationSettings initializationSettings = InitializationSettings(
      android: _androidInitializationSettings,
    );

    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void scheduleNotification(int id, String title, String body, String date) async {
    AndroidNotificationDetails androidNotificationDetails =
        const AndroidNotificationDetails(
      'channelId',
      'channelName',
      importance: Importance.max,
      priority: Priority.max,
      enableVibration: true,
    );

    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
    );

    DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    DateTime nt = DateTime.parse(date);
    date = formatter.format(nt);

    // ignore: no_leading_underscores_for_local_identifiers
    tz.TZDateTime _convertTime(String date) {
    var scheduleDate = tz.TZDateTime.parse(tz.local,date);

    return scheduleDate;
  }

  // for debug
  // print(_convertTime(date));
  print("set");

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      _convertTime(date),
      notificationDetails,
      androidAllowWhileIdle: true,
    uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime
    );
  }

  void cancelNotification(int id) async{
    print("cancel");
    await _flutterLocalNotificationsPlugin.cancel(id);
  }
  
}
