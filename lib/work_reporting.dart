import 'dart:developer';

import 'package:ezhrm/services/shared_preferences_singleton.dart';
import 'package:ezhrm/upload_csr.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'constants.dart';
import 'drawer.dart';

class WorkReporting extends StatefulWidget {
  const WorkReporting({Key key}) : super(key: key);

  @override
  _WorkReportingState createState() => _WorkReportingState();
}

class _WorkReportingState extends State<WorkReporting>
    with SingleTickerProviderStateMixin<WorkReporting> {
  bool visible = false;
  Map data;
  Map datanew;
  Map userData;
  List userDatanew;
  String _mylist;
  String _mycredit;
  String username;
  String email;
  String ppic;
  String ppic2;
  String uid;
  String cid;
  String todaysplan;
  String todayscompletedwork;
  String nextdayplaning;
  TextEditingController todaycompleteworkcontroller = TextEditingController();
  TextEditingController nextdayplaningcontroller = TextEditingController();

  bool istodaycompletedwork_readonly = true;
  bool isnextdayplaning_readonly = true;

  var newdata;
  var internet = 'yes';

  @override
  void initState() {
    super.initState();
    fetch_today_workreport();
  }

  showLoaderDialogwithName(BuildContext context, String message) {
    AlertDialog alert = AlertDialog(
      contentPadding: const EdgeInsets.all(15),
      content: Row(
        children: [
          const CircularProgressIndicator(color: themecolor),
          Container(
              margin: const EdgeInsets.only(left: 25),
              child: Text(
                message,
                style: const TextStyle(
                    fontWeight: FontWeight.w500, color: themecolor),
              )),
        ],
      ),
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future fetch_today_workreport() async {
    try {
      var uri = "$customurl/controller/process/app/user_task.php";
      final response = await http.post(uri, body: {
        'uid': SharedPreferencesInstance.getString('uid'),
        'cid': SharedPreferencesInstance.getString('comp_id'),
        'type': 'work_report'
      }, headers: <String, String>{
        'Accept': 'application/json',
      });
      var rsp = jsonDecode(response.body);
      if (rsp.containsKey("status")) {
        if (rsp["status"].toString() == "true") {
          userData = rsp;
          todayscompletedwork = userData["today_work"];
          nextdayplaning = userData["tomorrow_plan"];
          todaysplan = userData["today_plan"];

          todaycompleteworkcontroller.text = todayscompletedwork;
          nextdayplaningcontroller.text = nextdayplaning;

          setState(() {});
        } else {
          userData = {};
          setState(() {
            
          });
        }
      }
    } catch (error) {
      log(error.toString());
    }
  }

  Future submit_work() async {
    try {
      var uri = "$customurl/controller/process/app/user_task.php";
      final response = await http.post(uri, body: {
        'uid': SharedPreferencesInstance.getString('uid'),
        'cid': SharedPreferencesInstance.getString('comp_id'),
        'type': 'add_work',
        "work": todaycompleteworkcontroller.text,
        "plan": nextdayplaningcontroller.text,
      }, headers: <String, String>{
        'Accept': 'application/json',
      });
      var rsp = jsonDecode(response.body);
      log(rsp.toString());
      if (rsp.containsKey("status")) {
        if (rsp["status"].toString() == "true") {
          Navigator.pop(context);
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const WorkReporting()));
        }
      }
    } catch (error) {
      log(error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CustomDrawer(
          currentScreen: AvailableDrawerScreens.WorkReporting),
      appBar: AppBar(
        backgroundColor: Colors.blue,
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
        elevation: 0,
        title: const Text(
          "Work Reporting",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: userData == null
          ? const Center(
              child: GFLoader(
              type: GFLoaderType.custom,
              child: SizedBox(
                width: 60,
                height: 60,
                child: Image(
                  image: AssetImage('assets/newlod.gif'),
                  height: 100,
                  width: 100,
                ),
              ),
            ))
          : Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.white, Colors.white],
                ),
              ),
              child: userData.isEmpty
                  ? const Center(
                      child: Text(
                        'No Data Found',
                        style: TextStyle(
                            fontFamily: font1,
                            fontSize: 22,
                            fontWeight: FontWeight.w400,
                            color: Colors.black),
                      ),
                    )
                  : ListView(
                      children: [
                        const SizedBox(
                          height: 5,
                        ),
                        const Padding(
                          padding: EdgeInsets.only(
                              top: 10, bottom: 10, left: 20, right: 20),
                          child: Text(
                            "Todays Plan Work",
                            style: TextStyle(
                                color: themecolor,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: TextField(
                            readOnly: true,
                            decoration: InputDecoration(
                                hintText: todaysplan ?? "",
                                border: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius: BorderRadius.circular(10)),
                                filled: true,
                                fillColor: Colors.blue.shade50),
                            minLines: 12,
                            maxLines: 15,
                          ),
                        ),
                        const Divider(
                          thickness: 10,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 20, right: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Today Completed Work",
                                style: TextStyle(
                                    color: themecolor,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              ),
                              istodaycompletedwork_readonly == true
                                  ? RaisedButton(
                                      textColor: Colors.white,
                                      color: Colors.blue,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      onPressed: () {
                                        istodaycompletedwork_readonly = false;
                                        setState(() {});
                                      },
                                      child: const Text("Edit"),
                                    )
                                  : RaisedButton(
                                      textColor: Colors.white,
                                      color: Colors.blue,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      onPressed: () {
                                        istodaycompletedwork_readonly = true;
                                        setState(() {});
                                      },
                                      child: const Text("Done"),
                                    )
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: TextField(
                            controller: todaycompleteworkcontroller,
                            readOnly: istodaycompletedwork_readonly,
                            decoration: InputDecoration(
                                hintText: todayscompletedwork ?? "",
                                border: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius: BorderRadius.circular(10)),
                                filled: true,
                                fillColor: Colors.blue.shade50),
                            minLines: 12,
                            maxLines: 15,
                          ),
                        ),
                        const Divider(
                          thickness: 10,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 20, right: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Next Day Planning",
                                style: TextStyle(
                                    color: themecolor,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              ),
                              isnextdayplaning_readonly == true
                                  ? RaisedButton(
                                      textColor: Colors.white,
                                      color: Colors.blue,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      onPressed: () {
                                        isnextdayplaning_readonly = false;
                                        setState(() {});
                                      },
                                      child: const Text("Edit"),
                                    )
                                  : RaisedButton(
                                      textColor: Colors.white,
                                      color: Colors.blue,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      onPressed: () {
                                        isnextdayplaning_readonly = true;
                                        setState(() {});
                                      },
                                      child: const Text("Done"),
                                    )
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: TextField(
                            controller: nextdayplaningcontroller,
                            readOnly: isnextdayplaning_readonly,
                            decoration: InputDecoration(
                                hintText: nextdayplaning ?? "",
                                border: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius: BorderRadius.circular(10)),
                                filled: true,
                                fillColor: Colors.blue.shade50),
                            minLines: 12,
                            maxLines: 15,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: RaisedButton(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5)),
                              color: themecolor,
                              child: const Text(
                                "Submit",
                                style: TextStyle(color: Colors.white),
                              ),
                              onPressed: () {
                                submit_work();
                                showLoaderDialogwithName(
                                    context, "please wait..");
                              }),
                        )
                      ],
                    ),
            ),
    );
  }
}
