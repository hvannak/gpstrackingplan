import 'package:gpstrackingplan/models/userprofile.dart';
import 'package:gpstrackingplan/waitingdialog.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/apiHelper .dart';
import 'helpers/database_helper.dart';

class VerifyUserData extends StatefulWidget {
  final Map<String, dynamic> body;
  final Userprofile user;
  final int random;
  VerifyUserData({this.body,this.random, this.user});
  @override
  _VerifyUserDataState createState() => _VerifyUserDataState(this.body,this.random, this.user);
}

class _VerifyUserDataState extends State<VerifyUserData> {
  final Map<String, dynamic> body;
  Userprofile user;
  final int random;
  _VerifyUserDataState(this.body,this.random , this.user);
  final _formKey = GlobalKey<FormState>();
  final _globalKey = GlobalKey<ScaffoldState>();
  final _verifyNumber = TextEditingController();
  ApiHelper _apiHelper;

  _loadSetting() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _apiHelper = ApiHelper(prefs);
    });
  }

  Future<void> fetchPost() async {
      try{
        WaitingDialogs().showLoadingDialog(context, _globalKey);
        final response = await _apiHelper.fetchPost1('/api/ApplicationUser/Register', body);
        if (response.statusCode == 200) {
          if (response.body != null) {
          var db = DatabaseHelper();
          db.saveUser(user);
          // Navigator.of(context).pop();
        } else {
          final snackBar = SnackBar(content: Text('EntityID is not exist.'));
          _globalKey.currentState.showSnackBar(snackBar);
        }
          Navigator.of(_globalKey.currentContext,rootNavigator: true).pop();
          Navigator.of(context).pop();
        } else {
          Navigator.of(context).pop();
          final snackBar = SnackBar(content: Text('Failed to register'));
          _globalKey.currentState.showSnackBar(snackBar);
        }
      }
      catch(e){
        Navigator.of(context).pop();
        final snackBar = SnackBar(content: Text('Cannot connect to host'));
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
      appBar: AppBar(title: Text('Verify Number')),
      key: _globalKey,
      body: Container(
          child: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            Padding(
                padding: EdgeInsets.symmetric(vertical: 10.0),
                child: TextFormField(
                  controller: _verifyNumber,
                  keyboardType: TextInputType.number,
                  validator: (val) => val.isEmpty ? "Verify is required" : null,
                  autocorrect: false,
                  autofocus: false,
                  style: TextStyle(fontSize: 14.0),
                  decoration: InputDecoration(
                    hintText: "Verify Number",
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
                        padding: EdgeInsets.symmetric(vertical: 15.0),
                        color: Colors.lightBlue,
                        shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(8.0),
                        ),
                        onPressed: () {
                          if (_formKey.currentState.validate() && _verifyNumber.text.trim() == random.toString()) {
                            fetchPost();
                          }
                          else{
                            final snackBar = SnackBar(content: Text('Your verify number is not correct.'));
                            _globalKey.currentState.showSnackBar(snackBar);
                          }
                        },
                        child: Text(
                          'Verify',
                          style: TextStyle(fontSize: 16.0, color: Colors.white),
                        ),
                      ),
                    )
                  ],
                ))
          ],
        ),
      )),
    );
  }
}
