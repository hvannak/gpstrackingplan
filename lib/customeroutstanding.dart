import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'models/customeroutstandingmodel.dart';

class CustomerOutstanding extends StatefulWidget {
  _CustomerOutstandingState createState() => _CustomerOutstandingState();
}

class _CustomerOutstandingState extends State<CustomerOutstanding> {
  String _token = '';
  String _urlSetting = '';
  String customerId = '';
  List<OutstandingModel> _list = [];
  double total;
  bool isState = false;

  Future<List<OutstandingModel>> fetchOustandingData() async {
    if (isState == false) {
      final response = await http.get(
          _urlSetting + '/api/CustomerOutstanding/CustomerID/' + customerId,
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader: "Bearer " + _token
          });
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        setState(() {
          total = jsonData['BalancebyDocuments']['value'];
          isState = true;
        });
        print('total= $total');
        _list = [];
        for (var item in jsonData['Results']) {
          OutstandingModel payment = OutstandingModel.fromJson(item);
          _list.add(payment);
        }
        print('test list data= ${_list.length}');
        return _list;
      } else {
        throw Exception('Failed to load post');
      }
    }
    else{
      return _list;
    }
  }

  _loadSetting() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _token = (prefs.getString('token') ?? '');
      _urlSetting = (prefs.getString('url') ?? '');
      customerId = (prefs.getString('linkedCustomerID') ?? '');
      print(_urlSetting);
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
        title: Text('Customer Outstanding'),
      ),
      body: Container(
          child: FutureBuilder(
        future: fetchOustandingData(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.data == null) {
            return Container(
              child: Center(child: Text('Loading...')),
            );
          } else {
            return ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (BuildContext context, int index) {
                return Card(
                  child: Container(
                    decoration: BoxDecoration(color: Colors.lightBlue[50]),
                    child: ListTile(
                      title: Text(
                        snapshot.data[index].balance.toString() +
                            ' ' +
                            snapshot.data[index].currency,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        snapshot.data[index].typeDocType +
                            ' on ' +
                            DateFormat("yyyy/MM/dd")
                                .format(snapshot.data[index].date) +
                            ' by ' +
                            snapshot.data[index].referenceNbr,
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      )),
      bottomNavigationBar: BottomAppBar(
        color: Colors.lightBlue,
        child: Container(
          height: 60.0,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('Total: $total' + ' USD',
                  style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}
