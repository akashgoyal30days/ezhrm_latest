import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:getwidget/types/gf_loader_type.dart';
import 'package:getwidget/components/loader/gf_loader.dart';

import 'main.dart';
import 'holiday.dart';
import 'tattlist.dart';
import 'constants.dart';
import 'applyleave.dart';
import 'leavestatus.dart';
import 'temareimlist.dart';
import 'teamleavelist.dart';
import 'markattendance_new.dart';
import 'attendance_history_new.dart';
import 'request_attendance_new.dart';
import 'services/shared_preferences_singleton.dart';

class HomePage extends StatefulWidget {
  const HomePage({this.profileViewScreenOpener, Key key, this.openDrawer})
      : super(key: key);
  final VoidCallback profileViewScreenOpener, openDrawer;
  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  String username,
      email,
      ppic,
      ppic2,
      uid,
      cid,
      mymgmt,
      locacc,
      freco,
      attreq,
      attlocat;

  Future getspref() async {
    setState(() {
      if (datak != null && datak['status'] == true) {
        setState(() {
          freco = datak['face_recog'];
          attreq = datak['req_attendance'];
          attlocat = datak['attendance_location'];
        });
      } else if (datak == null || datak['status'] == false || datak == '') {
        setState(() {
          freco = SharedPreferencesInstance.getString('freco');
          attreq = SharedPreferencesInstance.getString('reqatt');
          attlocat = SharedPreferencesInstance.getString('ulocat');
        });
      }
    });
  }

  String emppid;
  var cmplogo = '';
  getEmail() => setState(() {
        email = SharedPreferencesInstance.getString('email');
        username = SharedPreferencesInstance.getString('username');
        ppic = SharedPreferencesInstance.getString('profile');
        ppic2 = SharedPreferencesInstance.getString('profile2');
        uid = SharedPreferencesInstance.getString('uid');
        cid = SharedPreferencesInstance.getString('comp_id');
        emppid = SharedPreferencesInstance.getString('empid');
        mymgmt = SharedPreferencesInstance.getString('appmgmt');
      });

  bool visible = false;
  String myname = '',
      myskills = '',
      myphone = '',
      mygender = '',
      myreporting = '',
      myemail = '',
      mydoj = '',
      shiftname = '',
      shiftstart = '',
      shiftend = '',
      myid = '',
      mydob = '',
      myimg = '',
      mydesig = '';

  Map data, datanew;
  List userData, userDatanew;

  Future fetchList() async {
    try {
      var uri = "$customurl/controller/process/app/profile.php";
      final response = await http.post(uri, body: {
        'type': 'fetch_profile',
        'cid': SharedPreferencesInstance.getString('comp_id'),
        'uid': SharedPreferencesInstance.getString('uid')
      }, headers: <String, String>{
        'Accept': 'application/json',
      });
      data = json.decode(response.body);
      if (data['status'] == true) {
        setState(() {
          visible = true;
          userData = data["data"];
          myname = userData[0]['uname'];
          mydoj = userData[0]['u_doj'];
          myemail = userData[0]['u_email'];
          mygender = userData[0]['u_gender'];
          myphone = userData[0]['u_phone'];
          myid = userData[0]['uid'];
          myimg = userData[0]['img'];
          mydesig = userData[0]['u_designation'];
          myreporting = userData[0]['reporting_to'];
          mydob = userData[0]['u_dob'];
          myskills = userData[0]['u_skills'];
          shiftname = userData[0]['shift_name'];
          shiftstart = userData[0]['shift_start'];
          shiftend = userData[0]['shift_end'];
          visible = true;
          loader = 'dont show';
        });
      } else {
        setState(() {
          loader = 'error';
        });
      }
    } catch (error) {
      loader = 'error';
    }
  }

  @override
  void initState() {
    super.initState();
    getspref();
    fetchList();
    getEmail();
  }

 

  var loader = 'show';
  @override
  Widget build(BuildContext context) {
    var currentTime = DateTime.now();
    var greeting = currentTime.hour >= 5 && currentTime.hour < 12
        ? "Good Morning"
        : currentTime.hour >= 12 && currentTime.hour < 17
            ? "Good Afternoon"
            : "Good Evening";
    var greetingIcon = currentTime.hour >= 5 && currentTime.hour < 12
        ? const Icon(
            Icons.sunny,
            color: Colors.yellow,
            size: 28,
          )
        : currentTime.hour >= 12 && currentTime.hour < 17
            ? const Icon(
                Icons.wb_sunny,
                color: Colors.orange,
                size: 28,
              )
            : currentTime.hour >= 17 && currentTime.hour < 19
                ? const Icon(
                    Icons.sunny_snowing,
                    color: Colors.red,
                    size: 28,
                  )
                : Icon(
                    Icons.dark_mode,
                    color: Colors.yellow[200],
                    size: 28,
                  );
    return Scaffold(
      backgroundColor: const Color.fromRGBO(244, 244, 244, 1),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Stack(
              children: <Widget>[
                ClipPath(
                  clipper: CustomShapeClipper(),
                  child: Container(
                    width: double.infinity,
                    height: 200.0,
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
                SafeArea(
                  child: Center(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.89,
                      child: Column(children: [
                        Row(
                          children: <Widget>[
                            IconButton(
                              icon: const Icon(Icons.menu, color: Colors.white),
                              onPressed: widget.openDrawer,
                            ),
                            greetingIcon,
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Text(
                                greeting,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontFamily: font1,
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(20.0)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.7),
                                  offset: const Offset(0.0, 3.0),
                                  blurRadius: 15.0,
                                )
                              ]),
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 40.0),
                            child: Column(
                              children: <Widget>[
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 40),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      attlocat == '0' && freco == '0'
                                          ? Column(
                                              children: <Widget>[
                                                Material(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          100.0),
                                                  color: Colors.purple
                                                      .withOpacity(0.1),
                                                  child: IconButton(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            15.0),
                                                    icon: const Icon(
                                                        Icons.fingerprint),
                                                    color: Colors.purple,
                                                    iconSize: 30.0,
                                                    onPressed: () {
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (_) =>
                                                                  const MarkAttendanceScreen()));
                                                    },
                                                  ),
                                                ),
                                                const SizedBox(height: 10),
                                                Column(
                                                  children: const [
                                                    Text('Mark',
                                                        style: TextStyle(
                                                            color:
                                                                Colors.black54,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontFamily: font1,
                                                            fontSize: 14)),
                                                    Text('Attendance',
                                                        style: TextStyle(
                                                            color:
                                                                Colors.black54,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontFamily: font1,
                                                            fontSize: 14)),
                                                  ],
                                                )
                                              ],
                                            )
                                          : attlocat == '1' && freco == '0'
                                              ? Column(
                                                  children: <Widget>[
                                                    Material(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              100.0),
                                                      color: Colors.purple
                                                          .withOpacity(0.1),
                                                      child: IconButton(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(15.0),
                                                        icon: const Icon(
                                                            Icons.fingerprint),
                                                        color: Colors.purple,
                                                        iconSize: 30.0,
                                                        onPressed: () {
                                                          Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder: (_) =>
                                                                      const MarkAttendanceScreen()));
                                                          return;
                                                          // BlocProvider.of<
                                                          //             NavigationBloc>(
                                                          //         context)
                                                          //     .add(NavigationEvents
                                                          //         .MyAttendanceClickedEvent);
                                                        },
                                                      ),
                                                    ),
                                                    const SizedBox(height: 10),
                                                    Column(
                                                      children: const [
                                                        Text('Mark',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .black54,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontFamily:
                                                                    font1,
                                                                fontSize: 14)),
                                                        Text('Attendance',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .black54,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontFamily:
                                                                    font1,
                                                                fontSize: 14)),
                                                      ],
                                                    )
                                                  ],
                                                )
                                              : attlocat == '0' && freco == '1'
                                                  ? Column(
                                                      children: <Widget>[
                                                        Material(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      100.0),
                                                          color: Colors.purple
                                                              .withOpacity(0.1),
                                                          child: IconButton(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(15.0),
                                                            icon: const Icon(Icons
                                                                .fingerprint),
                                                            color:
                                                                Colors.purple,
                                                            iconSize: 30.0,
                                                            onPressed: () {
                                                              Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                      builder:
                                                                          (_) =>
                                                                              const MarkAttendanceScreen()));
                                                              return;
                                                              // set state while we fetch data from API
                                                              // BlocProvider.of<
                                                              //             NavigationBloc>(
                                                              //         context)
                                                              //     .add(NavigationEvents
                                                              //         .Markwithdate);
                                                            },
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            height: 10),
                                                        Column(
                                                          children: const [
                                                            Text('Mark',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .black54,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontFamily:
                                                                        font1,
                                                                    fontSize:
                                                                        14)),
                                                            Text('Attendance',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .black54,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontFamily:
                                                                        font1,
                                                                    fontSize:
                                                                        14)),
                                                          ],
                                                        )
                                                      ],
                                                    )
                                                  : attlocat == '1' &&
                                                          freco == '1'
                                                      ? Column(
                                                          children: <Widget>[
                                                            Material(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          100.0),
                                                              color: Colors
                                                                  .purple
                                                                  .withOpacity(
                                                                      0.1),
                                                              child: IconButton(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .all(
                                                                        15.0),
                                                                icon: const Icon(
                                                                    Icons
                                                                        .fingerprint),
                                                                color: Colors
                                                                    .purple,
                                                                iconSize: 30.0,
                                                                onPressed: () {
                                                                  Navigator.push(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                          builder: (_) =>
                                                                              const MarkAttendanceScreen()));
                                                                  return;
                                                                  // set state while we fetch data from API
                                                                  // BlocProvider.of<
                                                                  //             NavigationBloc>(
                                                                  //         context)
                                                                  //     .add(NavigationEvents
                                                                  //         .MyAttendanceClickedEvent);
                                                                },
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                                height: 10),
                                                            Column(
                                                              children: const [
                                                                Text('Mark',
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .black54,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        fontFamily:
                                                                            font1,
                                                                        fontSize:
                                                                            14)),
                                                                Text(
                                                                    'Attendance',
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .black54,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        fontFamily:
                                                                            font1,
                                                                        fontSize:
                                                                            14)),
                                                              ],
                                                            )
                                                          ],
                                                        )
                                                      : Column(
                                                          children: <Widget>[
                                                            Material(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          100.0),
                                                              color: Colors
                                                                  .purple
                                                                  .withOpacity(
                                                                      0.1),
                                                              child: IconButton(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .all(
                                                                        15.0),
                                                                icon: const Icon(
                                                                    Icons
                                                                        .fingerprint),
                                                                color: Colors
                                                                    .purple,
                                                                iconSize: 30.0,
                                                                onPressed: () {
                                                                  Navigator.push(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                          builder: (_) =>
                                                                              const MarkAttendanceScreen()));
                                                                  return;
                                                                  // set state while we fetch data from API
                                                                  // BlocProvider.of<
                                                                  //             NavigationBloc>(
                                                                  //         context)
                                                                  //     .add(NavigationEvents
                                                                  //         .MyAttendanceClickedEvent);
                                                                },
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                                height: 10),
                                                            Column(
                                                              children: const [
                                                                Text('Mark',
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .black54,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        fontFamily:
                                                                            font1,
                                                                        fontSize:
                                                                            14)),
                                                                Text(
                                                                    'Attendance',
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .black54,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        fontFamily:
                                                                            font1,
                                                                        fontSize:
                                                                            14)),
                                                              ],
                                                            )
                                                          ],
                                                        ),
                                      Column(
                                        children: <Widget>[
                                          Material(
                                            borderRadius:
                                                BorderRadius.circular(100.0),
                                            color: Colors.blue.withOpacity(0.1),
                                            child: IconButton(
                                              padding:
                                                  const EdgeInsets.all(15.0),
                                              icon: const Icon(
                                                  Icons.airline_seat_flat),
                                              color: Colors.blue,
                                              iconSize: 30.0,
                                              onPressed: () {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (_) =>
                                                            const ApplyLeave()));
                                              },
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          Column(
                                            children: const [
                                              Text('Apply',
                                                  style: TextStyle(
                                                      color: Colors.black54,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontFamily: font1,
                                                      fontSize: 14)),
                                              Text('Leave',
                                                  style: TextStyle(
                                                      color: Colors.black54,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontFamily: font1,
                                                      fontSize: 14)),
                                            ],
                                          )
                                        ],
                                      ),
                                      Column(
                                        children: <Widget>[
                                          Material(
                                            borderRadius:
                                                BorderRadius.circular(100.0),
                                            color:
                                                Colors.orange.withOpacity(0.1),
                                            child: IconButton(
                                              padding:
                                                  const EdgeInsets.all(15.0),
                                              icon: const Icon(Icons.receipt),
                                              color: Colors.orange,
                                              iconSize: 30.0,
                                              onPressed: () {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (_) =>
                                                            const MyHoliday()));
                                              },
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          Column(
                                            children: const [
                                              Text('Holiday',
                                                  style: TextStyle(
                                                      color: Colors.black54,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontFamily: font1,
                                                      fontSize: 14)),
                                              Text('List',
                                                  style: TextStyle(
                                                      color: Colors.black54,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontFamily: font1,
                                                      fontSize: 14)),
                                            ],
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 40.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Column(
                                        children: <Widget>[
                                          Material(
                                            borderRadius:
                                                BorderRadius.circular(100.0),
                                            color: Colors.blue.withOpacity(0.1),
                                            child: IconButton(
                                              padding:
                                                  const EdgeInsets.all(15.0),
                                              icon: const Icon(
                                                  Icons.analytics_sharp),
                                              color: Colors.blue,
                                              iconSize: 30.0,
                                              onPressed: () {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (_) =>
                                                            const LeaveStatus()));
                                              },
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          Column(
                                            children: const [
                                              Text('Leave',
                                                  style: TextStyle(
                                                      color: Colors.black54,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontFamily: font1,
                                                      fontSize: 14)),
                                              Text('Status',
                                                  style: TextStyle(
                                                      color: Colors.black54,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontFamily: font1,
                                                      fontSize: 14)),
                                            ],
                                          )
                                        ],
                                      ),
                                      Column(
                                        children: <Widget>[
                                          Material(
                                            borderRadius:
                                                BorderRadius.circular(100.0),
                                            color: Colors.purpleAccent
                                                .withOpacity(0.1),
                                            child: IconButton(
                                              padding:
                                                  const EdgeInsets.all(15.0),
                                              icon:
                                                  const Icon(Icons.fingerprint),
                                              color: Colors.purpleAccent,
                                              iconSize: 30.0,
                                              onPressed: () {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (_) =>
                                                            const RequestAttendance()));
                                                return;
                                                // set state while we fetch data from API
                                                // BlocProvider.of<NavigationBloc>(
                                                //         context)
                                                //     .add(
                                                //   NavigationEvents
                                                //       .MyReqAttendanceClickedEvent,
                                                // );
                                              },
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          Column(
                                            children: const [
                                              Text('Request',
                                                  style: TextStyle(
                                                      color: Colors.black54,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontFamily: font1,
                                                      fontSize: 14)),
                                              Text('Attendance',
                                                  style: TextStyle(
                                                      color: Colors.black54,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontFamily: font1,
                                                      fontSize: 14)),
                                            ],
                                          )
                                        ],
                                      ),
                                      Column(
                                        children: <Widget>[
                                          Material(
                                            borderRadius:
                                                BorderRadius.circular(100.0),
                                            color: Colors.deepPurple
                                                .withOpacity(0.1),
                                            child: IconButton(
                                              padding:
                                                  const EdgeInsets.all(15.0),
                                              icon: const Icon(Icons.list_alt),
                                              color: Colors.deepPurple,
                                              iconSize: 30.0,
                                              onPressed: () {
                                                Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                        builder: (_) =>
                                                            const AttendanceHistoryScreen()));
                                              },
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          Column(
                                            children: const [
                                              Text('Attendance',
                                                  style: TextStyle(
                                                      color: Colors.black54,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 14,
                                                      fontFamily: font1)),
                                              Text('History',
                                                  style: TextStyle(
                                                      color: Colors.black54,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 14,
                                                      fontFamily: font1)),
                                            ],
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ]),
                    ),
                  ),
                )
              ],
            ),
            // if (mymgmt == '1')
              // Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              //   const Padding(
              //     padding: EdgeInsets.only(top: 25, right: 30.0, left: 30),
              //     child: Text(
              //       "Manage your team",
              //       style: TextStyle(
              //         fontSize: 16,
              //         fontWeight: FontWeight.bold,
              //         color: Color(0xff072a99),
              //       ),
              //     ),
              //   ),
              //   const SizedBox(height: 10),
              //   SingleChildScrollView(
              //     scrollDirection: Axis.horizontal,
              //     physics: const BouncingScrollPhysics(),
              //     child: Row(
              //       crossAxisAlignment: CrossAxisAlignment.start,
              //       children: <Widget>[
              //         const SizedBox(width: 22),
              //         ManageTeamWidgets(
              //           title: "Manage Team's Reimbursment",
              //           onTap: () => Navigator.push(
              //             context,
              //             MaterialPageRoute(builder: (_) => const TrList()),
              //           ),
              //         ),
              //         ManageTeamWidgets(
              //           title: "Manage Team's Leave",
              //           onTap: () => Navigator.push(
              //             context,
              //             MaterialPageRoute(builder: (_) => const LeaveList()),
              //           ),
              //         ),
              //         ManageTeamWidgets(
              //           title: "Manage Team's Attendance",
              //           onTap: () => Navigator.push(
              //             context,
              //             MaterialPageRoute(
              //                 builder: (_) => const TeamAttList()),
              //           ),
              //         ),
              //       ],
              //     ),
              //   ),
              //   const SizedBox(height: 10),
              // ]),
            Padding(
              padding: const EdgeInsets.fromLTRB(25, 10, 25, 10),
              child: Container(
                height: 255,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.7),
                      offset: const Offset(0.0, 3.0),
                      blurRadius: 8.0,
                    )
                  ],
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  image: const DecorationImage(
                    image: AssetImage("assets/cardb.png"),
                    fit: BoxFit.cover,
                  ),
                ),
                child: loader == 'show'
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
                        ),
                      )
                    : loader != 'error'
                        ? GestureDetector(
                            onTap: widget.profileViewScreenOpener,
                            child: Column(
                              children: [
                                Container(
                                  width: double.infinity,
                                  height: 90.0,
                                  decoration: const BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(10.0),
                                      topRight: Radius.circular(10.0),
                                    ),
                                    color: Colors.white,
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.topRight,
                                      stops: [-0.5, 0.7, 0.8, 0.9],
                                      colors: [
                                        Colors.indigo,
                                        Colors.blue,
                                        Colors.blue,
                                        Colors.blue
                                      ],
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                myname,
                                                style: const TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily: font1,
                                                    color: Colors.white),
                                              ),
                                              RichText(
                                                text: TextSpan(
                                                  children: [
                                                    const TextSpan(
                                                        text: "ID:",
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white54,
                                                            fontSize: 13)),
                                                    TextSpan(
                                                        text: myid,
                                                        style: const TextStyle(
                                                            fontSize: 15)),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (myimg != '' && myimg != null)
                                          Container(
                                            height: 90,
                                            width: 90,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              image: DecorationImage(
                                                image: NetworkImage(myimg),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            10, 8, 10, 0),
                                        child: SizedBox(
                                          height: 60,
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      mydesig,
                                                      style: const TextStyle(
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 20),
                                                    ),
                                                    Text(
                                                      myphone,
                                                      style: const TextStyle(
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const Spacer(),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            const Expanded(
                                              child: Text(
                                                'Virtual ID Card',
                                                style: TextStyle(
                                                  color: Color(0x88072a99),
                                                  fontSize: 18,
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 60,
                                              child: Image.network(
                                                ppic2,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          )
                        : const SizedBox(),
              ),
            )
          ],
        ),
      ),
      // bottomNavigationBar:
      //     const CustomBottomNavigationBar(showLogoutButton: true),
    );
  }
}

class ManageTeamWidgets extends StatelessWidget {
  const ManageTeamWidgets({
    Key key,
    @required this.title,
    @required this.onTap,
  }) : super(key: key);
  final String title;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 2.5,
      child: Card(
        margin: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 6,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontFamily: font1, fontSize: 14, color: Colors.black),
              ),
              ElevatedButton(
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                  const Color(0xff072a99),
                )),
                child: const Text(
                  'Open List',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: onTap,
              )
            ],
          ),
        ),
      ),
    );
  }
}

class CustomShapeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0.0, 390.0 - 200);
    path.quadraticBezierTo(size.width / 2, 280, size.width, 390.0 - 200);
    path.lineTo(size.width, 0.0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
