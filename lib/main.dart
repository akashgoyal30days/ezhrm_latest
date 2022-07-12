import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:package_info/package_info.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_foreground_plugin/flutter_foreground_plugin.dart';

import 'goGreen_Global.dart';
import 'splash_screen.dart';
import 'services/shared_preferences_singleton.dart';

GoGreenModel goGreenModel;
var datak;
final PageController pageController = PageController(initialPage: 0);
int currentIndex = 0;
String location, token, version, packagename, val, buildNumber;
final List<CameraDescription> cameras = [];

/// Create a [AndroidNotificationChannel] for heads up notifications
const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', // title
  'This channel is used for important notifications.', // description
  sound: RawResourceAndroidNotificationSound('pop'),
  importance: Importance.max,
  playSound: true,
  enableLights: true,
);

/// Initialize the [FlutterLocalNotificationsPlugin] package.
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() => runApp(const Main());

class Main extends StatelessWidget {
  const Main({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {},
      home: SplashScreen(),
    );
  }
}

initializeApp() async {
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  cameras.addAll(await availableCameras());
  await SharedPreferencesInstance.initialize();
  FlutterForegroundPlugin.stopForegroundService();
  SharedPreferencesInstance.instance.remove('reqatt');

  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  version = packageInfo.version;
  packagename = packageInfo.packageName;
  buildNumber = packageInfo.buildNumber;

  if (!SharedPreferencesInstance.isUserLoggedIn) return;
  await GoGreenGlobal.initialize();
  if (!SharedPreferencesInstance.isUserLoggedIn) return;
  goGreenModel = GoGreenModel(
    backgroundLocationInterval: int.parse(datak['time'].toString()),
    canSendRequest: datak["req_attendance"].toString() == "1",
    locationEnabled: datak["attendance_location"].toString() == "1",
    faceRecognitionEnabled: datak["face_recog"].toString() == "1",
    backgroundLocationTrackingEnabled: datak["loc_track"].toString() == "1",
    companyLogo: datak["comp_logo"],
    companyName: datak["comp_name"],
    debugEnable: datak["debug_enable"].toString() == "true",
    showUpdateAvailableDialog: datak['code'].toString() == "1009",
  );

}
