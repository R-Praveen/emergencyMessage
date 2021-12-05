import 'package:emergency_message/local_notification_service.dart';
import 'package:emergency_message/pages/home_page.dart';
import 'package:emergency_message/work_manager_utils.dart';
import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: true,
  );
  await LocalNotificationService().init();

  runApp(const MyApp());
}

void onSelectNotification(String? payload) async {
  debugPrint('');
  if (payload?.isNotEmpty ?? false) {
    debugPrint('notification payload: $payload');
  }
  // await Navigator.push(
  //   context,
  //   MaterialPageRoute<void>(builder: (context) => SecondScreen(payload)),
  // );
}

void onDidReceiveLocalNotification(
    int value, String? value1, String? value2, String? value3) {
  debugPrint('');
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
