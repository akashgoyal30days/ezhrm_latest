import 'dart:typed_data';
import 'package:ezhrm/camera_screen.dart';
import 'package:ezhrm/custom_text_field.dart';
import 'package:ezhrm/services/shared_preferences_singleton.dart';
import 'package:ezhrm/upload_type_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'dart:convert';
import 'constants.dart';
import 'drawer.dart';

class DocuMents extends StatefulWidget {
  const DocuMents({Key key}) : super(key: key);

  @override
  _DocuMentsState createState() => _DocuMentsState();
}

class _DocuMentsState extends State<DocuMents> {
  bool visible = true;
  Map data;
  List userData;
  String _mylist;
  var newdata;
  dynamic reasonController = TextEditingController();
  Future<void> _initializeControllerFuture;
  Uint8List imageBytes;

  @override
  void initState() {
    fetchList();
    super.initState();
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
      var uri = "$customurl/controller/process/app/document.php";
      final response = await http.post(uri, body: {
        'uid': SharedPreferencesInstance.getString('uid'),
        'cid': SharedPreferencesInstance.getString('comp_id'),
        'type': 'pending_doc'
      }, headers: <String, String>{
        'Accept': 'application/json',
      });
      data = json.decode(response.body);
      setState(() {
        visible = true;
        userData = data["data"];
        visible = true;
      });
      if (debug == 'yes') {}
    } catch (error) {
      showRetry();
    }
  }

  Future uploadDocumentAPI() async {
    var urii = "$customurl/controller/process/app/document.php";
    final responseneww = await http.post(urii, body: {
      'uid': SharedPreferencesInstance.getString('uid'),
      'cid': SharedPreferencesInstance.getString('comp_id'),
      'type': 'upload_doc',
      'doc_no': reasonController.text,
      'doc_id': _mylist,
      'file': base64.encode(imageBytes)
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
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
              "Uploaded Successfully",
              textAlign: TextAlign.center,
            ),
            backgroundColor: Colors.green,
          ));
          Navigator.pop(context);
        });
      } else if (newdata['status'] == false) {
        setState(() {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
              "Already Uploaded",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
            duration: Duration(seconds: 1),
            backgroundColor: Colors.red,
          ));
          _mylist = null;
          reasonController.clear();
        });
      }
    }
    setState(() {});
  }

  openCamera() async {
    imageBytes = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                const CameraScreen(cameraType: CameraType.rearCamera),
          ),
        ) ??
        imageBytes;
    setState(() {});
  }

  openGallery() async {
    var file =
        await ImagePicker.platform.pickImage(source: ImageSource.gallery);
    if (file == null) return;
    imageBytes = await file.readAsBytes();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CustomDrawer(
          currentScreen: AvailableDrawerScreens.uploadDocuments),
      appBar: AppBar(
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
        title: const Text(
          'Upload Documents',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
      ),
      body: userData == null
          ? Center(
              child: LoadingAnimationWidget.hexagonDots(
                color: const Color(0xff072a99),
                size: 40,
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(10),
              children: [
                const Padding(
                  padding: EdgeInsets.all(11),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Select Pending Documents",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff072a99),
                      ),
                    ),
                  ),
                ),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: DropdownButton<String>(
                      isExpanded: true,
                      underline: const SizedBox(),
                      hint: const Text("Pending Documents"),
                      value: _mylist,
                      items: userData?.map((item) {
                            return DropdownMenuItem(
                              child: Text(
                                item['type'],
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontFamily: font1,
                                ),
                              ),
                              value: item['id'].toString(),
                            );
                          })?.toList() ??
                          [],
                      onChanged: (String newValue) {
                        setState(() {
                          _mylist = newValue;
                        });
                      },
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(11),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Document Serial Number",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff072a99),
                        )),
                  ),
                ),
                CustomTextField(
                  hint: "Enter the Serial Number",
                  controller: reasonController,
                ),
                const Padding(
                  padding: EdgeInsets.all(11),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Choose Document Image",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff072a99),
                        )),
                  ),
                ),
                imageBytes == null
                    ? GestureDetector(
                        onTap: () => showDialog(
                            context: context,
                            builder: (context) => DocumentTypePickerDialogBox(
                                  camera: openCamera,
                                  gallery: openGallery,
                                )),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            SizedBox(height: 20),
                            Icon(
                              Icons.upload_file_outlined,
                              size: 30,
                            ),
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                'Click to Upload an Image',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                            SizedBox(height: 20),
                          ],
                        ))
                    : Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.memory(imageBytes),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextButton.icon(
                                onPressed: () {
                                  imageBytes = null;
                                  setState(() {});
                                },
                                style: ButtonStyle(
                                  foregroundColor:
                                      MaterialStateProperty.all(Colors.red),
                                ),
                                icon: const Icon(Icons.clear),
                                label: const Text("Remove"),
                              ),
                              TextButton.icon(
                                onPressed: () {
                                  showDialog(
                                      context: context,
                                      builder: (context) =>
                                          DocumentTypePickerDialogBox(
                                            camera: openCamera,
                                            gallery: openGallery,
                                          ));
                                },
                                icon: const Icon(Icons.refresh),
                                label: const Text("Replace Image"),
                              ),
                            ],
                          ),
                        ],
                      ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal:8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      if (imageBytes == null || _mylist == null) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text(
                          "Please upload Image/fill all the fields",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 16.0, fontWeight: FontWeight.bold),
                        )));
                        return;
                      }
                      uploadDocumentAPI();
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text(
                          "Please Wait We Are Uploading The Document",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 16.0, fontWeight: FontWeight.bold),
                        ),
                        duration: Duration(seconds: 1),
                        backgroundColor: Colors.black,
                      ));
                      setState(() {
                        userData = null;
                        fetchList();
                        initState();
                      });
                    },
                    child: const Text("Submit"),
                    style: ButtonStyle(
                      padding:
                          MaterialStateProperty.all(const EdgeInsets.all(15)),
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10))),
                      backgroundColor: MaterialStateProperty.all(
                        const Color(0xff072a99),
                      ),
                      elevation: MaterialStateProperty.all(8),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
