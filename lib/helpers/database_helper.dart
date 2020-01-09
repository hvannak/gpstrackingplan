import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;

import 'package:connectivity/connectivity.dart';
import 'package:gpstrackingplan/models/gpsroutemodel.dart';
import 'package:gpstrackingplan/models/userprofile.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import 'apiHelper .dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = new DatabaseHelper.internal();
  factory DatabaseHelper() => _instance;
  static Database _db;
  ApiHelper _apiHelper;
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


  Future<String> getGpsRoute() async {
    var dbClient = await db;
    var list = await dbClient.rawQuery('SELECT * FROM GpsRoute');
    for (int i = 0; i < list.length; i++) {
      var model = Gpsroutemodel.fromMap(list[i]);
      print(model.lat);
      var body = {
        'GpsID': '0',
        'Lat': model.lat,
        'Lng': model.lng,
        'Gpsdatetime': DateFormat('yyyy-MM-dd,HH:mm:ss').format(DateTime.parse(model.gpsdatetime)),
        'CheckType': model.checkType,
        'Customer': model.customer,
        'Image': model.image,
      };
      SharedPreferences prefs = await SharedPreferences.getInstance();
      _apiHelper = ApiHelper(prefs);
      final response = await _apiHelper.fetchPost1('/api/Gpstrackings', body);
      print(response.statusCode);
      if (response.statusCode == 200) {
        await dbClient.rawDelete('DELETE FROM GpsRoute');
        print('delete = ${await dbClient.rawQuery('SELECT * FROM GpsRoute')}');
        return response.body;
        
      } else {
        print(response.statusCode);
        throw Exception('Failed to load post');
      }
    }
   
    return null;
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