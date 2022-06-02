import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:getwidget/components/loader/gf_loader.dart';
import 'package:getwidget/types/gf_loader_type.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:http/http.dart' as http;

import 'constants.dart';
import 'custom_text_field.dart';
import 'login.dart';
import 'services/shared_preferences_singleton.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({Key key}) : super(key: key);

  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen>
    with SingleTickerProviderStateMixin<ChangePasswordScreen> {
  final cpassController = TextEditingController();
  final newpassController = TextEditingController();
  final cnfNewpassController = TextEditingController();
  var data;
  List userData;
  String name;
  String email;
  String avatar;

  var internet = 'yes';
  void mping() async {
    if (debug == 'yes') {
      //print("The statement 'this machine is connected to the Internet' is: ");
      //print(await DataConnectionChecker().hasConnection);

      // returns a bool

      // We can also get an enum instead of a bool
      //print( "Current status: ${await DataConnectionChecker().connectionStatus}");
      // prints either DataConnectionStatus.connected
      // or DataConnectionStatus.disconnected

      // This returns the last results from the last call
      // to either hasConnection or connectionStatus
      //print("Last results: ${DataConnectionChecker().lastTryResults}");
    }
    // actively listen for status updates
    var listener = DataConnectionChecker().onStatusChange.listen((status) {
      switch (status) {
        case DataConnectionStatus.connected:
          //print('Data connection is available.');
          // OverlayScreen().pop();
          setState(() {
            internet = 'yes';
          });
          break;
        case DataConnectionStatus.disconnected:
          //print('You are disconnected from the internet.');
          //   OverlayScreen().show(context, identifier: 'custom2');
          showTopSnackBar(
              context,
              const CustomSnackBar.error(
                message: 'No / slow internet',
              ));
          setState(() {
            internet = 'no';
          });
          break;
      }
    });
    await Future.delayed(const Duration(seconds: 5));
    await listener.cancel();
  }

  @override
  void initState() {
    super.initState();
    getEmails();
  }

  String btnstate = '';
  void showRetry() {
    showCupertinoDialog(
      context: context,
      builder: (context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: Theme(
            data: ThemeData.dark(),
            child: CupertinoAlertDialog(
              title: Column(
                children: const [
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    'Network Issues, Try again after sometime',
                    style: TextStyle(),
                  ),
                ],
              ),
              content: const Text('Please Retry'),
              actions: <Widget>[
                CupertinoDialogAction(
                  isDefaultAction: true,
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  load() {
    if (btnstate == 'hide') {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            titlePadding: const EdgeInsets.fromLTRB(0, 2, 0, 0),
            backgroundColor: Colors.transparent,
            elevation: 80,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0))),
            title: Center(
                child: Column(
              children: const [
                GFLoader(
                  type: GFLoaderType.android,
                  size: 50,
                  loaderColorOne: Colors.black,
                )
              ],
            )),
          );
        },
      );
    }
  }

  Future getEmails() async {
    setState(() {
      email = SharedPreferencesInstance.getString('email');
      name = SharedPreferencesInstance.getString('username');
      avatar = SharedPreferencesInstance.getString('profile');
    });
    if (debug == 'yes') {
      //print(name);
      //print(email);
    }
  }

  Future cpass() async {
    cnfNewpassController.clear();
    try {
      var uri = "$customurl/controller/process/app/extras.php";
      final response = await http.post(uri, body: {
        'uid': SharedPreferencesInstance.getString('uid'),
        'cid': SharedPreferencesInstance.getString('comp_id'),
        'new_pwd': newpassController.text,
        'c_pwd': cpassController.text,
        'type': 'change_password'
      }, headers: <String, String>{
        'Accept': 'application/json',
      });
      data = json.decode(response.body);
      userData = data["data"];
      if (data['status'] == true) {
        cpassController.clear();
        newpassController.clear();
        SharedPreferencesInstance.logOut();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const Login(),
          ),
        );
        Fluttertoast.showToast(
            msg: "Password Changed Successfully, Relogin",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 20000,
            backgroundColor: Colors.black,
            textColor: Colors.white,
            fontSize: 16.0);
      } else if (data['status'] == false) {
        Fluttertoast.showToast(
            msg: data['msg'],
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 20000,
            backgroundColor: Colors.black,
            textColor: Colors.white,
            fontSize: 16.0);
      }
      if (debug == 'yes') {
        //debugPrint(data.toString());
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          "Something went wrong, please retry",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
        ),
        duration: Duration(seconds: 1),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Change Password',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.indigo,
                Colors.blue[600],
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextField(
                hint: "Current Password",
                controller: cpassController,
                isPassword: true,
                textInputType: TextInputType.visiblePassword,
              ),
              CustomTextField(
                hint: "New Password",
                controller: newpassController,
                isPassword: true,
                textInputType: TextInputType.visiblePassword,
              ),
              CustomTextField(
                hint: "Confirm New Password",
                controller: cnfNewpassController,
                isPassword: true,
                textInputType: TextInputType.visiblePassword,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () {
                    if (newpassController.text.isEmpty ||
                        newpassController.text.isEmpty ||
                        cpassController.text.isEmpty) return;
                    if (newpassController.text == cnfNewpassController.text &&
                        newpassController.text != cpassController.text) {
                      cpass();
                    } else if (newpassController.text !=
                        cnfNewpassController.text) {
                      Fluttertoast.showToast(
                          msg:
                              "Confirm Password And New Password Doesn't Matched",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.CENTER,
                          timeInSecForIosWeb: 20000,
                          backgroundColor: Colors.black,
                          textColor: Colors.white,
                          fontSize: 16.0);
                    } else if (newpassController.text == cpassController.text) {
                      Fluttertoast.showToast(
                          msg:
                              "New Password And Current Password Should Not Be Same",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.CENTER,
                          timeInSecForIosWeb: 20000,
                          backgroundColor: Colors.black,
                          textColor: Colors.white,
                          fontSize: 16.0);
                    }
                    setState(() {});
                  },
                  child: const Text("Change Password"),
                  style: ButtonStyle(
                    padding:
                        MaterialStateProperty.all(const EdgeInsets.all(15)),
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10))),
                    backgroundColor: MaterialStateProperty.all(
                      const Color(0xff072a99),
                    ),
                    elevation: MaterialStateProperty.all(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      // bottomNavigationBar: CustomBottomNavigationBar(),
    );
  }
}
