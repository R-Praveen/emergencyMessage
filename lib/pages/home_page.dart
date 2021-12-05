import 'package:contacts_service/contacts_service.dart';
import 'package:emergency_message/constants.dart';
import 'package:emergency_message/home_bloc.dart';
import 'package:emergency_message/local_notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class HomePage extends StatelessWidget {
  final homeBloc = HomeBloc();
  HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    homeBloc.showMessage.stream.listen((event) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(event),
        ),
      );
    });
    return Scaffold(
      backgroundColor: appBackgroundColor,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Link 4 contact numbers",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              const SizedBox(
                height: 30,
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () async {
                      final permissionStatus = await _askPermission();
                      if (permissionStatus == PermissionStatus.granted) {
                        _pickContact();
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          color: Colors.grey,
                          padding: const EdgeInsets.all(5),
                          child: const Icon(
                            Icons.contacts,
                            color: Colors.white,
                          ),
                        ),
                        Container(
                          color: Colors.black,
                          padding: const EdgeInsets.all(5),
                          child: Text(
                            "Contacts".toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              _getAddedContacts(),
              StreamBuilder<bool>(
                  stream: null,
                  builder: (context, snapshot) {
                    return TextButton(
                      onPressed: () async {
                        try {
                          homeBloc.onConfirm();
                        } catch (e) {
                          debugPrint(e.toString());
                        }
                      },
                      child: const Text(
                        "Confirm",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    );
                  })
            ],
          ),
        ),
      ),
    );
  }

  Widget _getAddedContacts() {
    return StreamBuilder<List>(
      stream: homeBloc.controller.stream,
      builder: (context, snapshot) {
        if (!snapshot.hasData || (snapshot.data?.isEmpty ?? true)) {
          return const SizedBox();
        }
        return Center(
          child: ListView.separated(
              shrinkWrap: true,
              primary: false,
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    title: Text(
                      snapshot.data![index]["name"] as String,
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      snapshot.data![index]["phone_no"] as String,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return const Divider();
              },
              itemCount: snapshot.data?.length ?? 0),
        );
      },
    );
  }

  Future<PermissionStatus> _askPermission() async {
    PermissionStatus permission = await Permission.contacts.status;
    if (permission != PermissionStatus.granted &&
        permission != PermissionStatus.permanentlyDenied) {
      PermissionStatus permissionStatus = await Permission.contacts.request();
      return permissionStatus;
    } else {
      return permission;
    }
  }

  Future _pickContact() async {
    final Contact? contact = await ContactsService.openDeviceContactPicker(
        iOSLocalizedLabels: iOSLocalizedLabels);
    homeBloc.addContact(contact);
  }
}
