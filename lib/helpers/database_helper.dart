import 'dart:async';
import 'dart:io' as io;

import 'package:connectivity/connectivity.dart';
import 'package:gpstrackingplan/models/gpsroutemodel.dart';
import 'package:gpstrackingplan/models/userprofile.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = new DatabaseHelper.internal();
  factory DatabaseHelper() => _instance;
  static Database _db;

  Future<Database> get db async {
    if (_db != null) return _db;
    _db = await initDb();
    return _db;
  }

  DatabaseHelper.internal();

  initDb() async {
    io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "gpsroute.db");
    var theDb = await openDatabase(path, version: 1, onCreate: _onCreate);
    return theDb;
  }

  void _onCreate(Database db, int version) async {
    // When creating the db, create the table
    await db.execute(
        "CREATE TABLE User(Id TEXT, FullName TEXT, Email TEXT, UserName TEXT, Password TEXT, linkedCustomerID TEXT, Telephone TEXT )");
    print("Created user tables");
    await db.execute(
        "CREATE TABLE GpsRoute(GpsID INTEGER PRIMARY KEY, Lat TEXT, Lng TEXT, Gpsdatetime TEXT, CheckType TEXT, Customer TEXT, Image TEXT, UserId TEXT )");
    print("Created user GpsRoute");
  }

  Future<int> saveUser(Userprofile user) async {
    var dbClient = await db;
    int res = await dbClient.insert("User", user.toMap());
    return res;
  }


  Future<List<Gpsroutemodel>> getGpsRoute() async {
    var dbClient = await db;
    List<Map> list = await dbClient.rawQuery('SELECT * FROM GpsRoute');
    List<Gpsroutemodel> gpsroute = new List();
    for (int i = 0; i < list.length; i++) {
      gpsroute.add(new Gpsroutemodel());
    }
    print('getGpsRote==${gpsroute.length}');
    return gpsroute;
  }

  Future<int> saveGpsroute(Gpsroutemodel gpsroute) async {
    var dbClient = await db;
    int res = await dbClient.insert("GpsRoute", gpsroute.toMap());
    print('saveres=== $res');
    return res;
  }


  Future<Userprofile> loginUser(String username, String password) async {
    var dbClient = await db;
    var result = await dbClient.query('User',where: 'UserName = ? AND Password = ?',whereArgs: [username,password]);
    if (result.length > 0) {
      return new Userprofile.fromMap(result.first);
    }
    return null;
  }


  Future<bool> checkconnection() async{
  var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      print("Internet Connection");
      return  true;
    }else{
      print("Unable to connect");
      return false;
    }
  }

}