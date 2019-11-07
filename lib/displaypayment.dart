import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/payment.dart';
import 'package:http/http.dart' as http;


class DisplayPayment extends StatefulWidget {
  final String fromDate;
  final String toDate;
  DisplayPayment({this.fromDate, this.toDate});
  _DisplayPaymentState createState() =>
      _DisplayPaymentState(this.fromDate, this.toDate);
}


class _DisplayPaymentState extends State<DisplayPayment> {
  final String fromDate;
  final String toDate;
  String _token = '';
  String _urlSetting = '';
  String customerId = '';
  List<Paymentmodel> _list = [];
  _DisplayPaymentState(this.fromDate, this.toDate);

  Future<List<Paymentmodel>> fetchProfileData() async {
    print('test from date= $fromDate');
    print('test to date = $toDate');
    final response = await http.get(
        _urlSetting +
            '/api/CustomerPayment/CustomerID/' +
            customerId +
            '/' +
            fromDate +
            '/' +
            toDate,
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.authorizationHeader: "Bearer " + _token
        });
    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      print('test jsonData Payment= $jsonData');
      _list = [];
      for (var item in jsonData['Results']) {
        Paymentmodel payment = Paymentmodel.fromJson(item);
        _list.add(payment);
      }
      print('test list data= ${_list.length}');
      return _list;
    } else {
      print(response.statusCode);
      throw Exception('Failed to load post');
    }
  }

  _loadSetting() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _token = (prefs.getString('token') ?? '');
      _urlSetting = (prefs.getString('url') ?? '');
      customerId = (prefs.getString('linkedCustomerID') ?? '');

      print('test customerID = $customerId');
      // print(_token);
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
      appBar: AppBar(
        title: Text('Take Leave'),
      ),
      body: Container(
        child: FutureBuilder(
        future: fetchProfileData(),
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
                  key: new Key(snapshot.data[index].docType.toString()),
                  onDismissed: (direction) {
                    snapshot.data.removeAt(index);
                  },
                  child: Container(
                    child: ListTile(
                      // leading: Icon(Icons.person),
                      title: Text(snapshot.data[index].customer),
                      subtitle: Text( 
                               DateFormat("yyyy/MM/dd")
                              .format(snapshot.data[index].date) +'-'+
                              snapshot.data[index].docType +'-'+
                              snapshot.data[index].phone1 + '-'+ 
                              snapshot.data[index].referenceNbr +'-'+  
                              snapshot.data[index].paymentAmount.toString()), 
                      // onTap: () {

                      // },
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
