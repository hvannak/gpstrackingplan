import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gpstrackingplan/models/customermodel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Routevisiting extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Route Visiting'),
      ),
      body: MyRouteVisiting(),
    );
  }
}

class MyRouteVisiting extends StatefulWidget {
  @override
  _MyRouteVisitingState createState() => _MyRouteVisitingState();
}

class _MyRouteVisitingState extends State<MyRouteVisiting> {
  final _formKey = GlobalKey<FormState>();
  final _globalKey = GlobalKey<ScaffoldState>();
  String _token = '';
  String _urlSetting = '';
  String _checkType = 'IN';
  String _customer = 'NEW';
  String _image = '';
  var _customerSearch = TextEditingController();
  List<Customermodel> _listCustomer = [];

  _loadSetting() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _token = (prefs.getString('token') ?? '');
      _urlSetting = (prefs.getString('url') ?? '');
    });
  }

  Future<List<Customermodel>> fetchCustomerData(String name) async {
    final response = await http.get(_urlSetting + '/api/Customer/CustomerName/' + name, headers: {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: "Bearer " + _token
    });

    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      _listCustomer = [];
      for (var item in jsonData) {
        Customermodel customermodel = Customermodel.fromJson(item);
        _listCustomer.add(customermodel);
      }
      _listCustomer.sort((a, b) => b.customerName.compareTo(a.customerName));
      print(_listCustomer.length);
      return _listCustomer;
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
    _listCustomer.add(new Customermodel(
      customerID: 'NEW',
      customerName: 'NEW'
    ));
    _listCustomer.add(new Customermodel(
      customerID: 'OLD',
      customerName: 'OLD'
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[300],
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
                                child: DropdownButtonFormField(
                                  items: [
                                    DropdownMenuItem<String>(
                                      child: Text('Check In'),
                                      value: 'IN',
                                    ),
                                    DropdownMenuItem<String>(
                                      child: Text('Check Out'),
                                      value: 'OUT',
                                    ),
                                    DropdownMenuItem<String>(
                                      child: Text('Depo/Farm'),
                                      value: 'CUS',
                                    ),
                                    DropdownMenuItem<String>(
                                      child: Text('Sub Depo'),
                                      value: 'SUB',
                                    ),
                                  ],
                                  onChanged: (String value) {
                                    setState(() {
                                      _checkType = value;
                                      print(_checkType);
                                    });
                                  },
                                  validator: (val) => val == null
                                      ? "Check type is required"
                                      : null,
                                  hint: Text('Select Item'),
                                  value: _checkType,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                          style: BorderStyle.solid,
                                        )),
                                    filled: true,
                                    fillColor: Colors.grey[200],
                                    contentPadding: EdgeInsets.all(15.0),
                                  ),
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Expanded(
                                    child: Padding(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 1.0),
                                        child: TextFormField(
                                          controller: _customerSearch,
                                          autocorrect: false,
                                          autofocus: false,
                                          style: TextStyle(fontSize: 14.0),
                                          decoration: InputDecoration(
                                            hintText: "Search Customer",
                                            border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                borderSide: BorderSide(
                                                  width: 0,
                                                  style: BorderStyle.none,
                                                )),
                                            filled: true,
                                            fillColor: Colors.grey[200],
                                            contentPadding:
                                                EdgeInsets.all(15.0),
                                          ),
                                        )),
                                  ),
                                  Expanded(
                                    child: Padding(
                                        padding: EdgeInsets.only(top: 5.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            Center(
                                              child: RaisedButton(
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 15.0),
                                                shape:
                                                    new RoundedRectangleBorder(
                                                  borderRadius:
                                                      new BorderRadius.circular(
                                                          8.0),
                                                ),
                                                onPressed: () {
                                                  fetchCustomerData(_customerSearch.text);
                                                },
                                                child: Text(
                                                  'Search',
                                                  style:
                                                      TextStyle(fontSize: 14.0),
                                                ),
                                              ),
                                            )
                                          ],
                                        )),
                                  )
                                ],
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 10.0),
                                child: DropdownButtonFormField(
                                  // items: [
                                  //   DropdownMenuItem<String>(
                                  //     child: Text('-NEW-'),
                                  //     value: 'NEW',
                                  //   ),
                                  //   DropdownMenuItem<String>(
                                  //     child: Text('-OLD-'),
                                  //     value: 'OLD',
                                  //   ),
                                  // ],                              
                                  items: _listCustomer.map((f) =>DropdownMenuItem(
                                    child: Text(f.customerName),
                                    value: f.customerName,
                                  )).toList(),
                                  onChanged: (String value) {
                                    setState(() {
                                      _customer = value;
                                      print(_customer);
                                    });
                                  },
                                  validator: (val) => val == null
                                      ? "Customer is required"
                                      : null,
                                  hint: Text('Select Item'),
                                  value: _customer,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                          style: BorderStyle.solid,
                                        )),
                                    filled: true,
                                    fillColor: Colors.grey[200],
                                    contentPadding: EdgeInsets.all(15.0),
                                  ),
                                ),
                              ),
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
