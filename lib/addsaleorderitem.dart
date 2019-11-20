import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:gpstrackingplan/models/customermodel.dart';
import 'package:gpstrackingplan/models/inventorymodel.dart';
import 'package:gpstrackingplan/models/saleorderitemmodel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class AddSaleOrderItem extends StatefulWidget {
  @override
  _AddSaleOrderItemState createState() => _AddSaleOrderItemState();
}

class _AddSaleOrderItemState extends State<AddSaleOrderItem> {
  final _formKey = GlobalKey<FormState>();
  final _globalKey = GlobalKey<ScaffoldState>();
  String _token = '';
  String _urlSetting = '';
  String _customerId = '';
  final _orderQty = TextEditingController();
  var _unitPrice = TextEditingController();
  final _extendedPrice = TextEditingController();
  var _inventorySearch = TextEditingController();
  List<InventoryModel> _listInventory = [];
  String _inventory = '';
  String _warehouse = 'M000';
  String _priceclass = '';
  String _inventoryId = '';
  List<Customermodel> _listCustomer = [];

  _loadSetting() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _token = (prefs.getString('token') ?? '');
      _urlSetting = (prefs.getString('url') ?? '');
      _customerId = (prefs.getString('linkedCustomerID') ?? '');
    });
  }

  Future<List<Customermodel>> fetchGetCustomerById(String id) async {
    final response = await http
        .get(_urlSetting + '/api/Customer/CustomerID/' + id, headers: {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: "Bearer " + _token
    });

    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      _listCustomer = [];
      for (var item in jsonData) {
        Customermodel customermodel = Customermodel.fromJson(item);
        _listCustomer.add(customermodel);
        _priceclass = _listCustomer[0].priceclass;
        setState(() {
          _priceclass = _listCustomer[0].priceclass;
          print('set priceclass = $_priceclass');
        });
      }
      return _listCustomer;
    } else {
      final snackBar = SnackBar(content: Text('Failed to load'));
      _globalKey.currentState.showSnackBar(snackBar);
      throw Exception('Failed to load post');
    }
  }

  Future<List<InventoryModel>> fetchInventoryData(String name) async {
    final response = await http
        .get(_urlSetting + '/api/Inventory/InventoryName/' + name, headers: {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: "Bearer " + _token
    });
    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      _listInventory = [];
      for (var item in jsonData) {
        InventoryModel inventorymodel = InventoryModel.fromJson(item);
        _listInventory.add(inventorymodel);
      }
      setState(() {
        _listInventory
            .sort((a, b) => b.inventoryDesc.compareTo(a.inventoryDesc));
        _inventory = _listInventory[0].inventoryId;
      });
      return _listInventory;
    } else {
      final snackBar = SnackBar(content: Text('Failed to load'));
      _globalKey.currentState.showSnackBar(snackBar);
      throw Exception('Failed to load post');
    }
  }

  Future<String> getInventoryPrice(String id, String price) async {
    print('IN funct getInventoryPrice');
    print(id);
    print(price);
    final response = await http.get(
        _urlSetting + '/api/Inventory/InventoryPrice/' + id + '/' + price,
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.authorizationHeader: "Bearer " + _token
        });
    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      // print('jsonData price= ${jsonData['SalesPriceDetails']['Price']['value']}');
      print(jsonData);
      print(jsonData['SalesPriceDetails']);
      if (jsonData['SalesPriceDetails'].toString() != '[]'){
        _unitPrice.text= jsonData['SalesPriceDetails'][0]['Price']['value'].toString();
      }
      else{
        print('else');
        _unitPrice.text = '0.0';
      }
        
  
     print('_unitPrice.text = ${_unitPrice.text}');
      return _unitPrice.text;
    } else {
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
        backgroundColor: Colors.grey[300],
        appBar: AppBar(
          title: Text('Add Sale Order Item'),
        ),
        body: Stack(
          children: <Widget>[
            SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
                child: Column(
                  children: <Widget>[
                    Padding(
                        padding: EdgeInsets.all(5.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: <Widget>[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Expanded(
                                    child: Padding(
                                        padding:
                                            EdgeInsets.symmetric(vertical: 1.0),
                                        child: TextFormField(
                                          controller: _inventorySearch,
                                          textInputAction:
                                              TextInputAction.search,
                                          onFieldSubmitted: (valueget) {
                                            fetchInventoryData(valueget);
                                            fetchGetCustomerById(_customerId);
                                          },
                                          autocorrect: false,
                                          autofocus: false,
                                          style: TextStyle(fontSize: 14.0),
                                          decoration: InputDecoration(
                                            hintText: "Search Inventory",
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
                                                  fetchInventoryData(_inventorySearch.text);
                                                  fetchGetCustomerById(_customerId);
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
                                  items: _listInventory
                                      .map((f) => DropdownMenuItem(
                                            child: AutoSizeText(
                                              f.inventoryDesc,
                                              style: TextStyle(fontSize: 10.0),
                                              maxLines: 5,
                                            ),
                                            value: f.inventoryId,
                                          ))
                                      .toList(),
                                  onChanged: (String value) {
                                    setState(() {
                                      print(value);
                                      _inventory = value;
                                      print('_inventory = $_inventory');
                                      print('_priceclass = $_priceclass');
                                      getInventoryPrice(
                                          _inventory, _priceclass);
                                    });
                                  },
                                  validator: (val) => val == null
                                      ? "Customer is required"
                                      : null,
                                  hint: Text('Select Item'),
                                  value: _inventory,
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
                                padding: EdgeInsets.symmetric(vertical: 10.0),
                                child: DropdownButtonFormField(
                                  items: [
                                    DropdownMenuItem<String>(
                                      child: Text('M000'),
                                      value: 'M000',
                                    ),
                                    DropdownMenuItem<String>(
                                      child: Text('F001'),
                                      value: 'F001',
                                    ),
                                  ],
                                  onChanged: (String value) {
                                    setState(() {
                                      _warehouse = value;
                                    });
                                  },
                                  validator: (val) => val == null
                                      ? "Check type is required"
                                      : null,
                                  hint: Text('Select Item'),
                                  value: _warehouse,
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
                                  padding: EdgeInsets.symmetric(vertical: 10.0),
                                  child: TextFormField(
                                    controller: _orderQty,
                                    validator: (val) => val.isEmpty
                                        ? "Username is required"
                                        : null,
                                    autocorrect: false,
                                    autofocus: false,
                                    style: TextStyle(fontSize: 14.0),
                                    decoration: InputDecoration(
                                      hintText: "OrderQtyr",
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
                                  padding: EdgeInsets.symmetric(vertical: 10.0),
                                  child: TextFormField(
                                    controller: _unitPrice,
                                    validator: (val) => val.isEmpty
                                        ? "Username is required"
                                        : null,
                                    autocorrect: false,
                                    autofocus: false,
                                    style: TextStyle(fontSize: 14.0),
                                    decoration: InputDecoration(
                                      hintText: "UnitPrice",
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
                                  padding: EdgeInsets.symmetric(vertical: 10.0),
                                  child: TextFormField(
                                    controller: _extendedPrice,
                                    validator: (val) => val.isEmpty
                                        ? "Username is required"
                                        : null,
                                    autocorrect: false,
                                    autofocus: false,
                                    style: TextStyle(fontSize: 14.0),
                                    decoration: InputDecoration(
                                      hintText: "ExtendedPrice",
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
                            ],
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
                                color: Colors.lightBlue,
                                shape: new RoundedRectangleBorder(
                                  borderRadius: new BorderRadius.circular(8.0),
                                ),
                                onPressed: () {
                                  if (_formKey.currentState.validate()) {
                                    SaleOrderItemModel itemModel =
                                        SaleOrderItemModel();
                                    itemModel.saleOrderId = 0;
                                    itemModel.orderDetailId = 0;
                                    itemModel.inventoryId = _inventory;
                                    itemModel.orderQty =
                                        double.parse(_orderQty.text);
                                    itemModel.unitPrice =
                                        double.parse(_unitPrice.text);
                                    itemModel.extendedPrice =
                                        double.parse(_extendedPrice.text);
                                    itemModel.warehouseId = _warehouse;
                                    print('testqty= ${itemModel.orderQty}');
                                    Navigator.pop(context, itemModel);
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
              ),
            )
          ],
        ));
  }
}
