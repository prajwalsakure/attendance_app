// import 'dart:convert';
// import 'dart:io';
// import 'package:path_provider/path_provider.dart';

// class DataBaseService {
//   static final DataBaseService _cameraServiceService =
//       DataBaseService._internal();
//   factory DataBaseService() {
//     return _cameraServiceService;
//   }
//   DataBaseService._internal();
//   File jsonFile;
//   //
//   Map<String, dynamic> _db = Map<String, dynamic>();
//   Map<String, dynamic> get db => this._db;

//   /// loads a simple json file.
//   Future loadDB() async {
//     var tempDir = await getApplicationDocumentsDirectory();
//     String _embPath = tempDir.path + '/emb.json';

//     jsonFile = new File(_embPath);

//     if (jsonFile.existsSync()) {
//       _db = json.decode(jsonFile.readAsStringSync());
//       // print("this is db");
//       // print(_db);
//     }
//   }

//   Future saveData(String user, String password, List modelData) async {
//     String userAndPass = user + ':' + password;
//     _db[userAndPass] = modelData;
//     jsonFile.writeAsStringSync(json.encode(_db));
//   }

//   /// deletes the created users
//   cleanDB() {
//     this._db = Map<String, dynamic>();
//     jsonFile.writeAsStringSync(json.encode({}));
//   }
// }
