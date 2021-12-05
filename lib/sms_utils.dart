import 'package:flutter/material.dart';
import 'package:flutter_sms/flutter_sms.dart';

Future send(
  String message,
  List<String> recipients,
) async {
  await sendSMS(message: message, recipients: recipients).catchError((onError) {
    debugPrint(onError);
  });
}
