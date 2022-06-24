import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:geolocator/geolocator.dart';

import 'package:http/http.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_snake_navigationbar/flutter_snake_navigationbar.dart';

import 'home.dart';
import 'main.dart';
import 'drawer.dart';
import 'myprofile.dart';
import 'constants.dart';
import 'notification.dart';
import 'services/shared_preferences_singleton.dart';

class HomeBottomNavigationBar extends StatefulWidget {
  const HomeBottomNavigationBar({Key key}) : super(key: key);

  @override
  State<HomeBottomNavigationBar> createState() =>
      _HomeBottomNavigationBarState();
}

class _HomeBottomNavigationBarState extends State<HomeBottomNavigationBar> {
  final _pageController = PageController(initialPage: 0);
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final Map<String, List> fetchedNotifications = {};
  final int intervalInMicroSeconds = goGreenModel.backgroundLocationInterval;
  Timer backgroundTrackingTimer;
  StreamSubscription locationStream;
  Position currentPosition;
  int _currentPageIndex = 0;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // if (goGreenModel.backgroundLocationTrackingEnabled) {
      //   showLocationTrackingDialog();
      // }
      //if (goGreenModel.showUpdateAvailableDialog) showUpdate();
    });
  }

  void showUpdate() => showCupertinoDialog(
        context: context,
        builder: (context) {
          return WillPopScope(
            onWillPop: () async {
              Navigator.pop(context);
              return false;
            },
            child: Theme(
              data: ThemeData.light(),
              child: CupertinoAlertDialog(
                title: Column(
                  children: [
                    const SizedBox(height: 10),
                    Image.asset(
                      'assets/ezlogo.png',
                      width: 200,
                      height: 100,
                    ),
                    const Text(
                      'EZHRM',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 30,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
                content: Column(
                  children: const [
                    SizedBox(height: 20),
                    Text(
                      ' New Update available',
                      style: TextStyle(
                          fontFamily: font1,
                          fontWeight: FontWeight.w500,
                          fontSize: 25),
                    ),
                  ],
                ),
                actions: <Widget>[
                  Column(
                    children: [
                      CupertinoDialogAction(
                        isDefaultAction: true,
                        child: const Text('Update now'),
                        onPressed: () async {
                          if (await canLaunch(
                              "https://play.google.com/store/apps/details?id=com.in30days.ezhrm")) {
                            await launch(
                                "https://play.google.com/store/apps/details?id=com.in30days.ezhrm");
                          }
                        },
                      ),
                      const Divider(),
                      CupertinoDialogAction(
                        isDefaultAction: true,
                        child: const Text('Not Now'),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );

  //-------------LOCATION START API ------------------

  showLocationTrackingDialog() async {
    bool clickedOnAllow = await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const WarningDialog(),
        ) ??
        false;
    if (!clickedOnAllow) {
      SystemNavigator.pop();
      return;
    }
    checkGPSStatus();
  }

  checkGPSStatus() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      var permissions = await PermissionHandler().requestPermissions([
        PermissionGroup.locationWhenInUse,
        PermissionGroup.location,
      ]);
      if (permissions[PermissionGroup.locationWhenInUse] ==
              PermissionStatus.denied &&
          permissions[PermissionGroup.location] == PermissionStatus.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
              "Location permission is denied",
              textAlign: TextAlign.center,
            ),
            backgroundColor: Colors.red,
          ));
        }
        Navigator.pop(context);
        return;
      }
    }
    var locationEnabled = await Geolocator.isLocationServiceEnabled();
    if (!locationEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
            "Please Turn your GPS ON",
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.red,
        ));
      }
      Navigator.pop(context);
      return;
    }
    var servicestatus = await Geolocator.isLocationServiceEnabled();
    if (!servicestatus) {
      try {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
            "Please Turn your GPS ON",
            textAlign: TextAlign.center,
          ),
          duration: Duration(seconds: 10),
          backgroundColor: Colors.red,
        ));
      } catch (e) {
        //
      }
      return;
    }
    if (await Geolocator.checkPermission() == LocationPermission.denied ||
        await Geolocator.checkPermission() ==
            LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          "Please enable location permission from settings",
          textAlign: TextAlign.center,
        ),
        duration: Duration(seconds: 10),
        backgroundColor: Colors.red,
      ));
      return;
    }
    startBackgroundTracking();
  }

  Future<bool> backgroundServices() async => await FlutterBackground.initialize(
        androidConfig: const FlutterBackgroundAndroidConfig(
          notificationTitle: "Running in Background",
          notificationImportance: AndroidNotificationImportance.Max,
          notificationText: "Your Location is being updated in background",
        ),
      );

  startBackgroundTracking() async {
    await backgroundServices();
    FlutterBackground.enableBackgroundExecution();
    // location updates stream
    locationStream =
        Geolocator.getPositionStream().listen((_) => currentPosition = _);
    // background location update
    backgroundTrackingTimer = Timer.periodic(
      Duration(microseconds: intervalInMicroSeconds),
      (_) => sendBackgroundLocation(),
    );
  }

  sendBackgroundLocation() async {
    if (currentPosition == null) return;
    final response = await post(
        "$customurl/controller/process/app/location_track.php",
        body: {
          'uid': SharedPreferencesInstance.getString('uid') ?? "",
          'cid': SharedPreferencesInstance.getString('comp_id') ?? "",
          'type': 'add_loc',
          'lat': currentPosition.latitude.toString(),
          'long': currentPosition.longitude.toString(),
        },
        headers: <String, String>{
          'Accept': 'application/json',
        });
    log(response.body);
  }

  //----LOCATION API-------------------
  saveFetchedNotifications(fetchedNotifications) {
    this.fetchedNotifications.clear();
    this.fetchedNotifications.addAll(fetchedNotifications);
  }

  openDrawer() => scaffoldKey.currentState?.openDrawer();

  openUserProfileScreen() => _pageController
      .animateToPage(2,
          duration: const Duration(milliseconds: 150), curve: Curves.easeInQuad)
      .then((_) => setState(() => _currentPageIndex = 2));

  DateTime _lastPressedAt = DateTime.now();
  GlobalKey<HomePageState> homeKey = GlobalKey<HomePageState>();
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_currentPageIndex != 0) {
          await _pageController.animateToPage(0,
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeInQuad);
          setState(() => _currentPageIndex = 0);
          return false;
        }
        if (_lastPressedAt == null ||
            DateTime.now().difference(_lastPressedAt) >
                const Duration(seconds: 2)) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text(
              "Press Back Again To Exit The App",
              textAlign: TextAlign.center,
            ),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.black54,
          ));
          _lastPressedAt = DateTime.now();
          return false;
        }
        return true;
      },
      child: Scaffold(
        key: scaffoldKey,
        drawer: CustomDrawer(
            openUserProfileScreen: openUserProfileScreen,
            currentScreen: AvailableDrawerScreens.dashboard),
        body: PageView(
          controller: _pageController,
          children: [
            HomePage(
                key: homeKey,
                openDrawer: openDrawer,
                profileViewScreenOpener: openUserProfileScreen),
            NotificationsScreen(
              openDrawer: openDrawer,
              saveFetchedNotifications: saveFetchedNotifications,
              fetchedNotifications: fetchedNotifications,
            ),
            UserProfile(openDrawer: openDrawer),
          ],
        ),
        bottomNavigationBar: SnakeNavigationBar.color(
          backgroundColor: const Color(0xff072a99),
          snakeShape: SnakeShape.indicator,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white,
          snakeViewColor: Colors.blueAccent,
          showSelectedLabels: true,
          currentIndex: _currentPageIndex,
          showUnselectedLabels: true,
          onTap: (index) => _pageController
              .animateToPage(index,
                  duration: const Duration(milliseconds: 150),
                  curve: Curves.easeInQuad)
              .then((_) => setState(
                  () => _currentPageIndex = _pageController.page.toInt())),
          items: [
            BottomNavigationBarItem(
                icon: _currentPageIndex == 0
                    ? const Icon(Icons.cottage)
                    : const Icon(Icons.home),
                label: "Home"),
            BottomNavigationBarItem(
                icon: _currentPageIndex == 1
                    ? const Icon(Icons.notifications_active)
                    : const Icon(Icons.notifications),
                label: "Notifications"),
            const BottomNavigationBarItem(
                icon: Icon(Icons.person), label: "Profile"),
          ],
        ),
      ),
    );
  }

  @override
  dispose() {
    backgroundTrackingTimer?.cancel();
    locationStream?.cancel();
    FlutterBackground.disableBackgroundExecution();
    super.dispose();
  }
}

class WarningDialog extends StatelessWidget {
  const WarningDialog({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: const Text("This app collects location data to enable"),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("- Location Based Attendance Marking"),
          const Text(
            "- Employer/Company can track your live location",
            textAlign: TextAlign.left,
          ),
          const Text(
            "- To Check and approve your travel allowances even when the app is closed or not in use",
            textAlign: TextAlign.left,
          ),
          const SizedBox(height: 10),
          const Text(
            "Do you want to allow?",
            textAlign: TextAlign.left,
          ),
          RichText(
              text: TextSpan(
                  style: const TextStyle(color: Colors.black),
                  children: [
                const TextSpan(text: "Click "),
                TextSpan(
                    text: "here ",
                    style: const TextStyle(color: Colors.blue),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        launch("https://ezhrm.in/locationpolicy");
                      }),
                const TextSpan(text: "for details"),
              ])),
        ],
      ),
      actions: [
        CupertinoDialogAction(
          child: const Text("Allow"),
          onPressed: () {
            Navigator.of(context).pop(true);
          },
        ),
        const CupertinoDialogAction(
          child: Text("Exit"),
          onPressed: SystemNavigator.pop,
        ),
      ],
    );
  }
}
