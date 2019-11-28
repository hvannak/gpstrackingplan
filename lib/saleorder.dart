import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gpstrackingplan/addsaleorder.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'helpers/apiHelper .dart';
import 'models/saleordermodel.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class SaleOrder extends StatefulWidget {
  _SaleOrderState createState() => _SaleOrderState();
}

class _SaleOrderState extends State<SaleOrder> {
  String _token = '';
  String _urlSetting = '';
  final _globalKey = GlobalKey<ScaffoldState>();
  String customerId = '';
  List<SaleOrderModel> _list = [];
  ApiHelper _apiHelper;

  Future<List<SaleOrderModel>> fetchSaleOrderData() async {
    final response = await http
        .get(_urlSetting + '/api/SaleOrder/Customer/' + customerId, headers: {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: "Bearer " + _token
    });
    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      _list = [];
      for (var item in jsonData) {
        SaleOrderModel saleOrder = SaleOrderModel.fromJson(item);
        _list.add(saleOrder);
      }
      return _list;
    } else {
      throw Exception('Failed to load post');
    }
  }

  _loadSetting() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _apiHelper = ApiHelper(prefs);
      customerId = _apiHelper.linkedCustomerID;
    });
  }

  Future<String> deleteSaleOrder(int saleId) async {
    print('Delete');
    var response = await _apiHelper.deleteData('/api/SaleOrder/', saleId);
    if (response.statusCode == 200) {
      final snackBar = SnackBar(content: Text('Delete successfully'));
      _globalKey.currentState.showSnackBar(snackBar);
      return response.body;
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
      key: _globalKey,
      appBar: AppBar(
        title: Text('Sale Order'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add_circle),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => AddSaleOrder()));
            },
          )
        ],
      ),
      body: Container(
          child: FutureBuilder(
        future: fetchSaleOrderData(),
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
                  key: new Key(snapshot.data[index].saleOrderId.toString()),
                  onDismissed: (direction){
                    deleteSaleOrder(snapshot.data[index].saleOrderId);
                    snapshot.data.removeAt(index);
                  },
                  child: Card(
                    child: ListTile(
                      title: Text(
                        snapshot.data[index].orderNumber,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        snapshot.data[index].customerDesc +
                            ' on ' +
                            DateFormat("yyyy/MM/dd")
                                .format(snapshot.data[index].orderDate) +
                            ' quality ' +
                            snapshot.data[index].orderQty.toString() +
                            ' total ' +
                            snapshot.data[index].orderTotal.toString(),
                      ),
                      onTap: () {
                        Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AddSaleOrder(
                                        saleorder: snapshot.data[index],
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
