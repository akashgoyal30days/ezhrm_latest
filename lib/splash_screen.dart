import 'package:ezhrm/home_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import 'main.dart' as main;
import 'login.dart';
import 'services/shared_preferences_singleton.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool showNoInternet = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    var connectivityResult = await (Connectivity().checkConnectivity());

    if (connectivityResult != ConnectivityResult.mobile &&
        connectivityResult != ConnectivityResult.wifi) {
      setState(() {
        showNoInternet = true;
      });
      return;
    }
    await main.initializeApp();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => SharedPreferencesInstance.isUserLoggedIn
            ? const HomeBottomNavigationBar()
            : const Login(),
      ),
    );
  }

  @override
  Widget build(BuildContext contxt) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.indigo,
              Colors.blue[600],
            ],
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: SizedBox.expand(
              child: Column(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Image.asset(
                          "assets/ezlogo.png",
                          scale: 4,
                        ),
                        showNoInternet
                            ? const Padding(
                                padding: EdgeInsets.symmetric(horizontal:8.0),
                                child: Text(
                                  "Please turn on your mobile data or wifi",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.white),
                                ),
                              )
                            : LoadingAnimationWidget.fourRotatingDots(
                                color: Colors.white54,
                                size: 50,
                              ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: FutureBuilder<PackageInfo>(
                        future: PackageInfo.fromPlatform(),
                        builder: ((contet, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            return Text(
                              snapshot.data.version,
                              style: const TextStyle(color: Colors.white54),
                            );
                          }
                          // Place Holder Transparent Text
                          return const Text(
                            "0.0.0",
                            style: TextStyle(color: Colors.transparent),
                          );
                        })),
                  )
                ],
              ),
            ),
          ),
        ),
      );
}
