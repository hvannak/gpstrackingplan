import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gpstrackingplan/appsetting.dart';
import 'package:gpstrackingplan/helpers/apiHelper%20.dart';
import 'package:gpstrackingplan/register.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dashboard.dart';

import 'helpers/database_helper.dart';
import 'models/userprofile.dart';
import 'package:connectivity/connectivity.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _formKey = GlobalKey<FormState>();
  final _globalKey = GlobalKey<ScaffoldState>();
  final _username = TextEditingController();
  final _password = TextEditingController();
  ApiHelper _apiHelper;

  bool _isLoading = false;

  _setAppSetting(
      String token, String fullname, String linkedCustomerID, String iD) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setString('token', token);
      prefs.setString('fullname', fullname);
      prefs.setString('linkedCustomerID', linkedCustomerID);
      prefs.setString('Id', iD);
    });
  }

  _loadSetting() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _apiHelper = ApiHelper(prefs);
    });
  }

  fetchPost() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      print("Internet Connection");
      try {
        var body = {'UserName': _username.text, 'Password': _password.text};
        var respone = await _apiHelper
            .fetchPost('/api/ApplicationUser/Login', body)
            .timeout(Duration(seconds: 100));   
        if (respone.statusCode == 200) {
          Map<String, dynamic> tokenget = jsonDecode(respone.body);
          var response1 = await _apiHelper.fetchData1(
              '/api/UserProfile', tokenget['token']);
          var jsonData = jsonDecode(response1.body);
          Userprofile profile = Userprofile.fromJson(jsonData);
          _setAppSetting(tokenget['token'], profile.fullName,
              profile.linkedCustomerID, profile.iD.toString());
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => MyDashboard()));
        } else {
          var jsonData = jsonDecode(respone.body)['message'];
          final snackBar = SnackBar(content: Text(jsonData));
          _globalKey.currentState.showSnackBar(snackBar);
        }
      } catch (e) {
        final snackBar = SnackBar(content: Text('Cannot connect to host'));
        _globalKey.currentState.showSnackBar(snackBar);
      }
    } else {
      print("Unable to connect");
      var db = DatabaseHelper();
      Userprofile user = await db.loginUser(_username.text, _password.text);
      if (user != null) {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => MyDashboard()));
      } else {
        final snackBar = SnackBar(content: Text('wrong username or password'));
        _globalKey.currentState.showSnackBar(snackBar);
      }
      return user;
    }

    // try {
    //   var body = {'UserName': _username.text, 'Password': _password.text};
    //   var respone = await _apiHelper
    //       .fetchPost('/api/ApplicationUser/Login', body)
    //       .timeout(Duration(seconds: 5));
    //   if (respone.statusCode == 200) {
    //     Map<String, dynamic> tokenget = jsonDecode(respone.body);
    //     var response1 =
    //         await _apiHelper.fetchData1('/api/UserProfile', tokenget['token']);
    //     var jsonData = jsonDecode(response1.body);
    //     Userprofile profile = Userprofile.fromJson(jsonData);
    //     _setAppSetting(tokenget['token'], profile.fullName,
    //         profile.linkedCustomerID, profile.iD.toString());
    //     Navigator.push(
    //         context, MaterialPageRoute(builder: (context) => MyDashboard()));
    //   } else {
    //     var jsonData = jsonDecode(respone.body)['message'];
    //     final snackBar = SnackBar(content: Text(jsonData));
    //     _globalKey.currentState.showSnackBar(snackBar);
    //   }
    // } catch (e) {
    //   final snackBar = SnackBar(content: Text('Cannot connect to host'));
    //   _globalKey.currentState.showSnackBar(snackBar);
    // }
  }

  Future<Userprofile> _loginUser(String username, String password) async {
    var db = DatabaseHelper();
    Userprofile user = await db.loginUser(username, password);
    if (user != null) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => MyDashboard()));
    } else {
      final snackBar = SnackBar(content: Text('wrong username or password'));
      _globalKey.currentState.showSnackBar(snackBar);
    }
    return user;
  }

  @override
  void initState() {
    super.initState();
    _loadSetting();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomPadding: false,
        key: _globalKey,
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => Register()));
          },
          label: Text('Register'),
          icon: Icon(Icons.supervised_user_circle),
          backgroundColor: Colors.pink,
        ),
        body: OrientationBuilder(
            builder: (BuildContext context, Orientation orientation) {
          return Center(
              child: orientation == Orientation.portrait
                  ? _veticalLayout()
                  : _horizontalLayout());
        }));
  }

  _veticalLayout() {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        Image.asset(
          'assets/images/bg.jpeg',
          fit: BoxFit.cover,
          color: Colors.black54,
          colorBlendMode: BlendMode.darken,
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(20.0),
              child: InkWell(
                child: Image.asset(
                  'assets/images/user.png',
                  color: Colors.blue,
                  height: 180.0,
                  width: 180.0,
                ),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Appsetting()));
                },
              ),
            ),
            Stack(
              children: <Widget>[
                SingleChildScrollView(
                  child: Container(
                    height: 300.0,
                    width: 450.0,
                    padding:
                        EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(20.0)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Form(
                          key: _formKey,
                          child: Column(
                            children: <Widget>[
                              Padding(
                                  padding: EdgeInsets.symmetric(vertical: 25.0),
                                  child: TextFormField(
                                    controller: _username,
                                    validator: (val) => val.isEmpty
                                        ? "Username is required"
                                        : null,
                                    autocorrect: false,
                                    autofocus: false,
                                    style: TextStyle(fontSize: 14.0),
                                    decoration: InputDecoration(
                                      hintText: "Username",
                                      border: InputBorder.none,
                                      filled: true,
                                      fillColor: Colors.grey[200],
                                      contentPadding: EdgeInsets.all(15.0),
                                    ),
                                  )),
                              TextFormField(
                                controller: _password,
                                validator: (val) =>
                                    val.isEmpty ? "Password is required" : null,
                                autocorrect: false,
                                autofocus: false,
                                obscureText: true,
                                style: TextStyle(fontSize: 14.0),
                                decoration: InputDecoration(
                                    hintText: "Password",
                                    border: InputBorder.none,
                                    filled: true,
                                    fillColor: Colors.grey[200],
                                    contentPadding: EdgeInsets.all(15.0)),
                              ),
                              Padding(
                                  padding: EdgeInsets.only(top: 20.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Center(
                                        child: RaisedButton(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 15.0),
                                          onPressed: () {
                                            if (_formKey.currentState
                                                .validate()) {
                                              fetchPost();
                                              // _loginUser(_username.text,
                                              //     _password.text);
                                            }
                                          },
                                          child: Text(
                                            'Login',
                                            style: TextStyle(fontSize: 14.0),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ],
        )
      ],
    );
  }

  _horizontalLayout() {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        Image.asset(
          'assets/images/bg.jpeg',
          fit: BoxFit.cover,
          color: Colors.black54,
          colorBlendMode: BlendMode.darken,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(20.0),
              child: InkWell(
                child: Image.asset(
                  'assets/images/user.png',
                  color: Colors.blue,
                  height: 180.0,
                  width: 180.0,
                ),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Appsetting()));
                },
              ),
            ),
            Stack(
              children: <Widget>[
                SingleChildScrollView(
                  child: Container(
                    height: 300.0,
                    width: 450.0,
                    padding:
                        EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(20.0)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Form(
                          key: _formKey,
                          child: Column(
                            children: <Widget>[
                              Padding(
                                  padding: EdgeInsets.symmetric(vertical: 25.0),
                                  child: TextFormField(
                                    controller: _username,
                                    validator: (val) => val.isEmpty
                                        ? "Username is required"
                                        : null,
                                    autocorrect: false,
                                    autofocus: false,
                                    style: TextStyle(fontSize: 14.0),
                                    decoration: InputDecoration(
                                      hintText: "Username",
                                      border: InputBorder.none,
                                      filled: true,
                                      fillColor: Colors.grey[200],
                                      contentPadding: EdgeInsets.all(15.0),
                                    ),
                                  )),
                              TextFormField(
                                controller: _password,
                                validator: (val) =>
                                    val.isEmpty ? "Password is required" : null,
                                autocorrect: false,
                                autofocus: false,
                                obscureText: true,
                                style: TextStyle(fontSize: 14.0),
                                decoration: InputDecoration(
                                    hintText: "Password",
                                    border: InputBorder.none,
                                    filled: true,
                                    fillColor: Colors.grey[200],
                                    contentPadding: EdgeInsets.all(15.0)),
                              ),
                              Padding(
                                  padding: EdgeInsets.only(top: 20.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Center(
                                        child: RaisedButton(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 15.0),
                                          onPressed: () {
                                            if (_formKey.currentState
                                                .validate()) {
                                              // fetchPost();
                                              // showSnackbar(context);
                                            }
                                          },
                                          child: Text(
                                            'Login',
                                            style: TextStyle(fontSize: 14.0),
                                          ),
                                        ),
                                      )
                                    ],
                                  ))
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ],
        )
      ],
    );
  }
}
