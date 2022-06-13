import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
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
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

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
  bool showLoadingSpinnerOnTop = false,
      attendanceloadingOverlay = false,
      checkInButtonLoading = false,
      showTodaysRecords = false,
      showOutOfRangeButton = false,
      imageRequired = goGreenModel.faceRecognitionEnabled,
      locationRequired = goGreenModel.locationEnabled,
      ableToSendRequest = goGreenModel.canSendRequest;
  Position currentPosition;
  final Set<Marker> marker = {};
  final List attendanceRecordsList = [];
  GoogleMapController _googleMapController;
  StreamSubscription locationUpdateStream;
  LatLng initialLocation;
  Uint8List imageBytes;
  String messageOnScreen, attendanceRecordStatus;
  MapType mapType = MapType.normal;
  BuildContext scaffoldContext;

  @override
  void initState() {
    fetchAttendanceRecords();
    var position = SharedPreferencesInstance.getLastLocation();
    initialLocation = LatLng(position.latitude, position.longitude);
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
      var permissions = await PermissionHandler().requestPermissions([
        PermissionGroup.locationWhenInUse,
        PermissionGroup.location,
      ]);
      if (permissions[PermissionGroup.locationWhenInUse] ==
              PermissionStatus.denied &&
          permissions[PermissionGroup.location] == PermissionStatus.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
              "Location permission is denied",
              textAlign: TextAlign.center,
            ),
            backgroundColor: Colors.red,
          ));
        }
        Navigator.pop(context);
        return;
      }
    }
    var locationEnabled = await Geolocator.isLocationServiceEnabled();
    if (!locationEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
            "Please Turn your GPS ON",
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.red,
        ));
      }
      Navigator.pop(context);
      return;
    }
    startLocationStreaming();
  }

  startLocationStreaming() async {
    locationUpdateStream =
        Geolocator.getPositionStream(desiredAccuracy: LocationAccuracy.high)
            .listen(updateLocationOnMap);
  }

  Future<bool> checkUserLocationValidity() async {
    showCheckInButtonLoading(true);
    try {
      var response = await http
          .post("$customurl/controller/process/app/attendance_mark.php", body: {
        'type': 'verify_location',
        'uid': SharedPreferencesInstance.getString('uid') ?? "",
        'cid': SharedPreferencesInstance.getString('comp_id') ?? "",
        'lat': locationRequired ? currentPosition.latitude.toString() : "",
        'long': locationRequired ? currentPosition.longitude.toString() : "",
      });
      var responseBody = json.decode(response.body);
      log(responseBody.toString());
      showOutOfRangeButton = responseBody['status'].toString() != "true";
      showCheckInButtonLoading(false);
      if (showOutOfRangeButton) {
        locationOutOfRangeDialog();
      }
      return !showOutOfRangeButton;
    } catch (e) {
      log(e.toString());
      // ScaffoldMessenger.of(context).showSnackBar(
      showCheckInButtonLoading(false);
      //   const SnackBar(
      //     content: Text(
      //       "Please Try Again",
      //       textAlign: TextAlign.center,
      //     ),
      //     backgroundColor: Colors.red,
      //   ),
      // );
    }
    return false;
  }

  updateLocationOnMap(Position positon) async {
    if (!mounted) return;
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
    // log('length of png image bytes ${imageBytes.length / 1000}kB');
    // log('length of base64 bytes ${base64.encode(imageBytes).length / 1000}kB');
    // log('length of jpeg bytes ${image.encodeJpg(image.decodeImage(imageBytes), quality: 50).length / 1000}kB');
    faceRecogAPI();
  }

  //-------------------END IMAGE FUNCTIONS---------------------------

  //------------------ START API FUNCTIONS---------------------------

  faceRecogAPI() async {
    var apiStart = DateTime.now();
    showProcessingOverlay(true);
    try {
      final tokenResponse = await http.post(
        "$customurl/controller/process/app/attendance_mark.php",
        body: {
          'type': 'face_token',
          'uid': SharedPreferencesInstance.getString('uid') ?? "",
          'cid': SharedPreferencesInstance.getString('comp_id') ?? "",
        },
        headers: <String, String>{
          'Accept': 'application/json',
        },
      );
      log(tokenResponse.body);
      var token = json.decode(tokenResponse.body)['token'];
      log("token is $token");
      // FACE RECOG REQUEST
      var request = http.MultipartRequest(
        "POST",
        Uri.parse(
            "http://164.52.223.146/verify?model_name=Facenet&distance_metric=cosine"),
      );
      request.headers['Authorization'] = 'Bearer $token';
      request.fields.addAll({
        'employee_id': SharedPreferencesInstance.getString('uid') ?? "",
        'company_id': SharedPreferencesInstance.getString('comp_id') ?? "",
      });
      Directory cacheDirectory = await getTemporaryDirectory();
      File file = await File(cacheDirectory.path +
              "/${DateTime.now().millisecondsSinceEpoch}.png")
          .writeAsBytes(imageBytes);
      request.files
          .add(await http.MultipartFile.fromPath('image_file', file.path));
      var response = await http.Response.fromStream(await request.send());
      log(response.body);
      var apiEnd = DateTime.now();
      SharedPreferencesInstance.saveLogs(
          "both token + face recog",
          json.encode(request.fields),
          response.body,
          apiEnd.difference(apiStart).inSeconds);
      markAttendanceAPI(
          faceDistance: json.decode(response.body)["distance"].toString());
    } catch (e) {
      log(e.toString());
      showProcessingOverlay(false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Error Occured, Try Again",
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  markAttendanceAPI(
      {bool sendRequest = false, String faceDistance = ""}) async {
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
      showProcessingOverlay(false);
      return;
    }
    if (currentPosition == null && locationRequired) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Location not captured, please enable location",
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.red,
        ),
      );
      showProcessingOverlay(false);
      return;
    }
    showProcessingOverlay(true);

    try {
      var apiStartTime = DateTime.now();
      Map body = {
        'type': 'mark_attendance',
        'uid': SharedPreferencesInstance.getString('uid') ?? "",
        'cid': SharedPreferencesInstance.getString('comp_id') ?? "",
        'device_id': SharedPreferencesInstance.getString('deviceid') ?? "",
        'lat': locationRequired ? currentPosition.latitude.toString() : "",
        'long': locationRequired ? currentPosition.longitude.toString() : "",
        'face_distance': faceDistance,
        'img_data': sendRequest ? base64.encode(imageBytes) : "",
        'send_request': ableToSendRequest && sendRequest ? "1" : "0"
      };
      final response = await http.post(
        "$customurl/controller/process/app/attendance_mark.php",
        body: body,
        headers: <String, String>{
          'Accept': 'application/json',
        },
      );
      log("url :" + response.request.url.toString());
      log("data we are sending in mark_attendance" + body.toString());
      var apiEndTime = DateTime.now();
      var logBody = {
        'type': 'mark_attendance',
        'uid': SharedPreferencesInstance.getString('uid') ?? "",
        'cid': SharedPreferencesInstance.getString('comp_id') ?? "",
        'device_id': SharedPreferencesInstance.getString('deviceid') ?? "",
        'lat': locationRequired ? currentPosition.latitude.toString() : "",
        'long': locationRequired ? currentPosition.longitude.toString() : "",
        'face_distance': faceDistance,
        'img_data': imageRequired ? "sent Data (Too Long To display)" : "",
        'send_request': ableToSendRequest && sendRequest ? "1" : "0"
      };
      SharedPreferencesInstance.saveLogs(
        response.request.url.toString(),
        json.encode(logBody),
        response.body,
        apiEndTime.difference(apiStartTime).inSeconds,
      );
      SharedPreferencesInstance.saveLastLocation(currentPosition);
      log("MARK ATTENDANCE RESPONSE :" + response.body);
      Map data = json.decode(response.body);
      showProcessingOverlay(false);

      if (!data.containsKey("code")) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Error Occured"),
          backgroundColor: Colors.red,
        ));
        return;
      }

      switch (data["code"].toString()) {
        case "1001":
          return code1001(data, sendRequest);
        case "1002":
          return code1002(data);
        case "1003":
          return code1003(data);
      }

      // logouts if code is not equal to 1001 or 1002 or 1003
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
      log(e.toString());
      showProcessingOverlay(false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Error Occured, Try Again",
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.red,
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

  showProcessingOverlay(bool value) {
    setState(() {
      attendanceloadingOverlay = value;
    });
  }

  showCheckInButtonLoading(bool value) {
    setState(() {
      checkInButtonLoading = value;
    });
  }

  locationOutOfRangeDialog() async {
    bool sendRequestSelected = await showDialog(
            context: context,
            builder: (_) => AlertDialog(
                  title: const Text(
                    "Out of Range",
                    style: TextStyle(color: Colors.red),
                  ),
                  content: RichText(
                      text: const TextSpan(
                          style: TextStyle(color: Colors.black, fontSize: 16),
                          children: [
                        TextSpan(
                            text: "Sorry!  Out of  Range\n",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        TextSpan(text: "Do you want to send request to admin?")
                      ])),
                  actions: [
                    TextButton(
                      child: const Text("Try Again"),
                      onPressed: () {
                        Navigator.pop(context);
                        checkUserLocationValidity();
                      },
                      style: ButtonStyle(
                        foregroundColor: MaterialStateProperty.all(
                          const Color(0xff072a99),
                        ),
                      ),
                    ),
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
                  ],
                )) ??
        false;
    if (sendRequestSelected) {
      imageBytes = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const CameraScreen(),
        ),
      );
      if (imageBytes == null) return;
      markAttendanceAPI(sendRequest: true);
    }
  }

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
            currentPosition == null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Fetching location....",
                          style:
                              TextStyle(color: Color(0xff072a99), fontSize: 20),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        CircularProgressIndicator(
                          color: Color(0xff072a99),
                        ),
                      ],
                    ),
                  )
                : GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: initialLocation,
                      zoom: 18,
                    ),
                    mapType: mapType,
                    markers: marker,
                    onMapCreated: (controller) async {
                      _googleMapController = controller;
                      if (!locationRequired) return;
                      if (currentPosition != null) {
                        await _googleMapController
                            ?.animateCamera(CameraUpdate.newCameraPosition(
                          CameraPosition(
                            target: LatLng(
                              currentPosition.latitude,
                              currentPosition.longitude,
                            ),
                            zoom: 18,
                          ),
                        ));
                      }
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
                                )),
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
                          child: checkInButtonLoading
                              ? CircleAvatar(
                                  radius: 22,
                                  backgroundColor: const Color(0xff072a99),
                                  child:
                                      LoadingAnimationWidget.threeRotatingDots(
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                )
                              : showOutOfRangeButton
                                  ? IntrinsicHeight(
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Hero(
                                              tag: "The Button",
                                              child: ElevatedButton(
                                                onPressed: () async {
                                                  // locationOutOfRangeDialog();
                                                },
                                                child: const Text(
                                                    "Location is out of Range"),
                                                style: ButtonStyle(
                                                  padding:
                                                      MaterialStateProperty.all(
                                                          const EdgeInsets.all(
                                                              15)),
                                                  shape:
                                                      MaterialStateProperty.all(
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10))),
                                                  backgroundColor:
                                                      MaterialStateProperty.all(
                                                    Colors.red,
                                                  ),
                                                  elevation:
                                                      MaterialStateProperty.all(
                                                          8),
                                                ),
                                              ),
                                            ),
                                          ),
                                          // const SizedBox(width: 8),
                                          // Container(
                                          //   decoration: BoxDecoration(
                                          //     borderRadius:
                                          //         BorderRadius.circular(8),
                                          //     color: Colors.white,
                                          //   ),
                                          //   width: MediaQuery.of(context)
                                          //           .size
                                          //           .width *
                                          //       0.2,
                                          //   child: Column(
                                          //     mainAxisAlignment:
                                          //         MainAxisAlignment.center,
                                          //     children: [
                                          //       GestureDetector(
                                          //         onTap:
                                          //             checkUserLocationValidity,
                                          //         child: const Icon(
                                          //           Icons.refresh,
                                          //           size: 26,
                                          //           color: Color(0xff072a99),
                                          //         ),
                                          //       ),
                                          //     ],
                                          //   ),
                                          // ),
                                        ],
                                      ),
                                    )
                                  : Hero(
                                      tag: "The Button",
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          if (locationRequired) {
                                            var value =
                                                await checkUserLocationValidity();
                                            if (!value) return;
                                          }

                                          if (imageRequired) {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    CameraScreen(
                                                        callBack: getImage),
                                              ),
                                            );
                                          } else {
                                            markAttendanceAPI();
                                          }
                                        },
                                        child: attendanceRecordStatus ==
                                                "Submitted"
                                            ? const Text("Check Out")
                                            : const Text("Check In"),
                                        style: ButtonStyle(
                                          padding: MaterialStateProperty.all(
                                              const EdgeInsets.all(15)),
                                          shape: MaterialStateProperty.all(
                                              RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10))),
                                          backgroundColor:
                                              MaterialStateProperty.all(
                                            const Color(0xff072a99),
                                          ),
                                          elevation:
                                              MaterialStateProperty.all(8),
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
