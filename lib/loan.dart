import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:ezhrm/applyloan.dart';
import 'package:ezhrm/services/shared_preferences_singleton.dart';
import 'package:getwidget/components/loader/gf_loader.dart';
import 'package:getwidget/types/gf_loader_type.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'dart:convert';
//import 'package:fluttertoast/fluttertoast.dart';
import 'constants.dart';
import 'drawer.dart';

class Loan extends StatefulWidget {
  const Loan({Key key}) : super(key: key);

  @override
  _LoanState createState() => _LoanState();
}

class _LoanState extends State<Loan> with SingleTickerProviderStateMixin<Loan> {
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
                    'Network Issues, try again after sometime',
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
        'type': 'check_self_loan',
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
      if (debug == 'yes') {
        //debugPrint(userData.toString());
      }
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
                    Text('No loans taken'),
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
      showRetry();
    }
  }

  Future show(
          String loanamount, String appstatus, String clear, List emilist) =>
      showModalBottomSheet(
          context: context,
          builder: (BuildContext builder) {
            return Container(
              color: Colors.white,
              height: emilist.isEmpty ? 270 : 600,
              child: Column(
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Divider(),
                      Text(
                        'Loan Amount - $loanamount',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(),
                    ],
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                        child: Container(
                          height: 30,
                          width: MediaQuery.of(context).size.width / 2.5,
                          color: Colors.blue,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: const [
                                Spacer(),
                                Center(
                                    child: Text(
                                  'Loan Approval Status',
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                )),
                                Spacer(),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(10, 10, 20, 0),
                        child: Container(
                          height: 30,
                          width: MediaQuery.of(context).size.width / 2.5,
                          color: Colors.blue,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: const [
                                Spacer(),
                                Center(
                                    child: Text(
                                  'Loan Clear Status',
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                )),
                                Spacer(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                          child: Container(
                            width: MediaQuery.of(context).size.width / 2.5,
                            color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  const Spacer(),
                                  if (appstatus == '0')
                                    const Center(
                                        child: Text(
                                      'Pending',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ))
                                  else if (appstatus == '1')
                                    const Center(
                                        child: Text(
                                      'Approved',
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ))
                                  else if (appstatus == '2')
                                    const Center(
                                        child: Text(
                                      'Rejected',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )),
                                  const Spacer(),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(10, 10, 20, 0),
                          child: Container(
                            width: MediaQuery.of(context).size.width / 2.5,
                            color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  const Spacer(),
                                  if (clear == '0')
                                    const Center(
                                        child: Text(
                                      'Pending',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ))
                                  else if (clear == '1')
                                    const Center(
                                        child: Text(
                                      'Completed',
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )),
                                  const Spacer(),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    color: Colors.transparent,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8, 2, 8, 8),
                      child: Row(
                        children: const [
                          Spacer(),
                          Text(
                            'List Of Recovered Emi',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                            ),
                          ),
                          Spacer(),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      height: 50,
                      width: MediaQuery.of(context).size.width,
                      color: Colors.black,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: const [
                          SizedBox(
                            width: 90,
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(20, 8, 0, 8),
                              child: Text(
                                'Month/Year',
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Expected Amount',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(0, 8, 8, 8),
                            child: Text(
                              'Recieved Amount',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  emilist.isEmpty
                      ? const Card(
                          child: Center(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'No Emi Deducted',
                              style: TextStyle(
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ))
                      : SizedBox(
                          height: 250,
                          child: ListView.builder(
                              itemCount: emilist == null ? 0 : emilist.length,
                              itemBuilder: (BuildContext context, int index) {
                                return Container(
                                  color: Colors.transparent,
                                  child: Card(
                                    elevation: 80,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              7, 0, 0, 0),
                                          child: SizedBox(
                                            width: 90,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      20, 8, 8, 8),
                                              child: Text(
                                                '${emilist[index]['month']}/${emilist[index]['year']}',
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              20, 0, 0, 0),
                                          child: SizedBox(
                                            width: 70,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      0, 8, 8, 8),
                                              child: Text(
                                                '${emilist[index]['amount_exp']}',
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              15, 0, 0, 0),
                                          child: SizedBox(
                                            width: 70,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      0, 8, 8, 8),
                                              child: Text(
                                                '${emilist[index]['amount_recv']}',
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                ),
                                              ),
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
            );
          });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CustomDrawer(currentScreen: AvailableDrawerScreens.loan),
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.blue,
        title: const Text(
          'Loan',
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
          ? Center(
              child: Container(
              child: const GFLoader(
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
                          '     Loan Amount',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(0, 8, 8, 8),
                        child: Text(
                          'Emi Amount',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(0, 8, 8, 8),
                        child: Text(
                          'Approval Status',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Details',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height / 1.32,
                  child: ListView.builder(
                      itemCount: userData == null ? 0 : userData.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Container(
                          color: Colors.transparent,
                          child: Card(
                            elevation: 80,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(20, 0, 0, 0),
                                  child: SizedBox(
                                    width: 70,
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.fromLTRB(0, 8, 8, 8),
                                      child: Text(
                                        '${userData[index]['loan_amount']}',
                                        style: const TextStyle(
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(15, 0, 0, 0),
                                  child: SizedBox(
                                    width: 70,
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.fromLTRB(0, 8, 8, 8),
                                      child: Text(
                                        '${userData[index]['emi_amount']}',
                                        style: const TextStyle(
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                if (userData[index]['approval_status'] == '0')
                                  const Padding(
                                    padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                                    child: SizedBox(
                                      width: 70,
                                      child: Padding(
                                        padding:
                                            EdgeInsets.fromLTRB(0, 8, 8, 8),
                                        child: Text(
                                          'Pending',
                                          style: TextStyle(
                                            color: Colors.red,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                if (userData[index]['approval_status'] == '1')
                                  const Padding(
                                    padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                                    child: SizedBox(
                                      width: 70,
                                      child: Padding(
                                        padding:
                                            EdgeInsets.fromLTRB(0, 8, 8, 8),
                                        child: Text(
                                          'Approved',
                                          style: TextStyle(
                                            color: Colors.green,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                if (userData[index]['approval_status'] == '2')
                                  const Padding(
                                    padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                                    child: SizedBox(
                                      width: 70,
                                      child: Padding(
                                        padding:
                                            EdgeInsets.fromLTRB(0, 8, 8, 8),
                                        child: Text(
                                          'Rejected',
                                          style: TextStyle(
                                            color: Colors.deepPurpleAccent,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(1, 0, 0, 0),
                                  child: SizedBox(
                                    width: 70,
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.fromLTRB(0, 8, 8, 8),
                                      child: IconButton(
                                        icon: const Icon(CupertinoIcons.eye),
                                        onPressed: () {
                                          show(
                                              '${userData[index]['loan_amount']}',
                                              '${(userData[index]['approval_status'])}',
                                              '${userData[index]['loan_clear']}',
                                              userData[index]['emi']);
                                        },
                                      ),
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
              width: 140,
              child: TextButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const ApplyLoan()));
                },
                child: Row(
                  children: const [
                    Icon(
                      Icons.add_circle,
                      color: Colors.white,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Apply For Loan',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
      //bottomNavigationBar: const CustomBottomNavigationBar(),
    );
  }
}
