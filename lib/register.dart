import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gpstrackingplan/models/userprofile.dart';
import 'package:gpstrackingplan/verifyuserdata.dart';
import 'package:gpstrackingplan/waitingdialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_localizations.dart';
import 'helpers/apiHelper .dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _formKey = GlobalKey<FormState>();
  final _globalKey = GlobalKey<ScaffoldState>();
  var _userName = TextEditingController();
  var _email = TextEditingController();
  var _fullName = TextEditingController();
  var _linkedCustomerID = TextEditingController();
  var _telephone = TextEditingController();
  var _password = TextEditingController();
  var _confirmPassword = TextEditingController();
  ApiHelper _apiHelper;

  _loadSetting() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _apiHelper = ApiHelper(prefs);
    });
  }

  Future<void> verifyNumber() async {
      Random rnd = new Random();
      int rndnumber = rnd.nextInt(1000);
      var body = {
        'VerifyNumber': rndnumber,
        'EntityID': _linkedCustomerID.text,
        'Telephone': _telephone.text
      };
      WaitingDialogs().showLoadingDialog(context, _globalKey);
      final respone = await _apiHelper.fetchPost('/api/ApplicationUser/Verify', body);
      if(respone.body == 'true') {
        var body1 = {
        'UserName': _userName.text,
        'Password': _password.text,
        'Email': _email.text,
        'FullName': _fullName.text,
        'LinkedCustomerID': _linkedCustomerID.text,
        'Telephone': _telephone.text,
        'DefaultRole': 'DefaultEmployee'
      };
       var user = Userprofile(
          userName: _userName.text,
          password: _password.text,
          email: _email.text,
          fullName: _fullName.text,
          linkedCustomerID: _linkedCustomerID.text,
          telephone: _telephone.text);
        Navigator.of(_globalKey.currentContext,rootNavigator: true).pop();
        Navigator.of(context).pop();
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => VerifyUserData(body:body1, user: user ,random: rndnumber)));
      }
      else{
        Navigator.of(context).pop();
        final snackBar = SnackBar(content: Text('Please verify customerID and telphone again.'));
        _globalKey.currentState.showSnackBar(snackBar);
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
      appBar: AppBar(title: Text(AppLocalizations.of(context).translate('register'))),
      key: _globalKey,
      body: Stack(
        children: <Widget>[
          SingleChildScrollView(
            child: Container(
              child: Column(
                children: <Widget>[
                  Padding(
                      padding: EdgeInsets.all(5.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: <Widget>[
                            Padding(
                                padding: EdgeInsets.symmetric(vertical: 10.0),
                                child: TextFormField(
                                  controller: _userName,
                                  validator: (val) => val.isEmpty
                                      ? AppLocalizations.of(context).translate('username_required')
                                      : null,
                                  autocorrect: false,
                                  autofocus: false,
                                  style: TextStyle(fontSize: 14.0),
                                  decoration: InputDecoration(
                                    hintText: AppLocalizations.of(context).translate('username'),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                          width: 0,
                                          style: BorderStyle.none,
                                        )),
                                    filled: true,
                                    fillColor: Colors.grey[200],
                                    contentPadding: EdgeInsets.all(15.0),
                                  ),
                                )),
                            Padding(
                                padding: EdgeInsets.symmetric(vertical: 5.0),
                                child: TextFormField(
                                  controller: _fullName,
                                  validator: (val) => val.isEmpty
                                      ? AppLocalizations.of(context).translate('fullname_required')
                                      : null,
                                  autocorrect: false,
                                  autofocus: false,
                                  style: TextStyle(fontSize: 14.0),
                                  decoration: InputDecoration(
                                    hintText: AppLocalizations.of(context).translate('fullname'),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                          width: 0,
                                          style: BorderStyle.none,
                                        )),
                                    filled: true,
                                    fillColor: Colors.grey[200],
                                    contentPadding: EdgeInsets.all(15.0),
                                  ),
                                )),
                            Padding(
                                padding: EdgeInsets.symmetric(vertical: 5.0),
                                child: TextFormField(
                                  controller: _email,
                                  autocorrect: false,
                                  autofocus: false,
                                  style: TextStyle(fontSize: 14.0),
                                  decoration: InputDecoration(
                                    hintText: AppLocalizations.of(context).translate('email'),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                          width: 0,
                                          style: BorderStyle.none,
                                        )),
                                    filled: true,
                                    fillColor: Colors.grey[200],
                                    contentPadding: EdgeInsets.all(15.0),
                                  ),
                                )),
                            Padding(
                                padding: EdgeInsets.symmetric(vertical: 5.0),
                                child: TextFormField(
                                  controller: _linkedCustomerID,
                                  validator: (val) => val.isEmpty
                                      ? AppLocalizations.of(context).translate('salepersonid_required')
                                      : null,
                                  autocorrect: false,
                                  autofocus: false,
                                  style: TextStyle(fontSize: 14.0),
                                  decoration: InputDecoration(
                                    hintText: AppLocalizations.of(context).translate('salepersonid'),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                          width: 0,
                                          style: BorderStyle.none,
                                        )),
                                    filled: true,
                                    fillColor: Colors.grey[200],
                                    contentPadding: EdgeInsets.all(15.0),
                                  ),
                                )),
                            Padding(
                                padding: EdgeInsets.symmetric(vertical: 5.0),
                                child: TextFormField(
                                  controller: _telephone,
                                  keyboardType: TextInputType.number,
                                  validator: (val) => val.isEmpty
                                      ? AppLocalizations.of(context).translate('phone_required')
                                      : null,
                                  autocorrect: false,
                                  autofocus: false,
                                  style: TextStyle(fontSize: 14.0),
                                  decoration: InputDecoration(
                                    hintText: AppLocalizations.of(context).translate('phone'),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                          width: 0,
                                          style: BorderStyle.none,
                                        )),
                                    filled: true,
                                    fillColor: Colors.grey[200],
                                    contentPadding: EdgeInsets.all(15.0),
                                  ),
                                )),
                            Padding(
                                padding: EdgeInsets.symmetric(vertical: 5.0),
                                child: TextFormField(
                                  controller: _password,
                                  validator: (val) => val.isEmpty
                                      ? AppLocalizations.of(context).translate('password_required')
                                      : null,
                                  autocorrect: false,
                                  autofocus: false,
                                  obscureText: true,
                                  style: TextStyle(fontSize: 14.0),
                                  decoration: InputDecoration(
                                    hintText: AppLocalizations.of(context).translate('password'),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                          width: 0,
                                          style: BorderStyle.none,
                                        )),
                                    filled: true,
                                    fillColor: Colors.grey[200],
                                    contentPadding: EdgeInsets.all(15.0),
                                  ),
                                )),
                            Padding(
                                padding: EdgeInsets.symmetric(vertical: 5.0),
                                child: TextFormField(
                                  controller: _confirmPassword,
                                  validator: (val) => val != _password.text
                                      ? AppLocalizations.of(context).translate('confirm_not_match')
                                      : null,
                                  autocorrect: false,
                                  autofocus: false,
                                  obscureText: true,
                                  style: TextStyle(fontSize: 14.0),
                                  decoration: InputDecoration(
                                    hintText: AppLocalizations.of(context).translate('confirm_password'),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                          width: 0,
                                          style: BorderStyle.none,
                                        )),
                                    filled: true,
                                    fillColor: Colors.grey[200],
                                    contentPadding: EdgeInsets.all(15.0),
                                  ),
                                )),
                            Padding(
                                padding: EdgeInsets.only(top: 5.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Center(
                                      child: RaisedButton(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 15.0),
                                        color: Colors.lightBlue,    
                                        shape: new RoundedRectangleBorder(
                                          borderRadius:
                                              new BorderRadius.circular(8.0),
                                        ),
                                        onPressed: () {
                                          if (_formKey.currentState
                                              .validate()) {
                                            // print('Click');
                                            // fetchPost();
                                            // _handleSubmit(context);
                                            verifyNumber();
                                          }
                                        },
                                        child: Text(
                                          AppLocalizations.of(context).translate('register'),
                                          style: TextStyle(fontSize: 16.0 , color: Colors.white),
                                        ),
                                      ),
                                    )
                                  ],
                                ))
                          ],
                        ),
                      ))
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
