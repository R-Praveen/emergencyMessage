import 'dart:async';
import 'dart:convert';

import 'package:contacts_service/contacts_service.dart';
import 'package:emergency_message/constants.dart';
import 'package:emergency_message/local_notification_service.dart';
import 'package:emergency_message/work_manager_utils.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
// import 'package:hardware_buttons/hardware_buttons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:volume_watcher/volume_watcher.dart';

class HomeBloc {
  final controller = StreamController<List>();
  final showMessage = StreamController<String>();
  final showConfirm = StreamController<String>();
  late StreamSubscription volumeButtonSubscription;
  late SharedPreferences preferences;
  HomeBloc() {
    initDetails();
  }
  Future initDetails() async {
    preferences = await SharedPreferences.getInstance();
    final contacts = getContactsFromLocal();
    controller.add(contacts);
  }

  List getContactsFromLocal() {
    final contacts = preferences.getString(contactsKey);
    if (contacts?.isNotEmpty ?? false) {
      final value = jsonDecode(contacts ?? '');
      return value;
    }
    return [];
  }

  void addContact(Contact? contact) {
    List contacts;
    contacts = getContactsFromLocal();
    if (contacts.length == 4) {
      showMessage.add("Maximum limit is 4 contacts only.");
      return;
    }
    if (contacts.isNotEmpty) {
      contacts.add(
        {
          "phone_no": contact!.phones![0].value as String,
          "name": contact.displayName,
        },
      );
    } else {
      contacts = [
        {
          "phone_no": contact!.phones![0].value as String,
          "name": contact.displayName,
        },
      ];
    }
    controller.add(contacts);
    saveToPref(contacts);
  }

  Future saveToPref(List contacts) async {
    preferences.setString(contactsKey, jsonEncode(contacts));
  }

  Future onConfirm() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        showMessage.add(
            'Please enable location to send your location to the contacts add');
        return;
      }
    }
    showMessage.add(
      "Volume Up long press will trigger emergency message successfully from now",
    );
    // await registerTask();
    VolumeWatcher.addListener(() {
      debugPrint('');
    });
    await LocalNotificationService().showNotification(
      '',
      LocalNotificationService.selfTemperatureAndroidNotificationID,
      title: "Location Shared!!!",
      subTitle: "You location shared with your contacts successfully",
    );
  }
}
