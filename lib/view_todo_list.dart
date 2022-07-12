import 'dart:developer';

import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:ezhrm/services/shared_preferences_singleton.dart';
import 'package:ezhrm/upload_csr.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:getwidget/getwidget.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'dart:convert';
import 'applywfh.dart';
import 'constants.dart';
import 'drawer.dart';

class ViewTodoList extends StatefulWidget {
  const ViewTodoList({Key key}) : super(key: key);

  @override
  _ViewTodoListState createState() => _ViewTodoListState();
}

class _ViewTodoListState extends State<ViewTodoList>
    with SingleTickerProviderStateMixin<ViewTodoList> {
  bool visible = false;
  Map data;
  Map datanew;
  List userData =[];
  List userDatanew;
  String _mylist;
  String _mycredit;
  String username;
  String email;
  String ppic;
  String ppic2;
  String uid;
  String cid;
  dynamic reasonController = TextEditingController();
  var newdata;
  var internet = 'yes';

  @override
  void initState() {
    super.initState();
    fetch_todo_list();
  }

  showLoaderDialogwithName(BuildContext context, String message) {
    AlertDialog alert = AlertDialog(
      contentPadding: EdgeInsets.all(15),
      content: Row(
        children: [
          CircularProgressIndicator(color: themecolor),
          Container(
              margin: EdgeInsets.only(left: 25),
              child: Text(
                message,
                style:
                    TextStyle(fontWeight: FontWeight.w500, color: themecolor),
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

  Future fetch_todo_list() async {
    try {
      var uri = "$customurl/controller/process/app/user_task.php";
      final response = await http.post(uri, body: {
        'uid': SharedPreferencesInstance.getString('uid'),
        'cid': SharedPreferencesInstance.getString('comp_id'),
        'type': 'fetch_all_task'
      }, headers: <String, String>{
        'Accept': 'application/json',
      });
      var rsp = jsonDecode(response.body);
      // log(rsp.toString());
      if (rsp.containsKey("status")) {
        if (rsp["status"].toString() == "true") {
          userData = rsp["data"];
          setState(() {});
        }
      }
      log(userData.toString());
    } catch (error) {
      log(error.toString());
    }
  }

  Future update_todolist_status(String taskid, String status) async {
    try {
      var uri = "$customurl/controller/process/app/user_task.php";
      final response = await http.post(uri, body: {
        'uid': SharedPreferencesInstance.getString('uid'),
        'cid': SharedPreferencesInstance.getString('comp_id'),
        'type': 'task_status_update',
        "id": taskid,
        "status": status,
      }, headers: <String, String>{
        'Accept': 'application/json',
      });
      var rsp = jsonDecode(response.body);
      log(rsp.toString());
      if (rsp.containsKey("status")) {
        if (rsp["status"].toString() == "true") {
          Navigator.pop(context);
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => ViewTodoList()));
        }
      }
      log(userData.toString());
    } catch (error) {
      log(error.toString());
    }
  }

  openstatussheet(int index) {
    return showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        builder: (context) {
          return Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10))),
            height: 100,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FlatButton(
                  color: Colors.green,
                  textColor: Colors.white,
                  child: Text("Mark as Complete"),
                  onPressed: () {
                    Navigator.pop(context);
                    showLoaderDialogwithName(context, "Please Wait..");
                    update_todolist_status(userData[index]["id"], "1");
                  },
                ),
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer:
          const CustomDrawer(currentScreen: AvailableDrawerScreens.TodoList),
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
          "To-Do List",
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
                  : ListView.builder(
                      itemCount: userData == null ? 0 : userData.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Container(
                            child: Card(
                              elevation: 10,
                              color: Colors.white,
                              margin: const EdgeInsets.all(8.0),
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Task",
                                          style: TextStyle(
                                              color: themecolor,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Text(
                                          userData[index]["task"].toString(),
                                          style: TextStyle(
                                            color: Colors.grey.shade700,
                                            fontSize: 15,
                                          ),
                                        ),
                                        Divider(),
                                        Text(
                                          "Deadline",
                                          style: TextStyle(
                                              color: themecolor,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Text(
                                          userData[index]["deadline"]
                                              .toString(),
                                          style: TextStyle(
                                            color: Colors.grey.shade700,
                                            fontSize: 15,
                                          ),
                                        ),
                                        Divider(),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "Status",
                                                  style: TextStyle(
                                                      color: themecolor,
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                SizedBox(
                                                  height: 5,
                                                ),
                                                userData[index]["status"]
                                                            .toString() ==
                                                        "1"
                                                    ? Container(
                                                        decoration: BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5),
                                                            color:
                                                                Colors.green),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(5.0),
                                                          child: Text(
                                                            "Completed",
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 15,
                                                            ),
                                                          ),
                                                        ),
                                                      )
                                                    : Container(
                                                        decoration: BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5),
                                                            color: Colors.red),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(5.0),
                                                          child: Text(
                                                            "Pending",
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 15,
                                                            ),
                                                          ),
                                                        ),
                                                      )
                                              ],
                                            ),
                                            userData[index]["status"]
                                                        .toString() ==
                                                    "0"
                                                ? RaisedButton(
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5)),
                                                    color: themecolor,
                                                    onPressed: () {
                                                      openstatussheet(index);
                                                    },
                                                    child: Text(
                                                      "Change Status",
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                    ),
                                                  )
                                                : Container(),
                                          ],
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
            ),
    );
  }
}
