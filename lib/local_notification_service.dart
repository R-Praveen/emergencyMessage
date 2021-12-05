import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationService {
  static final LocalNotificationService _notificationService =
      LocalNotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  factory LocalNotificationService() {
    return _notificationService;
  }

  LocalNotificationService._internal();

  static const channelID = "EMERGENCY";
  static const selfTemperatureAndroidNotificationID = 921;

  Future<void> init() async {
    final NotificationAppLaunchDetails? notificationAppLaunchDetails =
        await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
    if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
      final payload = notificationAppLaunchDetails!.payload;
      selectNotification(payload);
    }

    const AndroidInitializationSettings? initializationSettingsAndroid =
        AndroidInitializationSettings(
      'emergency',
    );
    final IOSInitializationSettings? initializationSettingsIOS =
        IOSInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
      onDidReceiveLocalNotification: onDidReceiveLocalNotification,
    );
    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: selectNotification);
  }

  Future selectNotification(String? payload) async {}

  void onDidReceiveLocalNotification(
      int a, String? b, String? c, String? d) async {}

  Future showNotification(
    String notificationMessage,
    int id, {
    String title = "EMERGENCY",
    String subTitle = '',
  }) async {
    if (Platform.isIOS) await checkPermission();
    await flutterLocalNotificationsPlugin.cancel(id);
    try {
      await flutterLocalNotificationsPlugin.show(
        id,
        title,
        notificationMessage,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channelID,
            "Emergency",
            subText: subTitle,
          ),
          iOS: IOSNotificationDetails(
            subtitle: subTitle,
          ), //IOS Notification details
        ),
        payload: 'DeepLinkType.selfTemperatureLog',
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future checkPermission() async {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }
}
