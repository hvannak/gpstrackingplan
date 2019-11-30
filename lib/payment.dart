
// import 'dart:convert';
// import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:gpstrackingplan/displaypayment.dart';
// import 'models/payment.dart';

class Payment extends StatefulWidget {

  _PaymentState createState() => new _PaymentState();
}

class _PaymentState extends State<Payment> {
  final _formKey = GlobalKey<FormState>();
  final _globalKey = GlobalKey<ScaffoldState>();
  // String _token = '';
  // String _urlSetting = '';
  String customerId = '';
  var fromdate = TextEditingController();
  var todate = TextEditingController();
  // List<Paymentmodel> _list = [];
   _loadSetting() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      // _token = (prefs.getString('token') ?? '');
      // _urlSetting = (prefs.getString('url') ?? '');
      customerId = (prefs.getString('linkedCustomerID') ?? '');

      print('test customerID = $customerId');
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
        fromdate.text = DateFormat('yyyy-MM-dd').format(picked);
      } else {
        todate.text = DateFormat('yyyy-MM-dd').format(picked);
      }
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
        backgroundColor: Colors.grey[300],
        key: _globalKey,
        appBar: AppBar(title: Text('Payment')),
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
                                  padding: EdgeInsets.symmetric(vertical: 5.0),
                                  child: TextFormField(
                                    controller: fromdate,
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
                                    onTap: () {
                                      _selectDate(context, 'from');
                                    },
                                  )),
                              Padding(
                                  padding: EdgeInsets.symmetric(vertical: 5.0),
                                  child: TextFormField(
                                    controller: todate,
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
                                    onTap: () {
                                      _selectDate(context, 'to');
                                    },
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
                                                Navigator.of(context).pop();
                                                 Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) => DisplayPayment(fromDate: fromdate.text,toDate: todate.text)));
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





