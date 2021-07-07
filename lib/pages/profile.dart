import 'dart:io';
import 'dart:math';

import 'package:face_recognise/firestoreServices/firestoreDB.dart';
import 'package:face_recognise/pages/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
// import 'package:geocoder/geocoder.dart';

import 'package:geolocator/geolocator.dart';
import 'package:vector_math/vector_math.dart' as rad;

class Profile extends StatefulWidget {
  const Profile(this.username, {Key key, this.imagePath}) : super(key: key);
  final String username;
  final String imagePath;

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String qrStr = "Nothing Scanned yet";
  @override
  Widget build(BuildContext context) {
    // final double mirror = math.pi;

    return WillPopScope(
      onWillPop: _onPressedBack,
      child: Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.blueAccent,
            elevation: 0,
            title: Text(
              "Hi " + widget.username,
              style: TextStyle(fontSize: 22),
            ),
            leading: IconButton(
                icon: Icon(Icons.home),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MyHomePage()),
                  );
                }),
            actions: <Widget>[
              Padding(
                padding: EdgeInsets.only(right: 20, top: 0),
                child: PopupMenuButton<String>(
                  child: Icon(
                    Icons.more_vert,
                    color: Colors.black,
                  ),
                  onSelected: (value) {
                    switch (value) {
                      case 'Log Out':
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => MyHomePage()),
                        );
                        break;
                    }
                  },
                  itemBuilder: (BuildContext context) {
                    return {'Log Out'}.map((String choice) {
                      return PopupMenuItem<String>(
                        value: choice,
                        child: Text(choice),
                      );
                    }).toList();
                  },
                ),
              )
            ]),
        backgroundColor: Colors.yellowAccent,
        body: SafeArea(
          child: Container(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black,
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: FileImage(File(widget.imagePath)),
                        ),
                      ),
                      margin: EdgeInsets.all(20),
                      width: 125,
                      height: 125,
                    ),
                  ],
                ),
                Container(
                  margin: EdgeInsets.all(20),
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    // color: Color(0xFFFEFFC1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          scanQR();
                        },
                        child: Text("Go to Scan page"),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // getAdrress(Coordinates cords) async {
  //   var addresses = await Geocoder.local.findAddressesFromCoordinates(cords);
  //   var first = addresses.first;
  //   print("${first.addressLine}");
  // }
  Future<void> scanQR() async {
    try {
      FlutterBarcodeScanner.scanBarcode("#2A99CF", "cancel", true, ScanMode.QR)
          .then((value) {
        if (value == '-1') {
          setState(() {
            qrStr = "snanning did not happened properly";
          });
        } else {
          setState(() {
            getVal(value);
            qrStr = value;
          });
        }
      });
    } catch (e) {
      setState(() {
        qrStr = "unable to read the qr";
      });
    }
  }

  getVal(String value) async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);

    if (value.contains('&')) {
      var lst = value.split("&");

      double curLat = double.parse(position.latitude.toStringAsPrecision(7));
      double curLong = double.parse(position.longitude.toStringAsPrecision(7));
      // print(curLat);
      // print(curLong);
      // print(lst);
      double checkLat = double.parse(lst[0].trim());
      double checkLong = double.parse(lst[1].trim());

      var date = DateTime.now().day.toString() +
          "/" +
          DateTime.now().month.toString() +
          "/" +
          DateTime.now().year.toString();
      //
      var time = DateTime.now().hour.toString() +
          ":" +
          DateTime.now().minute.toString();
      //
      var subject = lst[2].trim();
      // print(distance(curLat, curLong, checkLat, checkLong));
      if (distance(curLat, curLong, checkLat, checkLong) < 0.16) {
        FireStoreDB().getAttendance(widget.username, DateTime.now(), subject);
        successfulDialog(subject, date, time);
      } else
        locationWarning();
    } else {
      qrWarning();
    }
  }

  double distance(double lat1, double lng1, double lat2, double lng2) {
    double earthRadius = 6371;

    double dLat = rad.radians(lat2 - lat1);
    double dLng = rad.radians(lng2 - lng1);

    double sindLat = sin(dLat / 2);
    double sindLng = sin(dLng / 2);

    double a = pow(sindLat, 2) +
        pow(sindLng, 2) * cos(rad.radians(lat1)) * cos(rad.radians(lat2));

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    double dist = earthRadius * c;

    return dist;
  }

  Future<dynamic> qrWarning() {
    return showDialog(
        context: context,
        builder: (context) => new AlertDialog(
              title: new Text(
                'Warning',
                style: TextStyle(color: Colors.redAccent),
              ),
              content: new Text('Please Scan the appropriate QR code '),
              actions: [
                new GestureDetector(
                  onTap: () => Navigator.of(context).pop(false),
                  child: Text(
                    "Okay",
                    style: TextStyle(color: Colors.redAccent),
                  ),
                ),
              ],
            ));
  }

  Future<dynamic> locationWarning() {
    return showDialog(
        context: context,
        builder: (context) => new AlertDialog(
              title: new Text(
                'Warning',
                style: TextStyle(color: Colors.redAccent),
              ),
              content: new Text(
                  'Your Location Does not match with the location in the QR code \nplease try again with proper location '),
              actions: [
                new GestureDetector(
                  onTap: () => Navigator.of(context).pop(false),
                  child: Text(
                    "Okay",
                    style: TextStyle(color: Colors.redAccent, fontSize: 36),
                  ),
                ),
              ],
            ));
  }

  Future<dynamic> successfulDialog(String subject, String date, String time) {
    return showDialog(
        context: context,
        builder: (context) => new AlertDialog(
              title: new Text('Thank you ...'),
              content: new Text(
                  'Your attendance for the $subject is successfully submitted of data $date at $time'),
              actions: [
                new GestureDetector(
                  onTap: () => Navigator.of(context).pop(false),
                  child: Text(
                    "stay",
                    style: TextStyle(fontSize: 25),
                  ),
                ),
                SizedBox(height: 16),
                new GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MyHomePage()),
                  ),
                  child: Text(
                    "logout",
                    style: TextStyle(color: Colors.redAccent, fontSize: 25),
                  ),
                ),
              ],
            ));
  }

  Future<bool> _onPressedBack() {
    return showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: new Text('Are you sure?'),
            content: new Text('Do you want to exit an App'),
            actions: <Widget>[
              new GestureDetector(
                onTap: () => Navigator.of(context).pop(false),
                child: Text("NO"),
              ),
              SizedBox(height: 16),
              new GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MyHomePage()),
                ),
                child: Text(
                  "YES",
                  style: TextStyle(color: Colors.redAccent),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }
}
