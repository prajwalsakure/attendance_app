import 'package:camera/camera.dart';
import 'package:face_recognise/pages/widgets/FacePainter.dart';
import 'package:face_recognise/pages/widgets/auth_action_button.dart';
import 'package:face_recognise/pages/widgets/camera_header.dart';
import 'package:face_recognise/services/camera.service.dart';
import 'package:face_recognise/services/facenet.service.dart';
import 'package:face_recognise/services/ml_kit_service.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:async';
import 'dart:io';
import 'package:google_ml_kit/google_ml_kit.dart';

class SignIn extends StatefulWidget {
  final CameraDescription cameraDescription;
  const SignIn({
    Key key,
    @required this.cameraDescription,
  }) : super(key: key);

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  CameraService _cameraService = CameraService();
  MLKitService _mlKitService = MLKitService();
  FaceNetService _facceNetService = FaceNetService();
//
  Future _initializeControllerFuture;
  bool cameraInitialized = false;
  bool _detectingFaces = false;
  bool pictureTaked = false;
//
  bool _saving = false;
  bool _bottomSheetVisible = false;
//
  String imagePath;
  Size imageSize;
  Face faceDetected;
  //
  @override
  void initState() {
    super.initState();
    _start();
  }

  @override
  void dispose() {
    _cameraService.dispose();
    super.dispose();
  }

  _start() async {
    _initializeControllerFuture =
        _cameraService.startService(widget.cameraDescription);
    await _initializeControllerFuture;
    setState(() {
      cameraInitialized = true;
    });
    _frameFaces();
  }

  _frameFaces() {
    imageSize = _cameraService.getImageSize();
    _cameraService.cameraController.startImageStream((image) async {
      if (_cameraService.cameraController != null) {
        if (_detectingFaces) return;
        _detectingFaces = true;
        try {
          List<Face> faces = await _mlKitService.getFacesFromImage(image);
          if (faces != null) {
            if (faces.length > 0) {
              setState(() {
                faceDetected = faces[0];
              });
              if (_saving) {
                _saving = false;
                _facceNetService.setCurrentPrediction(image, faceDetected);
              }
            } else {
              setState(() {
                faceDetected = null;
              });
            }
          }
          _detectingFaces = false;
        } catch (e) {
          print(e);
          _detectingFaces = false;
        }
      }
    });
  }

//
  Future<void> onShot() async {
    if (faceDetected == null) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text('No face Detected'),
          );
        },
      );
      return false;
    } else {
      _saving = true;
      await Future.delayed(Duration(milliseconds: 500));
      await _cameraService.cameraController.stopImageStream();
      await Future.delayed(Duration(microseconds: 200));
      XFile file = await _cameraService.takePicture();
      setState(() {
        _bottomSheetVisible = true;
        pictureTaked = true;
        imagePath = file.path;
      });
      return true;
    }
  }

  _onBackPressed() {
    Navigator.of(context).pop();
  }

  _reload() {
    setState(() {
      _bottomSheetVisible = false;
      cameraInitialized = false;
      pictureTaked = false;
    });
    this._start();
  }

  @override
  Widget build(BuildContext context) {
    final double mirror = math.pi;
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Stack(
        children: [
          FutureBuilder(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (pictureTaked) {
                    return Container(
                      width: width,
                      height: height,
                      // child: Text("This is Image"),
                      child: Transform(
                        alignment: Alignment.center,
                        child: FittedBox(
                          fit: BoxFit.cover,
                          child: Image.file(File(imagePath)),
                        ),
                        transform: Matrix4.rotationY(mirror),
                      ),
                    );
                  } else {
                    return Transform.scale(
                      scale: 1.0,
                      child: AspectRatio(
                        aspectRatio: MediaQuery.of(context).size.aspectRatio,
                        child: OverflowBox(
                          alignment: Alignment.center,
                          child: FittedBox(
                            fit: BoxFit.fitHeight,
                            child: Container(
                              width: width,
                              height: width *
                                  _cameraService
                                      .cameraController.value.aspectRatio,
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  CameraPreview(
                                      _cameraService.cameraController),
                                  CustomPaint(
                                    painter: FacePainter(
                                        face: faceDetected,
                                        imageSize: imageSize),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                } else {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
              }),
          CameraHeader(
            "LOGIN",
            onBackPressed: _onBackPressed,
          )
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: !_bottomSheetVisible
          ? AuthActionButton(
              _initializeControllerFuture,
              onPressed: onShot,
              isLogin: true,
              reload: _reload,
            )
          : Container(),
    );
  }
}
