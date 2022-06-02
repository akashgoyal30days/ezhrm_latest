import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:ezhrm/services/shared_preferences_singleton.dart';
import 'package:getwidget/components/loader/gf_loader.dart';
import 'package:getwidget/types/gf_loader_type.dart';
import 'package:ezhrm/login.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

import 'applyadvsalary.dart';
import 'constants.dart';
import 'drawer.dart';

class Advance extends StatefulWidget {
  const Advance({Key key}) : super(key: key);

  @override
  _AdvanceState createState() => _AdvanceState();
}

class _AdvanceState extends State<Advance>
    with SingleTickerProviderStateMixin<Advance> {
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
  var internet = 'yes';
  void mping() async {
    if (debug == 'yes') {
      //print("The statement 'this machine is connected to the Internet' is: ");
      //print(await DataConnectionChecker().hasConnection);

      // returns a bool

      // We can also get an enum instead of a bool
      //print("Current status: ${await DataConnectionChecker().connectionStatus}");
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
    // mping();
    getEmail();
    fetchList();
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
                    'Network Issues, Try again after sometime',
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

  Future fetchList() async {
    try {
      var uri = "$customurl/controller/process/app/extras.php";
      final response = await http.post(uri, body: {
        'type': 'fetch_advance_history',
        'cid': SharedPreferencesInstance.getString('comp_id'),
        'uid': SharedPreferencesInstance.getString('uid')
      }, headers: <String, String>{
        'Accept': 'application/json',
      });
      data = json.decode(response.body);
      setState(() {
        visible = true;
        userData = data["data"];
        //da = data["data"]["status"];
        visible = true;
      });
      if (userData.isEmpty) {
        showCupertinoDialog(
          context: context,
          builder: (context) {
            return Theme(
              data: ThemeData.dark(),
              child: CupertinoAlertDialog(
                title: Column(
                  children: const [
                    Icon(
                      Icons.warning,
                      color: Colors.yellow,
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      'No advance salary taken',
                      style: TextStyle(fontFamily: font1),
                    ),
                  ],
                ),
                actions: <Widget>[
                  CupertinoDialogAction(
                    isDefaultAction: true,
                    child: const Text(
                      'OK',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            );
          },
        );
      }
    } catch (error) {
      userData = [];
      // showRetry();
    }
  }

  // String username = "";

  Future logOut(BuildContext context) async {
    SharedPreferencesInstance.instance.remove('username');
    SharedPreferencesInstance.instance.remove('email');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const Login(),
      ),
    );
  }

  show(String remarks) {
    showCupertinoDialog(
      barrierDismissible: true,
      context: context,
      builder: (context) {
        return Theme(
          data: ThemeData.dark(),
          child: CupertinoAlertDialog(
            content: Text(
              remarks,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontFamily: font1),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CustomDrawer(
          currentScreen: AvailableDrawerScreens.advanceSalary),

      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.blue,
        title: const Text(
          'Advance Salary List',
          style: TextStyle(color: Colors.white),
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
          : Column(
              children: [
                Container(
                  height: 50,
                  width: MediaQuery.of(context).size.width,
                  color: Colors.black,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: const [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Month/Year',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(0, 8, 8, 8),
                        child: Text(
                          'Amount',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(0, 8, 8, 8),
                        child: Text(
                          'Status',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Remarks',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height / 1.5,
                  child: userData.isEmpty
                      ? const Center(
                          child: Text(
                            'No any data found',
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
                            return Container(
                              height: 80,
                              color: Colors.transparent,
                              child: Card(
                                elevation: 80,
                                child: ListView(
                                  shrinkWrap: true,
                                  scrollDirection: Axis.horizontal,
                                  physics: const BouncingScrollPhysics(),

                                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          20, 0, 0, 0),
                                      child: SizedBox(
                                        width: 70,
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              0, 20, 8, 8),
                                          child: Text(
                                            '${userData[index]['month']} / ${userData[index]['year']}',
                                            style: const TextStyle(
                                                color: Colors.black),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          45, 10, 0, 0),
                                      child: SizedBox(
                                        width: 70,
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              0, 8, 8, 8),
                                          child: Text(
                                            '${userData[index]['amount']}',
                                            style: const TextStyle(
                                                color: Colors.black),
                                          ),
                                        ),
                                      ),
                                    ),
                                    if (userData[index]['status'] == '0')
                                      const Padding(
                                        padding:
                                            EdgeInsets.fromLTRB(5, 10, 0, 0),
                                        child: SizedBox(
                                          width: 75,
                                          child: Padding(
                                            padding:
                                                EdgeInsets.fromLTRB(0, 8, 8, 8),
                                            child: Text(
                                              'Pending',
                                              style:
                                                  TextStyle(color: Colors.red),
                                            ),
                                          ),
                                        ),
                                      ),
                                    if (userData[index]['status'] == '1')
                                      const Padding(
                                        padding:
                                            EdgeInsets.fromLTRB(5, 10, 0, 0),
                                        child: SizedBox(
                                          width: 75,
                                          child: Padding(
                                            padding:
                                                EdgeInsets.fromLTRB(0, 8, 8, 8),
                                            child: Text(
                                              'Approved',
                                              style: TextStyle(
                                                  color: Colors.green),
                                            ),
                                          ),
                                        ),
                                      ),
                                    if (userData[index]['status'] == '2')
                                      const Padding(
                                        padding:
                                            EdgeInsets.fromLTRB(5, 10, 0, 0),
                                        child: SizedBox(
                                          width: 75,
                                          child: Padding(
                                            padding:
                                                EdgeInsets.fromLTRB(0, 8, 8, 8),
                                            child: Text(
                                              'Rejected',
                                              style: TextStyle(
                                                  color:
                                                      Colors.deepPurpleAccent),
                                            ),
                                          ),
                                        ),
                                      ),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          15, 0, 10, 0),
                                      child: SizedBox(
                                        width: 70,
                                        child: IconButton(
                                          icon: const Icon(CupertinoIcons.eye),
                                          onPressed: () {
                                            if (userData[index]['remarks'] ==
                                                '') {
                                              show('No any remarks available');
                                            } else {
                                              show(userData[index]['remarks']);
                                            }
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                ),
              ],
            ),
      floatingActionButton: userData == null
          ? Container()
          : Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(50)),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.blue, Colors.indigo],
                ),
              ),
              width: 120,
              child: TextButton(
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const Applyadvsalary())),
                child: Row(
                  children: const [
                    Icon(
                      Icons.add_circle,
                      color: Colors.white,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      'Apply New',
                      style: TextStyle(color: Colors.white, fontFamily: font1),
                    ),
                  ],
                ),
              ),
            ),
      //bottomNavigationBar: const CustomBottomNavigationBar(),
    );
  }
}
