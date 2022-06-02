import 'package:ezhrm/services/shared_preferences_singleton.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'constants.dart';
import 'drawer.dart';

class LeaveQuota extends StatefulWidget {
  const LeaveQuota({Key key}) : super(key: key);

  @override
  _LeaveQuotaState createState() => _LeaveQuotaState();
}

class _LeaveQuotaState extends State<LeaveQuota>
    with SingleTickerProviderStateMixin<LeaveQuota> {
  bool visible = false;
  Map data;
  List userData;
  String username;
  String email;
  String ppic;
  String ppic2;
  String uid;
  String cid;

  @override
  void initState() {
    super.initState();
    // mping();
    getEmail();
    fetchList();
  }

  Future getEmail() async {
    setState(() {
      email = SharedPreferencesInstance.getString('email');
      username = SharedPreferencesInstance.getString('username');
      ppic = SharedPreferencesInstance.getString('profile');
      ppic2 = SharedPreferencesInstance.getString('profile2');
      uid = SharedPreferencesInstance.getString('uid');
      cid = SharedPreferencesInstance.getString('comp_id');
    });
  }

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
                    'Network Issues, try again after sometime',
                    style: TextStyle(fontFamily: font1),
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
                    fetchList();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future fetchList() async {
    try {
      var uri = "$customurl/controller/process/app/leave.php";
      final response = await http.post(uri, body: {
        'uid': SharedPreferencesInstance.getString('uid'),
        'cid': SharedPreferencesInstance.getString('comp_id'),
        'type': 'fetch_quota'
      }, headers: <String, String>{
        'Accept': 'application/json',
      });
      data = json.decode(response.body);
      setState(() {
        visible = true;
        userData = data["data"];
        visible = true;
      });
      if (debug == 'yes') {
        //debugPrint(userData.toString());
      }
    } catch (error) {
      showRetry();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer:
          const CustomDrawer(currentScreen: AvailableDrawerScreens.leaveQuota),
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
        bottomOpacity: 0,
        elevation: 0,
        title: const Text(
          "Leave Quota",
          style: TextStyle(color: Colors.white),
        ),
      ),
      backgroundColor: Colors.white,
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
          : userData.isEmpty ||  userData == null
              ? const Center(
                  child: Text(
                    'No leave quota assigned',
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
                    return Card(
                      elevation: 5,
                      margin: const EdgeInsets.all(18.0),
                      child: Column(
                        children: [
                          Container(
                            decoration: const BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(0)),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.blue, Colors.indigo],
                              ),
                            ),
                            width: MediaQuery.of(context).size.width,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Padding(
                                  padding: const EdgeInsets.all(3.0),
                                  child: Text(
                                    userData[index]["type"],
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 20),
                                  )),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Spacer(),
                              SizedBox(
                                // width: MediaQuery.of(context).size.width,
                                width: 150,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      const Card(
                                          elevation: 0,
                                          child: Center(
                                              child: Text(
                                            'Total',
                                            style: TextStyle(
                                              color: Color(0xff072a99),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20,
                                            ),
                                          ))),
                                      Center(
                                          child: Text(
                                        userData[index]["total_quota"],
                                        style: const TextStyle(
                                            fontFamily: font1,
                                            color: Colors.black,
                                            fontSize: 20),
                                      )),
                                    ],
                                  ),
                                ),
                              ),
                              const Spacer(),
                              SizedBox(
                                // width: MediaQuery.of(context).size.width,
                                width: 150,
                                child: Column(
                                  children: [
                                    const Card(
                                        elevation: 0,
                                        child: Center(
                                            child: Text(
                                          'Available',
                                          style: TextStyle(
                                              fontFamily: font1,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xff072a99),
                                              fontSize: 20),
                                        ))),
                                    Center(
                                        child: Text(
                                      userData[index]["avail_quota"],
                                      style: const TextStyle(
                                          fontFamily: font1,
                                          color: Colors.black,
                                          fontSize: 20),
                                    )),
                                  ],
                                ),
                              ),
                              const Spacer(),
                            ],
                          )
                        ],
                      ),
                    );
                  }),
      /* floatingActionButton: GestureDetector(
        child: FloatingActionButton(
        backgroundColor: Colors.indigo,
         onPressed: () {
           logOut(context);
        },child:  Icon(Icons.directions_run,),
          elevation: 40,
          hoverColor: Colors.red,
          splashColor: Colors.red,
          focusElevation: 200,
    ),
     onLongPress: (){

     },

      ),*/
      //bottomNavigationBar: const CustomBottomNavigationBar(),
    );
  }
}
