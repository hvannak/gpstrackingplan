import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:gpstrackingplan/main.dart';
import 'package:gpstrackingplan/routevisiting.dart';
import 'package:gpstrackingplan/saleorder.dart';
import 'package:gpstrackingplan/takeleave.dart';
import 'package:gpstrackingplan/payment.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'customeroutstanding.dart';
import 'models/userprofile.dart';

class MyDashboard extends StatefulWidget {
  @override
  _MyDashboardState createState() => _MyDashboardState();
}

class _MyDashboardState extends State<MyDashboard> {
  String _token = '';
  String _urlSetting = '';

  Material myItems(IconData icon, String heading, int color,
      BuildContext context, String page) {
    return Material(
      color: Colors.white,
      elevation: 4.0,
      borderRadius: BorderRadius.circular(20.0),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(heading,
                          style: TextStyle(
                              color: new Color(color), fontSize: 20.0)),
                    ),
                  ),
                  Material(
                    color: new Color(color),
                    borderRadius: BorderRadius.circular(24.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: InkWell(
                        child: Icon(
                          icon,
                          color: Colors.white,
                          size: 30.0,
                        ),
                        onTap: () {
                          print('Click menu');
                          fetchProfileData();
                          switch (page) {
                            case 'visit':
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Routevisiting()));
                              break;
                            case 'leave':
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Takeleave()));
                              break;
                            case 'payment':
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Payment()));
                              break;
                            case 'outstanding':
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          CustomerOutstanding()));
                              break;
                            case 'saleorder':
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SaleOrder()));
                              break;
                            case 'feedback':
                              // Navigator.push(
                              //     context,
                              //     MaterialPageRoute(
                              //         builder: (context) => Routevisiting()));
                              break;
                            default:
                          }
                          // Navigator.push(
                          //           context,
                          //           MaterialPageRoute(builder: (context) => MyHomePage()));
                        },
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  _loadSetting() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _token = (prefs.getString('token') ?? '');
      _urlSetting = (prefs.getString('url') ?? '');
    });
  }

  _setAppSetting(String fullname, String linkedCustomerID, String iD) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setString('fullname', fullname);
      prefs.setString('linkedCustomerID', linkedCustomerID);
      prefs.setString('Id', iD);
    });
  }

  Future<Userprofile> fetchProfileData() async {
    final response = await http.get(_urlSetting + '/api/UserProfile', headers: {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: "Bearer " + _token
    });
    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      print(jsonData);
      Userprofile profile = Userprofile.fromJson(jsonData);
      _setAppSetting(profile.fullName, profile.linkedCustomerID, profile.iD);
      return profile;
    } else {
      print(response.statusCode);
      throw Exception('Failed to load post');
    }
  }

  @override
  void initState() {
    super.initState();
    _loadSetting();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
        'Dashboard',
        style: TextStyle(color: Colors.white),
      )),
      drawer: Drawer(
        child: MyDrawer()),
      body: StaggeredGridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 12.0,
        mainAxisSpacing: 12.0,
        padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
        children: <Widget>[
          myItems(Icons.map, "Route Visit", 0xffed622b, context, 'visit'),
          myItems(
              Icons.graphic_eq, "Feedback", 0xffed622b, context, 'feedback'),
          myItems(
              Icons.time_to_leave, "Take Leave", 0xffed622b, context, 'leave'),
          myItems(
              Icons.time_to_leave, "Payment", 0xffed622b, context, 'payment'),
          myItems(Icons.time_to_leave, "Outstanding", 0xffed622b, context,
              'outstanding'),
          myItems(Icons.time_to_leave, "Sale Order", 0xffed622b, context,
              'saleorder')
        ],
        staggeredTiles: [
          StaggeredTile.extent(1, 130.0),
          StaggeredTile.extent(1, 130.0),
          StaggeredTile.extent(1, 130.0),
          StaggeredTile.extent(1, 130.0),
          StaggeredTile.extent(1, 130.0),
          StaggeredTile.extent(1, 130.0),
        ],
      ),
    );
  }
}

class MyDrawer extends StatefulWidget {
  @override
  _MyDrawerState createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  String _token = '';
  String _urlSetting = '';

  _loadSetting() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _token = (prefs.getString('token') ?? '');
      _urlSetting = (prefs.getString('url') ?? '');
    });
  }

  _setAppSetting(String fullname, String linkedCustomerID, String iD) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setString('fullname', fullname);
      prefs.setString('linkedCustomerID', linkedCustomerID);
      prefs.setString('Id', iD);
    });
  }

  _removeAppSetting() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.remove('fullname');
      prefs.remove('linkedCustomerID');
      prefs.remove('Id');
    });
  }

  Future<Userprofile> fetchProfileData() async {
    final response = await http.get(_urlSetting + '/api/UserProfile', headers: {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: "Bearer " + _token
    });
    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      print('test userdata= $jsonData');
      Userprofile profile = Userprofile.fromJson(jsonData);
      if (this.mounted) {
        _setAppSetting(profile.fullName, profile.linkedCustomerID, profile.iD);
      }
      return profile;
    } else {
      print(response.statusCode);
      throw Exception('Failed to load post');
    }
  }

  @override
  void initState() {
    super.initState();
    _loadSetting();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: fetchProfileData(),
      initialData: 'Loading...',
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.data == null) {
          return Container(
            child: Center(child: Text('Loading...')),
          );
        } else {
          return ListView(
            // Important: Remove any padding from the ListView.
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                child: Stack(
                  children: <Widget>[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        child: Image.asset('assets/images/user.png'),
                        radius: 50.0,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(right: 20.0),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          snapshot.data.fullName,
                          style: TextStyle(color: Colors.white, fontSize: 20.0),
                        ),
                      ),
                    )
                  ],
                ),
                padding: EdgeInsets.only(top: 35.0, left: 20.0),
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
              ),
              ListTile(
                title: Text('Route Visit'),
                leading: Icon(Icons.map),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Routevisiting()));
                },
              ),
              ListTile(
                title: Text('Take Leave'),
                leading: Icon(Icons.time_to_leave),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Takeleave()));
                },
              ),
              ListTile(
                title: Text('Logout'),
                leading: Icon(Icons.backspace),
                onTap: () {
                  _removeAppSetting();
                  Navigator.of(context).pop();
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => MyHomePage()));
                },
              ),
            ],
          );
        }
      },
    );
  }
}
