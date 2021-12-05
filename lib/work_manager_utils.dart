import 'package:emergency_message/home_bloc.dart';
import 'package:emergency_message/sms_utils.dart';
import 'package:workmanager/workmanager.dart';

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    switch (task) {
      case 'ListenToVolumeUpLongPress':
        final contacts = HomeBloc().getContactsFromLocal();
        send(
          "Please check my location",
          contacts.map((e) => e as String).toList(),
        );
        break;
      default:
        break;
    }
    return Future.value(true);
  });
}

Future registerTask() async {
  await Workmanager().registerOneOffTask(
    'listenVolume',
    'ListenToVolumeUpLongPress',
  );
}
