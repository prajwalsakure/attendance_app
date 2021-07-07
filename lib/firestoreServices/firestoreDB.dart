import 'package:cloud_firestore/cloud_firestore.dart';

class FireStoreDB {
  static final FireStoreDB _cameraServiceService = FireStoreDB._internal();
  factory FireStoreDB() {
    return _cameraServiceService;
  }
  FireStoreDB._internal();

  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection("users");

  final CollectionReference attendanceCollection =
      FirebaseFirestore.instance.collection("attendance");
//

  Future signUp(String name, String password, List<dynamic> face) async {
    String userAndPass = name + ':' + password;
    return userCollection.doc('data').update({userAndPass: face});
  }
  //

  Future getAttendance(String name, DateTime dateTime, String subject) {
    Timestamp myTime = Timestamp.fromDate(dateTime);
    // return attendanceCollection.doc(subject).set({name: myTime});
    return attendanceCollection.doc(subject).update({name: myTime});
  }
}

//
//
// var obj = ({userAndPass: face});
//   // DocumentSnapshot userSnapshot = await userCollection.doc('data').get();
//   // var data = userSnapshot.data();
//   var userSnapshot = await userCollection.doc('data').get();

//   var datas = userSnapshot.data();
//   datas[datas.keys.elementAt(0)].add({obj});
//   return await userCollection.doc('data').update(datas);
