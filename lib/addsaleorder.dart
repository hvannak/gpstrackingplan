import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:gpstrackingplan/displaysaleorderitem.dart';
import 'package:gpstrackingplan/models/saleordermodel.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'helpers/apiHelper .dart';
import 'models/saleorderitemmodel.dart';

class AddSaleOrder extends StatefulWidget {
  final SaleOrderModel saleorder;
  AddSaleOrder({
    Key key,
    this.saleorder,
  }) : super(key: key);
  @override
  _AddSaleOrderState createState() => _AddSaleOrderState(this.saleorder);
}

class _AddSaleOrderState extends State<AddSaleOrder> {
  final SaleOrderModel saleorder;
  final _formKey = GlobalKey<FormState>();
  final _globalKey = GlobalKey<ScaffoldState>();
  String _token = '';
  String _urlSetting = '';
  var _orderNbr = TextEditingController();
  var _customerId = TextEditingController();
  var _description = TextEditingController();
  var _oderQty = TextEditingController();
  var _orderTotal = TextEditingController();
  var _date = TextEditingController();
  _AddSaleOrderState(this.saleorder);
  ApiHelper _apiHelper;

  _loadSetting() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _token = (prefs.getString('token') ?? '');
      _urlSetting = (prefs.getString('url') ?? '');
      _customerId.text = (prefs.getString('linkedCustomerID') ?? '');
      _apiHelper = ApiHelper(prefs);
    });
  }

  Future<Null> _selectDate(BuildContext context) async {
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
      _date.text = DateFormat('yyyy-MM-dd').format(picked);
    });
  }

  List<SaleOrderItemModel> _listSaleItem = [];
  _navigateTakePictureScreen(BuildContext context) async {
    List<SaleOrderItemModel> result = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => DisplaySaleOrderItem()));
    print('back result');
    print('result = ${result.length}');
    setState(() {
      _listSaleItem = result;
      print('item result add page saleorder = ${_listSaleItem.length}');
    });
    return _listSaleItem;
  }

  Future<String> fetchPost(saleOrderId) async {
    var response;
    var body = {
      'SaleOrderID': saleOrderId,
      'OrderNbr': _orderNbr.text,
      'CustomerID': _customerId.text,
      'CustomerDescr': 'test',
      'OrderDesc': _description.text,
      'OrderQty': _oderQty.text,
      'OrderTotal': _orderTotal.text,
      'OrderDate': _date.text,
      'Details': SaleOrderItemModel.encondeToJson(_listSaleItem)
    };
    print(body);
    if (saleOrderId != 0) {
      response = await _apiHelper.fetchPut('/SaleOrder/Update', body, saleOrderId);
    } else {
      response = await http.post(_urlSetting + '/api/SaleOrder/Create',
        body: json.encode(body),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.authorizationHeader: "Bearer " + _token
        });
    }
    // final response = await http.post(_urlSetting + '/api/SaleOrder/Create',
    //     body: json.encode(body),
    //     headers: {
    //       HttpHeaders.contentTypeHeader: 'application/json',
    //       HttpHeaders.authorizationHeader: "Bearer " + _token
    //     });
    print(response.statusCode);
    if (response.statusCode == 200) {
      Navigator.of(context).pop();
      return response.body;
    } else {
      print(response.statusCode);
      throw Exception('Failed to load post');
    }
  }

  @override
  void initState() {
    super.initState();
    _loadSetting();
    _orderNbr.text = 'New';
    if (saleorder != null) {
      print('Employee');
      print(saleorder.orderNumber);
      _orderNbr.text = saleorder.orderNumber.toString();
      _customerId.text = saleorder.customerId.toString();
      _description.text = saleorder.orderDesc.toString();
      _oderQty.text = saleorder.orderQty.toString();
      _orderTotal.text = saleorder.orderTotal.toString();
      _date.text = DateFormat('yyyy/MM/dd').format(saleorder.orderDate);
      
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: Text('Add Sale Order'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add_circle),
            onPressed: () {
              _navigateTakePictureScreen(context);
            },
          )
        ],
      ),
      body: Stack(
        children: <Widget>[
          SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
              decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(20.0)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        Padding(
                            padding: EdgeInsets.symmetric(vertical: 10.0),
                            child: TextFormField(
                              controller: _orderNbr,
                              validator: (val) =>
                                  val.isEmpty ? "OrderNbr is required" : null,
                              autocorrect: false,
                              autofocus: false,
                              style: TextStyle(fontSize: 14.0),
                              decoration: InputDecoration(
                                hintText: "OrderNbr",
                                border: InputBorder.none,
                                filled: true,
                                fillColor: Colors.grey[200],
                                contentPadding: EdgeInsets.all(15.0),
                              ),
                            )),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 10.0),
                          child: TextFormField(
                            controller: _customerId,
                            validator: (val) =>
                                val.isEmpty ? "CustomerID is required" : null,
                            autocorrect: false,
                            autofocus: false,
                            style: TextStyle(fontSize: 14.0),
                            decoration: InputDecoration(
                                hintText: "CustomerID",
                                border: InputBorder.none,
                                filled: true,
                                fillColor: Colors.grey[200],
                                contentPadding: EdgeInsets.all(15.0)),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 10.0),
                          child: TextFormField(
                            controller: _description,
                            autocorrect: false,
                            autofocus: false,
                            style: TextStyle(fontSize: 14.0),
                            decoration: InputDecoration(
                                hintText: "Description",
                                border: InputBorder.none,
                                filled: true,
                                fillColor: Colors.grey[200],
                                contentPadding: EdgeInsets.all(15.0)),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 10.0),
                          child: TextFormField(
                            controller: _oderQty,
                            validator: (val) =>
                                val.isEmpty ? "OrderQty is required" : null,
                            autocorrect: false,
                            autofocus: false,
                            style: TextStyle(fontSize: 14.0),
                            decoration: InputDecoration(
                                hintText: "OrderQty",
                                border: InputBorder.none,
                                filled: true,
                                fillColor: Colors.grey[200],
                                contentPadding: EdgeInsets.all(15.0)),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 10.0),
                          child: TextFormField(
                            controller: _orderTotal,
                            validator: (val) =>
                                val.isEmpty ? "OrderTotal is required" : null,
                            autocorrect: false,
                            autofocus: false,
                            style: TextStyle(fontSize: 14.0),
                            decoration: InputDecoration(
                                hintText: "OrderTotal",
                                border: InputBorder.none,
                                filled: true,
                                fillColor: Colors.grey[200],
                                contentPadding: EdgeInsets.all(15.0)),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 10.0),
                          child: TextFormField(
                            controller: _date,
                            validator: (val) =>
                                val.isEmpty ? "Date is required" : null,
                            autocorrect: false,
                            autofocus: false,
                            style: TextStyle(fontSize: 14.0),
                            decoration: InputDecoration(
                              hintText: "Date",
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
                              _selectDate(context);
                            },
                          ),
                        ),
                        Padding(
                            padding: EdgeInsets.only(top: 20.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Center(
                                  child: RaisedButton(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 15.0),
                                    color: Colors.lightBlue,
                                    shape: new RoundedRectangleBorder(
                                      borderRadius:
                                          new BorderRadius.circular(8.0),
                                    ),
                                    onPressed: () {
                                      if (_formKey.currentState.validate()) {
                                        if (saleorder == null) {
                                          print('Post');
                                          fetchPost(0);
                                        } else {
                                          fetchPost(saleorder.saleOrderId);
                                        }
                                      }
                                    },
                                    child: Text(
                                      'Submit',
                                      style: TextStyle(
                                        fontSize: 18.0,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ))
                      ],
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
