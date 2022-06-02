import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:ezhrm/applycompoff.dart';
import 'package:ezhrm/services/shared_preferences_singleton.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'dart:convert';
import 'constants.dart';

class ApplyCmp extends StatefulWidget {
  const ApplyCmp({Key key}) : super(key: key);

  @override
  _ApplyCmpState createState() => _ApplyCmpState();
}

class _ApplyCmpState extends State<ApplyCmp>
    with SingleTickerProviderStateMixin<ApplyCmp> {
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

  dynamic reasonController = TextEditingController();
  var newdata;

  final List<String> leaveList = <String>[
    "Full Day",
    "Half Day",
  ];

  final List<String> leaveListval = <String>[
    "1",
    "2",
  ];
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
    // mping();

    getEmail();
    fetchList();
    // fetchCredit();
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
      var uri = "$customurl/controller/process/app/comp_off.php";
      final response = await http.post(uri, body: {
        'uid': SharedPreferencesInstance.getString('uid'),
        'cid': SharedPreferencesInstance.getString('comp_id'),
        'type': 'compoff_status'
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

  DateTime selectedDate = DateTime.now();
  DateTime selectedDatenew = DateTime.now();
  var customFormat = DateFormat('yyyy-MM-dd');
  var customFormatnew = DateFormat('yyyy-MM-dd');
  Future<void> showPicker(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1900),
        lastDate: DateTime.now());

    if (picked != null && picked != selectedDate && picked != selectedDatenew) {
      setState(() {
        selectedDate = picked;
        selectedDatenew = picked;
      });
    }
  }

  Future<void> showPickernew(BuildContext context) async {
    final DateTime pickednew = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1900),
        lastDate: DateTime(2101));

    if (pickednew != null && pickednew != selectedDatenew) {
      setState(() {
        selectedDatenew = pickednew;
      });
    }
  }

  // String username = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //toolbarHeight: 30,
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
        title: const Center(
            child: Text(
          "Comp Off",
          style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: font1),
        )),
        backgroundColor: Colors.blue,
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
          : userData.isEmpty
              ? const Center(
                  child: Text(
                    'No data Found',
                    style: TextStyle(color: Colors.black, fontSize: 20),
                  ),
                )
              : Container(
                  color: Colors.white,
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.white, Colors.white],
                      ),
                    ),
                    child: ListView.builder(
                        itemCount: userData == null ? 0 : userData.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Padding(
                            padding: const EdgeInsets.fromLTRB(8, 10, 8, 0),
                            child: FlipCard(
                              direction: FlipDirection.VERTICAL, // default
                              front: Card(
                                elevation: 10,
                                child: Container(
                                  decoration: const BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10)),
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [Colors.white, Colors.white],
                                    ),
                                  ),
                                  height: 60,
                                  // width: MediaQuery.of(context).size.width,
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            20, 5, 0, 0),
                                        child: Text(
                                          "${userData[index]["date"]}",
                                          style: const TextStyle(
                                              fontSize: 15,
                                              color: Colors.grey,
                                              fontFamily: font1,
                                              fontWeight: FontWeight.w900),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 55,
                                      ),
                                      if (userData[index]["status"] == '0')
                                        const Text(
                                          "Pending  ",
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: Colors.grey,
                                              fontFamily: font1,
                                              fontWeight: FontWeight.w900),
                                        )
                                      else if (userData[index]["status"] == '1')
                                        const Text(
                                          "Approved",
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: Colors.blue,
                                              fontFamily: font1,
                                              fontWeight: FontWeight.w900),
                                        )
                                      else if (userData[index]["status"] == '2')
                                        const Text(
                                          "Rejected ",
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: Colors.red,
                                              fontFamily: font1,
                                              fontWeight: FontWeight.w900),
                                        )
                                      else if (userData[index]["status"] == '3')
                                        const Text(
                                          "Cancelled",
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: Colors.red,
                                              fontFamily: font1,
                                              fontWeight: FontWeight.w900),
                                        ),
                                      //Spacer(),
                                      const SizedBox(
                                        width: 45,
                                      ),
                                      Row(
                                        children: [
                                          if (userData[index]['credit_id'] ==
                                              '1')
                                            const Text(
                                              'Full Day',
                                              style: TextStyle(
                                                  color: Colors.grey,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18),
                                            )
                                          else if (userData[index]
                                                  ['credit_id'] ==
                                              '2')
                                            const Text(
                                              'Half Day',
                                              style: TextStyle(
                                                  color: Colors.grey,
                                                  fontFamily: font1,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18),
                                            )
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              back: Container(
                                decoration: const BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [Colors.blue, Colors.indigo],
                                  ),
                                ),
                                height: 60,
                                child: Center(
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(21.0),
                                        child: Center(
                                          child: Row(
                                            children: [
                                              Text(
                                                ' Reason - ${userData[index]["reason"]}',
                                                style: const TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.white,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                              const Spacer(),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                  ),
                ),
      floatingActionButton: userData == null
          ? const SizedBox()
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
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const ApplyCompOff()));
                },
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
