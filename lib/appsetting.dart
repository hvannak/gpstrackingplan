import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Appsetting extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('App Setting')
      ),
      body: MySetting(title: 'App Setting')
    );
  }
}

class MySetting extends StatefulWidget {
  MySetting({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _MySettingState createState() => _MySettingState();
}

class _MySettingState extends State<MySetting> {
  final _formKey = GlobalKey<FormState>();
  final _globalKey = GlobalKey<ScaffoldState>();
  var _url = TextEditingController();
  String _setting = '';
  

  void showSnackbar(BuildContext context) async {
    _setAppSetting();
    final snackBar = SnackBar(content: Text('Data saved'));
    _globalKey.currentState.showSnackBar(snackBar);
  }

  _loadSetting() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _setting = (prefs.getString('url') ?? '');
      _url.text = _setting;
    });
  }

  _setAppSetting() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setString('url', _url.text);
    });
  }

  @override
  void initState() {
    super.initState();
    _loadSetting();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _globalKey,      
      body: Column(
        children: <Widget>[
          Padding(
              padding: EdgeInsets.all(10.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    Padding(
                        padding: EdgeInsets.symmetric(vertical: 10.0),
                        child: TextFormField(
                          controller: _url,
                          validator: (val) =>
                              val.isEmpty ? "Url is required" : null,
                          autocorrect: false,
                          autofocus: false,
                          style: TextStyle(fontSize: 14.0),
                          decoration: InputDecoration(
                            hintText: "Url",
                            border: InputBorder.none,
                            filled: true,
                            fillColor: Colors.grey[200],
                            contentPadding: EdgeInsets.all(15.0),
                          ),
                        )),
                    Padding(
                        padding: EdgeInsets.only(top: 20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Center(
                              child: RaisedButton(
                                padding: EdgeInsets.symmetric(vertical: 15.0),
                                onPressed: () {
                                  if (_formKey.currentState.validate()) {
                                    showSnackbar(context);
                                  }
                                },
                                child: Text(
                                  'Save',
                                  style: TextStyle(fontSize: 14.0),
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
    );
  }
}
