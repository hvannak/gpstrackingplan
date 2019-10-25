import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gpstrackingplan/models/takeleavemodel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class Takeleave extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Take Leave')),
      body: MyTakeLeave(title: 'Take Leave'),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => MyTakeLeaveAddEdit(
                        leave: null,
                        title: 'Add Leave',
                      )));
        },
        child: Icon(Icons.navigation),
        backgroundColor: Colors.green,
      ),
    );
  }
}

class MyTakeLeave extends StatefulWidget {
  MyTakeLeave({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _MyTakeLeaveState createState() => _MyTakeLeaveState();
}

class _MyTakeLeaveState extends State<MyTakeLeave> {
  final _formKey = GlobalKey<FormState>();
  final _globalKey = GlobalKey<ScaffoldState>();
  String _token = '';
  String _urlSetting = '';

  _loadSetting() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _token = (prefs.getString('token') ?? '');
      _urlSetting = (prefs.getString('url') ?? '');
      // print(_urlSetting);
      // print(_token);
    });
  }

  Future<List<Leave>> fetchLeaveData() async {
    final response = await http.get(_urlSetting + '/api/TakeLeaves', headers: {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: "Bearer " + _token
    });

    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      List<Leave> listLeave = [];
      for (var item in jsonData) {
        Leave leave = Leave.fromJson(item);
        listLeave.add(leave);
      }
      print(listLeave.length);
      return listLeave;
    } else {
      final snackBar = SnackBar(content: Text('Failed to login'));
      _globalKey.currentState.showSnackBar(snackBar);
      print(response.statusCode);
      throw Exception('Failed to load post');
    }
  }

  @override
  void initState() {
    super.initState();
    _loadSetting();
    // fetchLeaveData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _globalKey,
      body: Container(
          child: FutureBuilder(
        future: fetchLeaveData(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.data == null) {
            return Container(
              child: Center(child: Text('Loading...')),
            );
          } else {
            return ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  leading: Icon(Icons.person),
                  title: Text(snapshot.data[index].employeeName),
                  subtitle: Text(snapshot.data[index].workPlace +
                      '-(' +
                      DateFormat("yyy/MM/dd")
                          .format(snapshot.data[index].fromDate) +
                      '-' +
                      DateFormat("yyy/MM/dd")
                          .format(snapshot.data[index].toDate) +
                      ")"),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MyTakeLeaveAddEdit(
                                  leave: snapshot.data[index],
                                  title: 'Edit Leave',
                                )));
                  },
                );
              },
            );
          }
        },
      )),
    );
  }
}

class MyTakeLeaveAddEdit extends StatefulWidget {
  final Leave leave;
  final String title;
  MyTakeLeaveAddEdit({Key key, this.leave, this.title}) : super(key: key);
  @override
  _MyTakeLeaveAddEditState createState() =>
      _MyTakeLeaveAddEditState(this.leave, this.title);
}

class _MyTakeLeaveAddEditState extends State<MyTakeLeaveAddEdit> {
  final Leave leave;
  final String title;
  final _formKey = GlobalKey<FormState>();
  final _globalKey = GlobalKey<ScaffoldState>();
  String _token = '';
  String _urlSetting = '';
  var _employeeName = TextEditingController();
  var _workPlace = TextEditingController();
  var _reasion = TextEditingController();
  var _fromDate = TextEditingController();
  var _toDate = TextEditingController();

  _MyTakeLeaveAddEditState(this.leave, this.title);

  _loadSetting() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _token = (prefs.getString('token') ?? '');
      _urlSetting = (prefs.getString('url') ?? '');
      // print(_urlSetting);
      // print(_token);
    });
  }

  Future<Null> _selectDate(BuildContext context, String datename) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2018),
      lastDate: DateTime(2050),
      builder: (BuildContext context, Widget child) {
        return Theme(
          data: ThemeData.dark(),
          child: child,
        );
      },
    );
    setState(() {
      if (datename == 'from') {
        _fromDate.text = DateFormat('yyyy/MM/dd').format(picked);
      } else {
        _toDate.text = DateFormat('yyyy/MM/dd').format(picked);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow[200],
      key: _globalKey,
      appBar: AppBar(title: Text(this.title)),
      body: Column(
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
                          controller: _employeeName,
                          validator: (val) =>
                              val.isEmpty ? "Employee is required" : null,
                          autocorrect: false,
                          autofocus: false,
                          style: TextStyle(fontSize: 14.0),
                          decoration: InputDecoration(
                            hintText: "Employee",
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
                          controller: _workPlace,
                          validator: (val) =>
                              val.isEmpty ? "WorkPlace is required" : null,
                          autocorrect: false,
                          autofocus: false,
                          style: TextStyle(fontSize: 14.0),
                          decoration: InputDecoration(
                            hintText: "WorkPlace",
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
                          controller: _fromDate,
                          validator: (val) =>
                              val.isEmpty ? "From date is required" : null,
                          autocorrect: false,
                          autofocus: false,
                          style: TextStyle(fontSize: 14.0),
                          decoration: InputDecoration(
                            hintText: "From date",
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
                          onTap: () {
                            _selectDate(context, 'from');
                          },
                        )),
                    Padding(
                        padding: EdgeInsets.symmetric(vertical: 5.0),
                        child: TextFormField(
                          controller: _toDate,
                          validator: (val) =>
                              val.isEmpty ? "To date is required" : null,
                          autocorrect: false,
                          autofocus: false,
                          style: TextStyle(fontSize: 14.0),
                          decoration: InputDecoration(
                            hintText: "To date",
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
                          onTap: () {
                            _selectDate(context, 'to');
                          },
                        )),
                    Padding(
                        padding: EdgeInsets.symmetric(vertical: 5.0),
                        child: TextFormField(
                          controller: _reasion,
                          validator: (val) =>
                              val.isEmpty ? "Reasion is required" : null,
                          autocorrect: false,
                          autofocus: false,
                          style: TextStyle(fontSize: 14.0),
                          decoration: InputDecoration(
                            hintText: "Reasion",
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
                          keyboardType: TextInputType.multiline,
                          maxLines: 4,
                        )),
                    Padding(
                        padding: EdgeInsets.only(top: 5.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Center(
                              child: RaisedButton(
                                padding: EdgeInsets.symmetric(vertical: 15.0),
                                shape: new RoundedRectangleBorder(
                                  borderRadius: new BorderRadius.circular(8.0),
                                ),
                                onPressed: () {
                                  if (_formKey.currentState.validate()) {
                                    // showSnackbar(context);
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
