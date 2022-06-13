import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import 'constants.dart';
import 'drawer.dart';
import 'services/shared_preferences_singleton.dart';

class ApplyLeave extends StatefulWidget {
  const ApplyLeave({Key key}) : super(key: key);

  @override
  _ApplyLeaveState createState() => _ApplyLeaveState();
}

class _ApplyLeaveState extends State<ApplyLeave>
    with SingleTickerProviderStateMixin<ApplyLeave> {
  bool visible = true;
  Map data, leaveQuota;
  Map datanew;
  List userData;
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
  var difference = "";
  var newdata;

  loadProgress() {
    if (visible == true) {
      setState(() {
        visible = false;
      });
    } else {
      setState(() {
        visible = true;
      });
    }
  }

  @override
  void initState() {
    getEmail();
    fetchList();
    fetchCredit();
    fetchQuota();
    super.initState();
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
                    fetchCredit();
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

  Future fetchCredit() async {
    try {
      var urii = "$customurl/controller/process/app/leave.php";
      final responsenew = await http.post(urii, body: {
        'uid': SharedPreferencesInstance.getString('uid'),
        'cid': SharedPreferencesInstance.getString('comp_id'),
        'type': 'fetch_credit'
      }, headers: <String, String>{
        'Accept': 'application/json',
      });
      datanew = json.decode(responsenew.body);
      setState(() {
        visible = true;
        userDatanew = datanew["data"];
        if (userDatanew == null) {
          setState(() {
            userDatanew = [];
          });
        }
        visible = true;
      });
      if (debug == 'yes') {
        //debugPrint(userDatanew.toString());
        //debugPrint(datanew.toString());
      }
    } catch (error) {
      showRetry();
    }
  }

  String resulted;
  DateTime selectedDate = DateTime.now();
  DateTime selectedDatenew = DateTime.now();
  var customFormat = DateFormat('yyyy-MM-dd');
  var customFormatnew = DateFormat('yyyy-MM-dd');
  Future<void> showPicker(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0XFF072A99), // header background color
              onPrimary: Colors.white, // header text color
              onSurface: Color(0XFF072A99),

              /// body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                primary: const Color(0XFF072A99), //text color
              ),
            ),
          ),
          child: child,
        );
      },
      initialDate: selectedDate,
      firstDate: DateTime(2021),
      lastDate: DateTime(2050),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> showPickernew(BuildContext context) async {
    final DateTime pickednew = await showDatePicker(
        context: context,
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: Color(0XFF072A99), // header background color
                onPrimary: Colors.white, // header text color
                onSurface: Color(0XFF072A99),

                /// body text color
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  primary: const Color(0XFF072A99), //text color
                ),
              ),
            ),
            child: child,
          );
        },
        initialDate: selectedDatenew,
        firstDate: DateTime(2021),
        lastDate: DateTime(2050));

    if (pickednew != null && pickednew != selectedDatenew) {
      setState(() {
        var difference = pickednew.difference(selectedDate).inDays;

        if (0 > difference) {
          setState(() {});
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
              '"To Date" Should Not Be Earlier Than "From Date"',
              textAlign: TextAlign.center,
            ),
            backgroundColor: Colors.red,
          ));
        } else {
          resulted = "Good Day.";
          selectedDatenew = pickednew;
        }
      });
    }
  }

  // String username = "";

  Future Leave() async {
    try {
      var urii = "$customurl/controller/process/app/leave.php";
      final responseneww = await http.post(urii, body: {
        'uid': SharedPreferencesInstance.getString('uid'),
        'cid': SharedPreferencesInstance.getString('comp_id'),
        'type': 'apply_leave',
        'date_from': customFormat.format(selectedDate),
        if (_mycredit == '2' || _mycredit == '6')
          'date_to': customFormat.format(selectedDate)
        else if (_mycredit == '1')
          'date_to': customFormatnew.format(selectedDatenew)
        else if (_mycredit == '5')
          'date_to': customFormatnew.format(selectedDatenew),
        'credit': _mycredit,
        'avail_leave': _mylist,
        'reason': reasonController.text
      }, headers: <String, String>{
        'Accept': 'application/json',
      });
      newdata = json.decode(responseneww.body);
      if (newdata.containsKey('status')) {
        setState(() {
          // message =  mydataatt['msg'];
          visible = false;
        });
        if (newdata['status'] == true) {
          setState(() {
            Fluttertoast.showToast(
                msg: "Successfully Applied",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 2,
                backgroundColor: Colors.white,
                textColor: Colors.black,
                fontSize: 16.0);
            _mycredit = null;
            _mylist = null;
            reasonController.clear();
          });
        } else if (newdata['status'] == false) {
          setState(() {
            Fluttertoast.showToast(
                msg: "${newdata['error']}",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 2,
                backgroundColor: Colors.white,
                textColor: Colors.black,
                fontSize: 16.0);
            _mycredit = null;
            _mylist = null;
            reasonController.clear();
          });
        }
      }
      if (debug == 'yes') {
        //debugPrint(newdata.toString());
        //print('from- ${customFormat.format(selectedDate)}');
        //print('To- ${customFormatnew.format(selectedDatenew)}');
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

  bool submitting = false;
  submitButton() async {
    if (submitting) return;
    if (reasonController.text.isNotEmpty &&
        _mycredit != null &&
        _mylist != null) {
      setState(() {
        userDatanew = null;
        initState();
      });
      submitting = true;
      await Leave();
      submitting = false;
      return;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.fixed,
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.black.withOpacity(0.5),
        content: Center(
            child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height / 2.5,
            ),
            const Icon(
              Icons.warning,
              size: 60,
              color: Colors.white,
            ),
            const Text(
              'Please fill the required fields',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 3),
              textAlign: TextAlign.center,
            ),
          ],
        )),
      ));
    }
  }

  List quota;

  Future fetchQuota() async {
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
        quota = data["data"];
      });
      if (quota.isNotEmpty) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
            "Leave Quota not assigned, please contact admin",
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.red));
    } catch (error) {
//
    }
  }

  String selectedCreditName;
  int selectedItem;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer:
          const CustomDrawer(currentScreen: AvailableDrawerScreens.applyLeave),
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          "Apply Leave",
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
      body: userDatanew == null || quota == null
          ? Center(
              child: LoadingAnimationWidget.flickr(
                leftDotColor: Colors.indigo,
                rightDotColor: Colors.blue,
                size: 60,
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(8),
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 10.0, top: 8),
                  child: Text(
                    "Select Leave Type",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      color: Color(0xff072a99),
                    ),
                  ),
                ),
                Card(
                  margin: const EdgeInsets.all(10.0),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: DropdownButton<String>(
                      isExpanded: true,
                      underline: const SizedBox(),
                      hint: const Text("Leave Type"),
                      items: quota.isEmpty
                          ? []
                          : userData?.map((item) {
                                return DropdownMenuItem(
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          item['type'],
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontFamily: font1,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        " Available: " +
                                            (item['avail_quota']?.toString() ??
                                                ""),
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontFamily: font1,
                                        ),
                                      ),
                                    ],
                                  ),
                                  value: item['id'].toString(),
                                );
                              })?.toList() ??
                              [],
                      value: _mylist,
                      onChanged: (String newValue) {
                        setState(() {
                          _mylist = newValue;
                        });
                      },
                    ),
                  ),
                ),
                const Padding(
                    padding: EdgeInsets.only(left: 10.0, top: 8),
                    child: Text("Select Credit Type",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                          color: Color(0xff072a99),
                        ))),
                Card(
                  margin: const EdgeInsets.all(10.0),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: DropdownButton<String>(
                      isExpanded: true,
                      underline: const SizedBox(),
                      hint: const Text("Credit Type"),
                      items: userDatanew?.map((item) {
                            return DropdownMenuItem(
                              child: Text(
                                item['credit'],
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontFamily: font1,
                                ),
                              ),
                              value: userDatanew.indexOf(item).toString(),
                            );
                          })?.toList() ??
                          [],
                      value: selectedItem?.toString(),
                      onChanged: (String newValue) {
                        selectedItem = int.parse(newValue);
                        var item = userDatanew[int.parse(newValue)];
                        setState(() {
                          selectedCreditName = item['credit'];
                          _mycredit = item['id'].toString();
                        });
                        print(selectedCreditName);
                        print(_mycredit);
                      },
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("Select Date",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                        color: Color(0xff072a99),
                      )),
                ),
                Card(
                  margin: const EdgeInsets.all(8),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: IntrinsicHeight(
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                showPicker(context);
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text("From",
                                      style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xff072a99),
                                      )),
                                  const SizedBox(height: 10),
                                  Text(
                                    DateFormat("dd MMM, y")
                                        .format(selectedDate),
                                  )
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            child: Row(
                              children: [
                                const VerticalDivider(
                                  indent: 4,
                                  endIndent: 4,
                                  color: Color(0x99072a99),
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      if (selectedCreditName != null &&
                                          (selectedCreditName
                                                  .contains("Half Day") ||
                                              selectedCreditName
                                                  .contains("Short"))) return;
                                      showPickernew(context);
                                    },
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text("To",
                                            style: TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.w500,
                                              color: (selectedCreditName !=
                                                          null &&
                                                      (selectedCreditName
                                                              .contains(
                                                                  "Half Day") ||
                                                          selectedCreditName
                                                              .contains(
                                                                  "Short")))
                                                  ? Colors.grey
                                                  : const Color(0xff072a99),
                                            )),
                                        const SizedBox(height: 10),
                                        Text(
                                            DateFormat("dd MMM, y")
                                                .format(selectedDatenew),
                                            style: TextStyle(
                                              color: (selectedCreditName !=
                                                          null &&
                                                      (selectedCreditName
                                                              .contains(
                                                                  "Half Day") ||
                                                          selectedCreditName
                                                              .contains(
                                                                  "Short")))
                                                  ? Colors.grey
                                                  : Colors.black,
                                            )),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Padding(
                    padding: EdgeInsets.only(left: 10.0, top: 8),
                    child: Text("Reason for Leave",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                          color: Color(0xff072a99),
                        ))),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: TextField(
                    controller: reasonController,
                    cursorColor: const Color(0x33072a99),
                    keyboardType: TextInputType.name,
                    onSubmitted: (_) {},
                    minLines: 5,
                    maxLines: 15,
                    textInputAction: TextInputAction.done,
                    style: const TextStyle(color: Color(0xff072a99)),
                    decoration: InputDecoration(
                      fillColor: const Color(0x33072a99),
                      filled: true,
                      hintText: "State your reason here",
                      contentPadding: const EdgeInsets.all(10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: submitButton,
                    child: const Text("Apply Leave"),
                    style: ButtonStyle(
                      padding:
                          MaterialStateProperty.all(const EdgeInsets.all(15)),
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10))),
                      backgroundColor: MaterialStateProperty.all(
                        const Color(0xff072a99),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
      // //bottomNavigationBar: const CustomBottomNavigationBar(),
    );
  }
}
