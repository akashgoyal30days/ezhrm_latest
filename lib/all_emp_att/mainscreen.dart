import 'package:ezhrm/all_emp_att/check_out.dart';
import 'package:ezhrm/all_emp_att/check_in.dart';
import 'package:ezhrm/services/shared_preferences_singleton.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../login.dart';

class MainScr extends StatefulWidget {
  const MainScr({Key key}) : super(key: key);

  @override
  _MainScrState createState() => _MainScrState();
}

class _MainScrState extends State<MainScr> {
  void showDialog() {
    showCupertinoDialog(
      context: context,
      builder: (context) {
        return Theme(
          data: ThemeData.dark(),
          child: CupertinoAlertDialog(
            title: const Text('Log Out'),
            content: const Text('Are You Sure You Want To Log Out?'),
            actions: <Widget>[
              CupertinoDialogAction(
                isDefaultAction: true,
                child: const Text('Yes'),
                onPressed: () {
                  // Navigator.of(context).pop();
                  logOut(context);
                },
              ),
              CupertinoDialogAction(
                child: const Text("No"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          ),
        );
      },
    );
  }

  Future logOut(BuildContext context) async {
    SharedPreferencesInstance.logOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const Login(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Spacer(),
            Center(
                child: Text(
              'Welcome',
              style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width / 10,
                  fontWeight: FontWeight.w600),
            )),
            Center(
                child: Text(
              'to',
              style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width / 10,
                  fontWeight: FontWeight.w600),
            )),
            Center(
                child: Text(
              'Attendance Center',
              style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width / 10,
                  fontWeight: FontWeight.w600),
            )),
            const SizedBox(
              height: 70,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  height: MediaQuery.of(context).size.height / 15,
                  width: MediaQuery.of(context).size.width / 2.3,
                  color: Colors.blue.withOpacity(0.6),
                  child: RaisedButton(
                    elevation: 0,
                    color: Colors.transparent,
                    onPressed: () {
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (context) {
                        return const MainScrChckIn();
                      }));
                    },
                    child: Text(
                      "Check In Sheet",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: MediaQuery.of(context).size.width / 20),
                    ),
                  ),
                ),
                Container(
                  height: MediaQuery.of(context).size.height / 15,
                  width: MediaQuery.of(context).size.width / 2.3,
                  color: Colors.red.withOpacity(0.6),
                  child: RaisedButton(
                    elevation: 0,
                    color: Colors.transparent,
                    onPressed: () {
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (context) {
                        return const MainScrChckOut();
                      }));
                    },
                    child: Text(
                      "Check Out Sheet",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: MediaQuery.of(context).size.width / 20),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  height: MediaQuery.of(context).size.height / 15,
                  width: MediaQuery.of(context).size.width / 2.3,
                  color: Colors.red.withOpacity(0.6),
                  child: RaisedButton(
                    elevation: 0,
                    color: Colors.transparent,
                    onPressed: () {
                      showDialog();
                    },
                    child: Text(
                      "Log Out",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: MediaQuery.of(context).size.width / 20),
                    ),
                  ),
                ),
              ],
            ),
            const Spacer()
          ],
        ));
  }
}
