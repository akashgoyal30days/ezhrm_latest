import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:ezhrm/services/shared_preferences_singleton.dart';
import 'package:getwidget/components/loader/gf_loader.dart';
import 'package:getwidget/types/gf_loader_type.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'dart:convert';
import 'constants.dart';
import 'drawer.dart';

class MyHoliday extends StatefulWidget {
  const MyHoliday({Key key}) : super(key: key);

  @override
  _MyHolidayState createState() => _MyHolidayState();
}

class _MyHolidayState extends State<MyHoliday>
    with SingleTickerProviderStateMixin<MyHoliday> {
  bool visible = false;
  Map data;
  Map datanew;
  List userData;
  List userDatanew;
  String username;
  String email;
  String ppic;
  String ppic2;
  String uid;
  String cid;
  var currDt = DateTime.now();

  var internet = 'yes';
  void mping() async {
    var listener = DataConnectionChecker().onStatusChange.listen((status) {
      switch (status) {
        case DataConnectionStatus.connected:
          //print('Data connection is available.');
          // OverlayScreen().pop();
          showTopSnackBar(
              context,
              const CustomSnackBar.success(
                message: 'connected',
              ));
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
      var uri = "$customurl/controller/process/app/attendance.php";
      final response = await http.post(uri, body: {
        'type': 'fetch_holiday',
        'cid': SharedPreferencesInstance.getString('comp_id'),
        'uid': SharedPreferencesInstance.getString('uid'),
        'year': currDt.year.toString()
      }, headers: <String, String>{
        'Accept': 'application/json',
      });
      data = json.decode(response.body);
      setState(() {
        visible = true;
        userData = data["data"];
        print(userData);
        //da = data["data"]["status"];
        visible = true;
      });
      if (debug == 'yes') {
        //debugPrint(userData.toString());
      }
    } catch (error) {
      showRetry();
    }
  }

  // String username = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer:
          const CustomDrawer(currentScreen: AvailableDrawerScreens.holidayList),

      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.blue,
        title: const Text(
          'Holiday List',
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
              child: userData.isEmpty
                  ? const Center(
                      child: Text(
                        'No Holidays Available',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w400,
                            color: Colors.black),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(14),
                      itemCount: userData == null ? 0 : userData.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${userData[index]['remarks']}',
                                    style: const TextStyle(
                                        fontFamily: font1,
                                        color: Color(0xff072a99),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20),
                                  ),
                                  Text(
                                    DateFormat('d MMM, y').format(
                                      DateTime(
                                          int.parse(userData[index]['date']
                                              .toString()
                                              .substring(0, 4)),
                                          int.parse(userData[index]['date']
                                              .toString()
                                              .substring(5, 7)),
                                          int.parse(userData[index]['date']
                                              .toString()
                                              .substring(8))),
                                    ),
                                    style: const TextStyle(
                                        fontFamily: font1,
                                        fontStyle: FontStyle.italic),
                                  ),
                                ],
                              ),
                              const Divider(),
                            ],
                          ),
                        );
                      }),
            ),
      //bottomNavigationBar: const CustomBottomNavigationBar(),
    );
  }
}
