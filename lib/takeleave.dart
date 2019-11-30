import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gpstrackingplan/helpers/controlHelper.dart';
import 'package:gpstrackingplan/helpers/datasearchleave.dart';
import 'package:gpstrackingplan/models/takeleavemodel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'helpers/apiHelper .dart';

class Takeleave extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
  List<Leave> _listLeave = [];
  ApiHelper _apiHelper;

 _loadSetting() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _apiHelper = ApiHelper(prefs);
    });
  }

  Future<List<Leave>> fetchLeaveData() async {
    var response = await _apiHelper.fetchData('/api/TakeLeaves');
    if (response.statusCode == 200) {
      var list = jsonDecode(response.body) as List;
      _listLeave = list.map((i) => Leave.fromJson(i)).toList();
      _listLeave.sort((a, b) => b.leaveID.compareTo(a.leaveID));
      return _listLeave;
      // var jsonData = jsonDecode(response.body);
      // _listLeave = [];
      // for (var item in jsonData) {
      //   Leave leave = Leave.fromJson(item);
      //   _listLeave.add(leave);
      // }
      // _listLeave.sort((a, b) => b.leaveID.compareTo(a.leaveID));
      // return _listLeave;
    } else {
      final snackBar = SnackBar(content: Text('Failed to load'));
      _globalKey.currentState.showSnackBar(snackBar);
      print(response.statusCode);
      throw Exception('Failed to load post');
    }
  }

  Future<Leave> deletLeaveData(int leaveId) async {
    var response = await _apiHelper.deleteData('/api/TakeLeaves/',leaveId);
    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      Leave leave = Leave.fromJson(jsonData);
      final snackBar = SnackBar(content: Text('Delete successfully'));
      _globalKey.currentState.showSnackBar(snackBar);
      return leave;
    } else {
      final snackBar = SnackBar(content: Text('Failed to load'));
      _globalKey.currentState.showSnackBar(snackBar);
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
        title: Text('Take Leave'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(
                  context: context,
                  delegate: DataSearchLeave(_listLeave,_apiHelper));
            },
          )
        ],
      ),
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
                return new Dismissible(
                  key: new Key(snapshot.data[index].leaveID.toString()),
                  onDismissed: (direction) {
                    deletLeaveData(snapshot.data[index].leaveID);
                    snapshot.data.removeAt(index);
                  },
                  child: Card(
                    child: ListTile(
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
                    ),
                  ),
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
  var _employeeName = TextEditingController();
  var _workPlace = TextEditingController();
  var _reasion = TextEditingController();
  var _fromDate = TextEditingController();
  var _toDate = TextEditingController();
  ControlHelper _controlHelper = ControlHelper();
  ApiHelper _apiHelper;

  _MyTakeLeaveAddEditState(this.leave, this.title);

  _loadSetting() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _apiHelper = ApiHelper(prefs);
      if (leave == null) {
        _employeeName.text = _apiHelper.fullname;
      }
    });
  }

  Future<Leave> saveLeaveData(int leaveId) async {
    var response;
    var body = {
      'LeaveID': leaveId,
      'EmployeeName': _employeeName.text,
      'WorkPlace': _workPlace.text,
      'FromDate': _fromDate.text,
      'ToDate': _toDate.text,
      'Reasion': _reasion.text
    };
    if (leaveId > 0) {
      response = await _apiHelper.fetchPut('/api/TakeLeaves/', body, leaveId);
    } else {
      response = await _apiHelper.fetchPost1('/api/TakeLeaves', body);
    }
    if (response.statusCode == 200 ||
        response.statusCode == 201 ||
        response.statusCode == 204) {
      final snackBar = SnackBar(content: Text('Save successfully'));
      _globalKey.currentState.showSnackBar(snackBar);
      Leave leave;
      if (response.statusCode == 201) {
        var jsonData = jsonDecode(response.body);
        leave = Leave.fromJson(jsonData);
      }
      Navigator.of(context).pop();
      return leave;
    } else {
      final snackBar = SnackBar(content: Text('Failed to save'));
      _globalKey.currentState.showSnackBar(snackBar);
      print(response.statusCode);
      throw Exception('Failed to load post');
    }
  }

  @override
  void initState() {
    super.initState();
    if (leave != null) {
      print('Employee');
      print(leave.employeeName);
      _employeeName.text = leave.employeeName.toString();
      _workPlace.text = leave.workPlace.toString();
      _fromDate.text = DateFormat('yyyy/MM/dd').format(leave.fromDate);
      _toDate.text = DateFormat('yyyy/MM/dd').format(leave.toDate);
      _reasion.text = leave.reasion.toString();
    }
    _loadSetting();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[300],
        key: _globalKey,
        appBar: AppBar(title: Text(this.title)),
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
                                    controller: _employeeName,
                                    enabled: false,
                                    validator: (val) => val.isEmpty
                                        ? "Employee is required"
                                        : null,
                                    autocorrect: false,
                                    autofocus: false,
                                    style: TextStyle(fontSize: 14.0),
                                    decoration: InputDecoration(
                                      hintText: "Employee",
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
                              Padding(
                                  padding: EdgeInsets.symmetric(vertical: 5.0),
                                  child: TextFormField(
                                    controller: _workPlace,
                                    validator: (val) => val.isEmpty
                                        ? "WorkPlace is required"
                                        : null,
                                    autocorrect: false,
                                    autofocus: false,
                                    style: TextStyle(fontSize: 14.0),
                                    decoration: InputDecoration(
                                      hintText: "WorkPlace",
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
                              Padding(
                                  padding: EdgeInsets.symmetric(vertical: 5.0),
                                  child: TextFormField(
                                    controller: _fromDate,
                                    validator: (val) => val.isEmpty
                                        ? "From date is required"
                                        : null,
                                    autocorrect: false,
                                    autofocus: false,
                                    style: TextStyle(fontSize: 14.0),
                                    decoration: InputDecoration(
                                      hintText: "From date",
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
                                    onTap: () async{
                                      var date = await _controlHelper.selectDate(context);
                                      _fromDate.text = date;
                                    },
                                  )),
                              Padding(
                                  padding: EdgeInsets.symmetric(vertical: 5.0),
                                  child: TextFormField(
                                    controller: _toDate,
                                    validator: (val) => val.isEmpty
                                        ? "To date is required"
                                        : null,
                                    autocorrect: false,
                                    autofocus: false,
                                    style: TextStyle(fontSize: 14.0),
                                    decoration: InputDecoration(
                                      hintText: "To date",
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
                                    onTap: () async{
                                      var date = await _controlHelper.selectDate(context);
                                      _toDate.text = date;
                                    },
                                  )),
                              Padding(
                                  padding: EdgeInsets.symmetric(vertical: 5.0),
                                  child: TextFormField(
                                    controller: _reasion,
                                    validator: (val) => val.isEmpty
                                        ? "Reasion is required"
                                        : null,
                                    autocorrect: false,
                                    autofocus: false,
                                    style: TextStyle(fontSize: 14.0),
                                    decoration: InputDecoration(
                                      hintText: "Reasion",
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
                                          padding: EdgeInsets.symmetric(
                                              vertical: 15.0),
                                          shape: new RoundedRectangleBorder(
                                            borderRadius:
                                                new BorderRadius.circular(8.0),
                                          ),
                                          onPressed: () {
                                            if (_formKey.currentState
                                                .validate()) {
                                              // showSnackbar(context);
                                              if (leave == null) {
                                                print('Post');
                                                saveLeaveData(0);
                                              } else {
                                                saveLeaveData(leave.leaveID);
                                              }
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
              ),
            )
          ],
        ));
  }
}
