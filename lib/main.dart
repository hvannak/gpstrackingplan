import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:gpstrackingplan/app_localizations.dart';
import 'package:gpstrackingplan/application.dart';
import 'package:gpstrackingplan/appsetting.dart';
import 'package:gpstrackingplan/helpers/apiHelper%20.dart';
import 'package:gpstrackingplan/register.dart';
import 'package:gpstrackingplan/waitingdialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_translations_delegate.dart';
import 'dashboard.dart';

import 'helpers/database_helper.dart';
import 'models/customermodel.dart';
import 'models/userprofile.dart';

Future<Null> main() async {
  runApp(new MyApp());
}

class MyApp extends StatefulWidget {
  @override
  MyAppState createState() {
    return new MyAppState();
  }
}

class MyAppState extends State<MyApp> {
  AppTranslationsDelegate _newLocaleDelegate;

  @override
  void initState() {
    super.initState();
    _newLocaleDelegate = AppTranslationsDelegate(newLocale: null);
    application.onLocaleChanged = onLocaleChange;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(title: 'Main Page'),
      localizationsDelegates: [
        _newLocaleDelegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en', 'US'),
        const Locale('km', 'KH'),
      ],
    );
  }

  void onLocaleChange(Locale locale) {
    setState(() {
      _newLocaleDelegate = AppTranslationsDelegate(newLocale: locale);
    });
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
  static final List<String> languagesList = application.supportedLanguages;
  static final List<String> languageCodesList =
      application.supportedLanguagesCodes;

  final Map<dynamic, dynamic> languagesMap = {
    languagesList[0]: languageCodesList[0],
    languagesList[1]: languageCodesList[1],
  };

  String label = languagesList[0];

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

  _loadlanguage() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String languagecode = (prefs.getString('language') ?? '');
    setState(() {
       if(languagecode == ''){
         label = 'English';
         languagecode = 'en';
       }
       else{
         label = languagecode;
         languagecode = (languagecode == 'English' ? 'en' : 'km');
       }
    });
   await onLocaleChange(Locale(languagecode));
  }

  fetchPostOnline() async {
    try {
      WaitingDialogs().showLoadingDialog(context,_globalKey);
      var body = {'UserName': _username.text, 'Password': _password.text};
      var respone = await _apiHelper
          .fetchPost('/api/ApplicationUser/Login', body)
          .timeout(Duration(seconds: 100));
      if (respone.statusCode == 200) {
        Map<String, dynamic> tokenget = jsonDecode(respone.body);
        await fetchProfile(tokenget['token']);
        await syncData();
        var customers= await fetchCustomerData();
        Navigator.of(context).pop();
        Navigator.push(
              context, MaterialPageRoute(builder: (context) => MyDashboard(
                listCustomers: customers,
              )));
      } else {
        Navigator.of(context).pop();
        var jsonData = jsonDecode(respone.body)['message'];
        final snackBar = SnackBar(content: Text(jsonData));
        print(_globalKey.currentState);
        _globalKey.currentState.showSnackBar(snackBar);
      }
    } catch (e) {
      Navigator.of(context).pop();
      final snackBar = SnackBar(content: Text('Cannot connect to host'));
      _globalKey.currentState.showSnackBar(snackBar);
    }
  }

  fetchPostOffline() async {
    WaitingDialogs().showLoadingDialog(context,_globalKey);
    var db = DatabaseHelper();
    Userprofile user = await db.loginUser(_username.text, _password.text);
    if (user == null) {
      final snackBar = SnackBar(content: Text('Invalid username or password'));
      _globalKey.currentState.showSnackBar(snackBar);
      Navigator.of(context).pop();
    } 
    else{
      Navigator.of(context).pop();
      Navigator.push(
              context, MaterialPageRoute(builder: (context) => MyDashboard()));
    }
  }

  Future syncData() async {
    var db = DatabaseHelper();
        if (await db.checkconnection()){
           db.getGpsRoute();
          print('sync');
        }
        else{
          print('can not sync');   
        }
  }

  Future<List<Customermodel>> fetchCustomerData() async {
    final response = await _apiHelper.fetchData('/api/Customer/SalespersonID/' + _apiHelper.linkedCustomerID);
    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      List<Customermodel> _listCustomers= [];
      for (var item in jsonData['Results']) {
        Customermodel customermodel = Customermodel.fromJson(item);
        _listCustomers.add(customermodel);
      }
      print(_listCustomers.length);
      return _listCustomers;
    } else {
      final snackBar = SnackBar(content: Text('Failed to load'));
      _globalKey.currentState.showSnackBar(snackBar);
      throw Exception('Failed to load post');
    }
  }

  fetchProfile(String token) async {
    var response1 = await _apiHelper.fetchData1('/api/UserProfile', token);
    var jsonData = jsonDecode(response1.body);
    Userprofile profile = Userprofile.fromJson(jsonData);
    _setAppSetting(token, profile.fullName,profile.linkedCustomerID, profile.iD.toString());
    var db = DatabaseHelper();
    Userprofile userData = await db.checkUser(_username.text);
      if (userData == null) {
        var user = Userprofile(
        userName: profile.userName,
        password: _password.text,
        email: profile.email,
        fullName: profile.fullName,
        linkedCustomerID: profile.linkedCustomerID,
        telephone: profile.telephone);
        db.saveUser(user);
      }else{
        print('user already exist');
      } 
  }

  Future<void> _handleSubmit(BuildContext context) async {
    try{
      var db  = DatabaseHelper();
      if (await db.checkconnection()){
         fetchPostOnline();
      }
      else{
        fetchPostOffline();        
      }
    }
    catch(e){
      print(e);
    }
  }

  Future<void> onLocaleChange(Locale locale) async {
    var currentLang = await AppLocalizations.load(locale);
    setState(() {
      currentLang.currentLanguage;
    });
  } 
  void _select(String language) async{
    final SharedPreferences prefs = await  SharedPreferences.getInstance();
    print("language== "+language);
    onLocaleChange(Locale(languagesMap[language]));
    
    setState(() {
      label = "English";
      prefs.setString('language', language);
      if (language == "English") {
        label = "English";
      } else {
        label = language;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _loadSetting();
     _loadlanguage();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: Scaffold(
      appBar: new AppBar(
          automaticallyImplyLeading:false,
          title: new Text(
            label,
            style: new TextStyle(color: Colors.white),
          ),
          actions: <Widget>[
            PopupMenuButton<String>(
              onSelected: _select,
              icon: new Icon(Icons.language, color: Colors.white),
              itemBuilder: (BuildContext context) {
                return languagesList
                    .map<PopupMenuItem<String>>((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice),
                  );
                }).toList();
              },
            ),
          ],
        ),
        resizeToAvoidBottomPadding: false,
        key: _globalKey,
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => Register()));
          },
          // label: Text('Register'),
          label:Text(AppLocalizations.of(context).translate('register')),
          icon: Icon(Icons.supervised_user_circle),
          backgroundColor: Colors.pink,
        ),
        body: OrientationBuilder(
            builder: (BuildContext context, Orientation orientation) {
          return Center(
              child: orientation == Orientation.portrait
                  ? _veticalLayout()
                  : _horizontalLayout());
        }))
    );
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
                    height: 320.0,
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
                                        ? AppLocalizations.of(context).translate('username_required')
                                        : null,
                                    autocorrect: false,
                                    autofocus: false,
                                    style: TextStyle(fontSize: 14.0),
                                    decoration: InputDecoration(
                                      hintText: AppLocalizations.of(context).translate('username'),
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide: BorderSide(
                                            width: 0,
                                            style: BorderStyle.none,
                                          )),
                                      filled: true,
                                      fillColor: Colors.grey[200],
                                      contentPadding: EdgeInsets.all(15.0),
                                    ),
                                  )),
                              TextFormField(
                                controller: _password,
                                validator: (val) =>
                                    val.isEmpty ? AppLocalizations.of(context).translate('password_required')  : null,
                                autocorrect: false,
                                autofocus: false,
                                obscureText: true,
                                style: TextStyle(fontSize: 14.0),
                                decoration: InputDecoration(
                                    hintText: AppLocalizations.of(context).translate('password'),
                                    border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide: BorderSide(
                                            width: 0,
                                            style: BorderStyle.none,
                                          )),
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
                                          shape: new RoundedRectangleBorder(
                                            borderRadius:
                                                new BorderRadius.circular(8.0),
                                          ),
                                          color: Colors.lightBlue,
                                          onPressed: () {
                                            if (_formKey.currentState
                                                .validate()) {
                                              _handleSubmit(context);
                                              // fetchPost();
                                              // _loginUser(_username.text,
                                              //     _password.text);
                                            }
                                          },
                                          child: Text(
                                            AppLocalizations.of(context).translate('login'),
                                            style: TextStyle(fontSize: 16.0, color: Colors.white),
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
                                        ? AppLocalizations.of(context).translate('username')
                                        : null,
                                    autocorrect: false,
                                    autofocus: false,
                                    style: TextStyle(fontSize: 14.0),
                                    decoration: InputDecoration(
                                      hintText: AppLocalizations.of(context).translate('username'),
                                      border: InputBorder.none,
                                      filled: true,
                                      fillColor: Colors.grey[200],
                                      contentPadding: EdgeInsets.all(15.0),
                                    ),
                                  )),
                              TextFormField(
                                controller: _password,
                                validator: (val) =>
                                    val.isEmpty ? AppLocalizations.of(context).translate('password_required') : null,
                                autocorrect: false,
                                autofocus: false,
                                obscureText: true,
                                style: TextStyle(fontSize: 14.0),
                                decoration: InputDecoration(
                                    hintText: AppLocalizations.of(context).translate('password'),
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
                                            AppLocalizations.of(context).translate('login'),
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
