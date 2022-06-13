import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:ezhrm/main.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';

// THIS SCREEN RETUENS BYTES OF IMAGE IN Navigator.pop(context)

enum CameraType {frontCamera, rearCamera}

class CameraScreen extends StatefulWidget {
  const CameraScreen(
      {this.callBack,
      this.showFrame = true,
      this.cameraType = CameraType.frontCamera,
      Key key})
      : super(key: key);
  final Function(Uint8List) callBack;
  final CameraType cameraType;
  final bool showFrame;
  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController _cameraController;
  final _screenshotController = ScreenshotController();
  bool showLoading = true,
      showImagePreview = false,
      currentlyTakingScreenshot = false;
  Uint8List savedImageBytes;

  @override
  void initState() {
    initializeCamera();
    super.initState();
  }

  initializeCamera() async {
    _cameraController = CameraController(
      widget.cameraType == CameraType.frontCamera ? cameras[1] : cameras[0],
      ResolutionPreset.max,
      enableAudio: false,
    );
    await _cameraController.initialize();
    setState(() {
      showLoading = false;
    });
  }

  capturePhoto() async {
    var tempPath = join(
      (await getTemporaryDirectory()).path,
      '${DateTime.now()}.png',
    );
    await _cameraController.takePicture(tempPath);
    savedImageBytes = File(tempPath).readAsBytesSync();
    setState(() {
      showImagePreview = true;
    });
  }

  done() async {
    setState(() {
      currentlyTakingScreenshot = true;
    });
    var bytes = await _screenshotController.capture();
    if (widget.callBack != null) widget.callBack(bytes);
    Navigator.pop(this.context, bytes);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
            child: showLoading
                ? Center(
                    child: LoadingAnimationWidget.newtonCradle(
                      color: Colors.white,
                      size: 80,
                    ),
                  )
                : Column(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onDoubleTap: () {
                            if (showImagePreview) return;
                            capturePhoto();
                          },
                          child: Screenshot(
                            controller: _screenshotController,
                            child: Material(
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  showImagePreview
                                      ? Transform(
                                          alignment: Alignment.center,
                                          transform: widget.cameraType ==
                                                  CameraType.frontCamera
                                              ? Matrix4.rotationY(math.pi)
                                              : Matrix4.rotationX(0),
                                          child: Image.memory(
                                            savedImageBytes,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : CameraPreview(_cameraController),
                                  if (widget.cameraType ==
                                          CameraType.frontCamera &&
                                      widget.showFrame)
                                    ColorFiltered(
                                      colorFilter: const ColorFilter.mode(
                                        Colors.black,
                                        BlendMode.srcOut,
                                      ), // This one will create the magic
                                      child: Stack(
                                        fit: StackFit.expand,
                                        children: [
                                          Container(
                                            decoration: const BoxDecoration(
                                              color: Colors.black,
                                              backgroundBlendMode:
                                                  BlendMode.dstOut,
                                            ), // This one will handle background + difference out
                                          ),
                                          SizedBox.expand(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(18.0),
                                              child: ClipOval(
                                                child: Container(
                                                  decoration:
                                                      const BoxDecoration(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (widget.showFrame &&
                          widget.cameraType == CameraType.frontCamera)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              showImagePreview
                                  ? "Please make sure that your face is inside the Frame"
                                  : "Please Keep Your Face Inside The Frame",
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                      const SizedBox(height: 8),
                      SizedBox(
                          height: 56,
                          child: !showImagePreview
                              ? Stack(
                                  children: [
                                    Row(
                                      children: [
                                        const Spacer(flex: 4),
                                        GestureDetector(
                                          onTap: Navigator.of(context).pop,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: const [
                                              Icon(
                                                Icons.clear,
                                                color: Colors.white,
                                              ),
                                              Text(
                                                "Cancel",
                                                style: TextStyle(
                                                    color: Colors.white),
                                              )
                                            ],
                                          ),
                                        ),
                                        const Spacer(
                                          flex: 1,
                                        ),
                                      ],
                                    ),
                                    GestureDetector(
                                      onTap: capturePhoto,
                                      child: const _ShutterButton(),
                                    ),
                                  ],
                                )
                              : SizedBox(
                                  height: 56,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            savedImageBytes = null;
                                            showImagePreview = false;
                                          });
                                        },
                                        child: Column(
                                          children: const [
                                            Icon(
                                              Icons.refresh,
                                              color: Colors.white,
                                              size: 30,
                                            ),
                                            Text(
                                              "Retake",
                                              style: TextStyle(
                                                  color: Colors.white),
                                            )
                                          ],
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: done,
                                        child: Column(
                                          children: const [
                                            Icon(
                                              Icons.done,
                                              color: Colors.green,
                                              size: 30,
                                            ),
                                            Text(
                                              "Done",
                                              style: TextStyle(
                                                  color: Colors.green),
                                            )
                                          ],
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: Navigator.of(context).pop,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: const [
                                            Icon(
                                              Icons.clear,
                                              color: Colors.white,
                                            ),
                                            Text(
                                              "Cancel",
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                )),
                      const SizedBox(height: 10),
                    ],
                  )));
  }

  //----------START Widget Functions-----------

  ColorFiltered ovalShape() => ColorFiltered(
        colorFilter: const ColorFilter.mode(
          Colors.black,
          BlendMode.srcOut,
        ), // This one will create the magic
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: const BoxDecoration(
                color: Colors.black,
                backgroundBlendMode: BlendMode.dstOut,
              ), // This one will handle background + difference out
            ),
            SizedBox.expand(
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: ClipOval(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );

  //----------END Widget Functions-----------
}

class _ShutterButton extends StatelessWidget {
  const _ShutterButton({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      child: Container(
        margin: const EdgeInsets.all(4),
        child: const SizedBox.expand(),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          color: Colors.white,
          shape: BoxShape.circle,
        ),
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
    );
  }
}

class MapButton extends StatelessWidget {
  const MapButton(this.iconData, {this.onTap, Key key}) : super(key: key);
  final IconData iconData;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.all(4),
        child: Icon(
          iconData,
          color: const Color(0xff072a99),
        ),
        alignment: Alignment.center,
        decoration:
            const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
      ),
    );
  }
}
