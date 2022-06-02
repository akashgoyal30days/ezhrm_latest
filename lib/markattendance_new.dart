import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:ezhrm/login.dart';
import 'package:ezhrm/drawer.dart';
import 'package:ezhrm/main.dart';
import 'package:flutter/material.dart';
import 'package:ezhrm/uploadimg_new.dart';

import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import 'constants.dart';
import 'camera_screen.dart';
import 'attendance_records.dart';
import 'services/shared_preferences_singleton.dart';

class MarkAttendanceScreen extends StatefulWidget {
  const MarkAttendanceScreen({Key key}) : super(key: key);

  @override
  State<MarkAttendanceScreen> createState() => _MarkAttendanceScreenState();
}

class _MarkAttendanceScreenState extends State<MarkAttendanceScreen> {
  // Keeping default longitude and latitude of 30Days Technology Office
  bool showLoadingSpinnerOnTop = false,
      attendanceloadingOverlay = false,
      showTodaysRecords = false,
      imageRequired = goGreenModel.faceRecognitionEnabled,
      locationRequired = goGreenModel.locationEnabled,
      ableToSendRequest = goGreenModel.canSendRequest;
  Position currentPosition =
      Position(latitude: 28.6894989, longitude: 76.9533923);
  final Set<Marker> marker = {};
  final List attendanceRecordsList = [];
  GoogleMapController _googleMapController;
  StreamSubscription locationUpdateStream;
  Uint8List imageBytes;
  String messageOnScreen, attendanceRecordStatus;
  MapType mapType = MapType.normal;
  BuildContext scaffoldContext;

  @override
  void initState() {
    fetchAttendanceRecords();
    super.initState();
  }

  casesWorkflows() async {
    if (!locationRequired && imageRequired) {
      return Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CameraScreen(callBack: getImage),
        ),
      );
    }
    // all other cases are handled by this
    return checkGPSStatus();
  }

  //-------------------START LOCATION FUNCTIONS---------------------------
  checkGPSStatus() async {
    if (!locationRequired) return;
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        try {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
              "Location permission is denied",
              textAlign: TextAlign.center,
            ),
            backgroundColor: Colors.red,
          ));
        } catch (e) {
          //
        }
        Navigator.pop(context);
        return;
      } else if (permission == LocationPermission.deniedForever) {
        try {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
              "Please Goto Settings and give Location Permission",
              textAlign: TextAlign.center,
            ),
            backgroundColor: Colors.red,
          ));
        } catch (e) {
          //
        }
        Navigator.pop(context);
        return;
      }
    }
    var servicestatus = await Geolocator.isLocationServiceEnabled();
    if (!servicestatus) {
      try {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
            "Please Turn your GPS ON",
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.red,
        ));
      } catch (e) {
        //
      }
      Navigator.pop(context);
      return;
    }
    getCurrentLocation();
  }

  getCurrentLocation() async {
    locationUpdateStream =
        Geolocator.getPositionStream(desiredAccuracy: LocationAccuracy.high)
            .listen(updateLocationOnMap);
    updateLocationOnMap(await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    ));
  }

  updateLocationOnMap(Position positon,
      [bool ignoreLastPosition = false]) async {
    if (!mounted) return;
    if (!ignoreLastPosition &&
        currentPosition.latitude == positon.latitude &&
        currentPosition.longitude == positon.longitude) return;
    setState(() {
      showLoadingSpinnerOnTop = true;
    });
    currentPosition = positon;
    setMarkerOnMap();
    await _googleMapController?.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        target: LatLng(currentPosition.latitude, currentPosition.longitude),
        zoom: 18,
      ),
    ));
  }

  setMarkerOnMap() => setState(
        () {
          marker.clear();
          marker.add(Marker(
            markerId: MarkerId("User Location"),
            infoWindow: const InfoWindow(
                title: "This Location will be used for attendance"),
            visible: true,
            icon:
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
            position:
                LatLng(currentPosition.latitude, currentPosition.longitude),
          ));
          showLoadingSpinnerOnTop = false;
        },
      );

  changeMapType() => setState(() {
        mapType =
            mapType == MapType.normal ? MapType.satellite : MapType.normal;
      });

  shareLocation() => Share.text(
        'My Location Sharing',
        'Hello Sir!\n'
            '${SharedPreferencesInstance.getString('username')} this side.\n'
            'I am sharing my current working location. Please add it in HRM software, so that i can Mark my Attendance from Here.\nEmployee ID: ${SharedPreferencesInstance.getString('empid')}\nLatitude: ${currentPosition.latitude}\nLongitude: ${currentPosition.longitude} ',
        'text/plain',
      );

  //-------------------END LOCATION FUNCTIONS---------------------------

  //------------------ START IMAGE FUNCTIONS---------------------------

  getImage(Uint8List imageBytes) {
    this.imageBytes = imageBytes;
    markAttendanceAPI();
  }

  //-------------------END IMAGE FUNCTIONS---------------------------

  //------------------ START API FUNCTIONS---------------------------

  markAttendanceAPI({bool sendRequest = false}) async {
    if (sendRequest && !ableToSendRequest) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Cannot Send Request",
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    setState(() {
      attendanceloadingOverlay = true;
    });
    try {
      Map<String, String> body = {
        'type': 'mark',
        'uid': SharedPreferencesInstance.getString('uid') ?? "",
        'cid': SharedPreferencesInstance.getString('comp_id') ?? "",
        'device_id': SharedPreferencesInstance.getString('deviceid') ?? "",
        'lat': locationRequired ? currentPosition.latitude.toString() : "",
        'long': locationRequired ? currentPosition.longitude.toString() : "",
        'img_data': imageRequired ? base64.encode(imageBytes) : "",
        'send_request': ableToSendRequest && sendRequest ? "1" : "0"
      };
      final response = await http.post(
        "$customurl/controller/process/app/attendance_mark.php",
        body: body,
        headers: <String, String>{
          'Accept': 'application/json',
        },
      );

      log(response.body);
      Map data = json.decode(response.body);
      log(data.toString());

      if (!data.containsKey("code")) {
        setState(() {
          attendanceloadingOverlay = false;
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Error Occured"),
            backgroundColor: Color(0xAAF44336),
            behavior: SnackBarBehavior.floating,
          ));
        });
        return;
      }

      setState(() {
        attendanceloadingOverlay = false;
      });
      if (data["code"].toString() == "1001") return code1001(data, sendRequest);
      if (data["code"].toString() == "1002") return code1002(data);
      if (data["code"].toString() == "1003") return code1003(data);

      // logouts if code is not equal to 1001 or 1002
      await SharedPreferencesInstance.logOut();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Invalid Device"),
        backgroundColor: Color(0xAAF44336),
        behavior: SnackBarBehavior.floating,
      ));
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => const Login(),
          ),
          (route) => false);
    } catch (e) {
      setState(() {
        attendanceloadingOverlay = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Error Occured, Try Again",
            textAlign: TextAlign.center,
          ),
          backgroundColor: Color(0xFFF44336),
        ),
      );
    }
  }

  code1001(data, bool sendRequestType) async {
    if (data["status"].toString() == "true") {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: sendRequestType
            ? const Text(
                "Request Sent successfully",
                textAlign: TextAlign.center,
              )
            : const Text(
                "Attendance Marked successfully",
                textAlign: TextAlign.center,
              ),
        backgroundColor: Colors.green,
      ));
      fetchAttendanceRecords();
      return;
    }
    await showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: const Text(
                "Error Occured",
                style: TextStyle(color: Colors.red),
              ),
              content: Text(data["msg"]),
              actions: [
                TextButton(
                  child: const Text("Try Again"),
                  onPressed: Navigator.of(context).pop,
                  style: ButtonStyle(
                    foregroundColor: MaterialStateProperty.all(
                      const Color(0xff072a99),
                    ),
                  ),
                ),
              ],
            ));
  }

  code1002(data) async {
    if (!ableToSendRequest) return;
    bool selectedSendRequest = await showDialog(
            context: context,
            builder: (_) => AlertDialog(
                  title: const Text(
                    "Error Occured",
                    style: TextStyle(color: Colors.red),
                  ),
                  content: Text(data['msg']),
                  actions: [
                    TextButton(
                      child: const Text("Cancel"),
                      onPressed: Navigator.of(context).pop,
                      style: ButtonStyle(
                          foregroundColor: MaterialStateProperty.all(
                              const Color(0xff072a99))),
                    ),
                    TextButton(
                      child: const Text("Send Request"),
                      onPressed: () => Navigator.of(context).pop(true),
                      style: ButtonStyle(
                          foregroundColor: MaterialStateProperty.all(
                              const Color(0xff072a99))),
                    ),
                  ],
                )) ??
        false;
    if (!selectedSendRequest) return;
    markAttendanceAPI(sendRequest: true);
  }

  code1003(data) async {
    bool selectedSendRequest = await showDialog(
            context: context,
            builder: (_) => AlertDialog(
                  title: const Text(
                    "Error Occured",
                    style: TextStyle(color: Colors.red),
                  ),
                  content: Text(data["msg"]),
                  actions: [
                    TextButton(
                      child: const Text("Send Request"),
                      onPressed: () {
                        Navigator.pop(context, true);
                      },
                      style: ButtonStyle(
                        foregroundColor: MaterialStateProperty.all(
                          const Color(0xff072a99),
                        ),
                      ),
                    ),
                    TextButton(
                      child: const Text("Upload Images"),
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const UploadImg()),
                            (route) => route.isFirst);
                      },
                      style: ButtonStyle(
                        foregroundColor: MaterialStateProperty.all(
                          const Color(0xff072a99),
                        ),
                      ),
                    ),
                  ],
                )) ??
        false;
    if (!selectedSendRequest) return;
    markAttendanceAPI(sendRequest: true);
  }

  fetchAttendanceRecords() async {
    final response = await http
        .post("$customurl/controller/process/app/attendance.php", body: {
      'type': 'get_att_fetch',
      'cid': SharedPreferencesInstance.getString('comp_id'),
      'uid': SharedPreferencesInstance.getString('uid'),
    }, headers: <String, String>{
      'Accept': 'application/json',
    });
    var data = json.decode(response.body);
    String status = data['status']?.toString() ?? "";
    if (status != "true") {
      casesWorkflows();
      return;
    }
    attendanceRecordsList.clear();
    attendanceRecordsList.addAll(data["data"]);
    String creditStatus = data["credit"].toString();
    attendanceRecordStatus = creditStatus == "3"
        ? "Full Day"
        : creditStatus == "4"
            ? "Half Day"
            : creditStatus == "7"
                ? "Submitted"
                : "Pending";
    setState(() {});
    if (attendanceRecordsList.isEmpty) {
      casesWorkflows();
      return;
    }
    bool clickedOnProceed = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
                builder: (_) => AttendanceRecordScreen(
                      attendanceRecordsList,
                      attendanceRecordStatus,
                      openedDirectly: true,
                    ))) ??
        false;
    if (!clickedOnProceed) return Navigator.pop(context);
    casesWorkflows();
  }

  //------------------ END API FUNCTIONS---------------------------

  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    scaffoldContext = context;
    return Scaffold(
      key: scaffoldKey,
      drawer: const CustomDrawer(
          currentScreen: AvailableDrawerScreens.markAttendance),
      body: Stack(
        children: [
          if (locationRequired)
            GoogleMap(
              // Center Of India
              initialCameraPosition: const CameraPosition(
                target: LatLng(22.9734, 78.9629),
                zoom: 18,
              ),
              mapType: mapType,
              markers: marker,
              onMapCreated: (controller) async {
                _googleMapController = controller;
                if (!locationRequired) return;
                await _googleMapController
                    ?.animateCamera(CameraUpdate.newCameraPosition(
                  CameraPosition(
                    target: LatLng(
                        currentPosition.latitude, currentPosition.longitude),
                    zoom: 18,
                  ),
                ));
              },
              mapToolbarEnabled: true,
              compassEnabled: true,
              myLocationEnabled: locationRequired,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
            ),
          if (!locationRequired)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "To submit your attendance, please click on the button below",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          SafeArea(
            child: SizedBox.expand(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        MapButton(
                          Icons.menu,
                          onTap: scaffoldKey.currentState?.openDrawer,
                        ),
                        const Spacer(),
                        if (showLoadingSpinnerOnTop)
                          Container(
                            width: 34,
                            height: 34,
                            padding: const EdgeInsets.all(4),
                            margin: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                                color: Color(0xff072a99),
                                shape: BoxShape.circle),
                            child: const CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ),
                        if (attendanceRecordsList.isNotEmpty)
                          MapButton(
                            Icons.how_to_reg,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AttendanceRecordScreen(
                                    attendanceRecordsList,
                                    attendanceRecordStatus,
                                  ),
                                ),
                              );
                            },
                          ),
                        if (locationRequired)
                          Row(
                            children: [
                              MapButton(
                                Icons.share,
                                onTap: shareLocation,
                              ),
                              MapButton(
                                mapType == MapType.satellite
                                    ? Icons.apartment
                                    : Icons.map,
                                onTap: changeMapType,
                              ),
                              MapButton(
                                Icons.my_location_sharp,
                                onTap: () async => updateLocationOnMap(
                                    await Geolocator.getCurrentPosition(
                                      desiredAccuracy: LocationAccuracy.high,
                                    ),
                                    true),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Hero(
                            tag: "The Button",
                            child: ElevatedButton(
                              onPressed: () async {
                                if (imageRequired) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          CameraScreen(callBack: getImage),
                                    ),
                                  );
                                } else {
                                  markAttendanceAPI();
                                }
                              },
                              child: attendanceRecordStatus == "Submitted"
                                  ? const Text("Check Out")
                                  : const Text("Check In"),
                              style: ButtonStyle(
                                padding: MaterialStateProperty.all(
                                    const EdgeInsets.all(15)),
                                shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10))),
                                backgroundColor: MaterialStateProperty.all(
                                  const Color(0xff072a99),
                                ),
                                elevation: MaterialStateProperty.all(8),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (attendanceloadingOverlay)
            SizedBox.expand(
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    LoadingAnimationWidget.threeRotatingDots(
                      color: Colors.white70,
                      size: 60,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(messageOnScreen ?? "Processing",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          )),
                    )
                  ],
                ),
                decoration: const BoxDecoration(
                  color: Color(0xcc072a99),
                ),
              ),
            )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _googleMapController?.dispose();
    locationUpdateStream?.cancel();
    super.dispose();
  }
}
