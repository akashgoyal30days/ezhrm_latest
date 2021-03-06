import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart';

import 'constants.dart';
import 'main.dart';
import 'services/shared_preferences_singleton.dart';

class GoGreenGlobal {
   static initialize() async {
    log("Gogreen initialized");

    try {
      var body = {
        'uid': SharedPreferencesInstance.getString('uid')??"",
        'cid': SharedPreferencesInstance.getString('comp_id')??"",
        'type': 'go_green',
        'firebase_token': SharedPreferencesInstance.getString('fbasetoken')??"",
        'device_id': SharedPreferencesInstance.getString('deviceid') ?? "",
        'version': version,
        'platform': 'android',
      };
      var apiStartTime = DateTime.now();

      final response = await post(
          "$customurl/controller/process/app/extras.php",
          body: body,
          headers: <String, String>{
            'Accept': 'application/json',
          });
      var apiEndTime = DateTime.now();

      datak = json.decode(response.body);
      log(datak.toString());
      SharedPreferencesInstance.saveLogs(
          response.request.url.toString(), json.encode(body), response.body,
          duration: apiEndTime.difference(apiStartTime).inSeconds);
      if (datak.containsKey('code')) val = datak['code'].toString();
      if (datak['status'].toString() != "true") {
        return await SharedPreferencesInstance.logOut();
      }
      log(datak.toString());
      SharedPreferencesInstance.appInitialization(datak);
      log("Initialized");
      return;
    } catch (error) {
      log("Error in initialized");
      return await SharedPreferencesInstance.logOut();
    }
  }
}

class GoGreenModel {
  final bool backgroundLocationTrackingEnabled,
      faceRecognitionEnabled,
      locationEnabled,
      canSendRequest,
      showUpdateAvailableDialog,
      debugEnable;
  final String companyName, companyLogo;
  final int backgroundLocationInterval;

  const GoGreenModel(
      {this.backgroundLocationTrackingEnabled,
      this.faceRecognitionEnabled,
      this.showUpdateAvailableDialog,
      this.debugEnable,
      this.locationEnabled,
      this.canSendRequest,
      this.companyName,
      this.companyLogo,
      this.backgroundLocationInterval});
}
