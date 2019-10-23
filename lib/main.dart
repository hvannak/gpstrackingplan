import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:gpstrackingplan/appsetting.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dashboard.dart';


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
  String _urlSetting = '';

  void showSnackbar(BuildContext context) {
    fetchPost();
    final snackBar = SnackBar(content: Text('Pocessing data'));
    _globalKey.currentState.showSnackBar(snackBar);
  }

  _loadSetting() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _urlSetting = (prefs.getString('url') ?? '');     
    });
  }

  Future<String> fetchPost() async {
    final headers = {'Content-Type': 'application/json'};
    var body = {
      'UserName': _username.text,
      'Password': _password.text
    };
    final response =
        // await http.post('http://192.168.100.93:8184/api/ApplicationUser/Login',body: json.encode(body),headers: headers);
        await http.post(_urlSetting + '/api/ApplicationUser/Login',body: json.encode(body),headers: headers);
    if (response.statusCode == 200) {
      Navigator.push(
        context, 
        MaterialPageRoute(builder: (context) => Dashboard()));
      return response.body;
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
     resizeToAvoidBottomPadding: false,
     key: _globalKey,
     body: Stack(
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
                    child:Image.asset(
                    'assets/images/user.png',
                    color: Colors.blue,
                    height: 180.0,
                    width: 180.0,
                    ),
                    onTap: (){
                      Navigator.push(
                                context, 
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
                       padding: EdgeInsets.symmetric(
                         horizontal: 30.0,
                         vertical: 20.0
                       ),
                       decoration: BoxDecoration(
                         color: Colors.white,
                         shape: BoxShape.rectangle,
                         borderRadius: BorderRadius.circular(20.0)
                       ),
                       child: Column(
                         mainAxisAlignment: MainAxisAlignment.center,
                         children: <Widget>[
                           Form(
                             key: _formKey,
                             child: Column(
                               children: <Widget>[
                                 Padding(
                             padding: EdgeInsets.symmetric(
                               vertical: 25.0
                             ),
                             child:TextFormField(
                             controller: _username,
                             validator: (val)=> val.isEmpty ? "Username is required" : null,
                             autocorrect: false,
                             autofocus: false,
                             style: TextStyle(
                               fontSize: 14.0
                             ),
                             decoration: InputDecoration(
                               hintText: "Username",
                               border: InputBorder.none,
                               filled: true,
                               fillColor: Colors.grey[200],
                               contentPadding: EdgeInsets.all(15.0),
                             ),
                            )
                           ),
                           TextFormField(
                             controller: _password,
                             validator: (val) => val.isEmpty ? "Password is required" : null,
                             autocorrect: false,
                             autofocus: false,
                             obscureText: true,
                             style: TextStyle(
                               fontSize: 14.0
                             ),
                             decoration: InputDecoration(
                               hintText: "Password",
                               border: InputBorder.none,
                               filled: true,
                               fillColor: Colors.grey[200],
                               contentPadding: EdgeInsets.all(15.0)
                             ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 20.0),
                              child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Center(
                                  child: RaisedButton(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 15.0
                                  ),
                                  onPressed: (){
                                    if(_formKey.currentState.validate()){
                                      
                                      showSnackbar(context);
                                    }
                                  },
                                  child: Text(
                                    'Login',
                                    style: TextStyle(
                                      fontSize: 14.0
                                      ),
                                    ),
                                  ),
                                )
                              ],
                             )
                            )
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
     ),
   );
  }
}

