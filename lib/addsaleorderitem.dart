import 'dart:convert';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:gpstrackingplan/models/inventorymodel.dart';
import 'package:gpstrackingplan/models/saleorderitemmodel.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/apiHelper .dart';

class AddSaleOrderItem extends StatefulWidget {
  final SaleOrderItemModel saleorderitem;
  final int saleOrderId;
  final List<InventoryModel> listIn;
  final String title;
  AddSaleOrderItem({Key key, this.saleorderitem, this.listIn, this.title,this.saleOrderId})
      : super(key: key);
  @override
  _AddSaleOrderItemState createState() =>
      _AddSaleOrderItemState(this.saleorderitem, this.listIn, this.title,this.saleOrderId);
}

class _AddSaleOrderItemState extends State<AddSaleOrderItem> {
  final SaleOrderItemModel saleorderitem;
  final String title;
  final int saleOrderId;
  List<InventoryModel> _listInventory;
  _AddSaleOrderItemState(this.saleorderitem, this._listInventory, this.title,this.saleOrderId);

  final _formKey = GlobalKey<FormState>();
  final _globalKey = GlobalKey<ScaffoldState>();
  final _orderQty = TextEditingController();
  var _unitPrice = TextEditingController();
  var _extendedPrice = TextEditingController();
  var _inventorySearch = TextEditingController();
  String _inventory = '';
  String _warehouse = 'F001';
  String _priceclass = '';
  int _saleOrderDetailId = 0;
  ApiHelper _apiHelper;

  _loadSetting() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _apiHelper = ApiHelper(prefs);
      _priceclass = _apiHelper.priceClass;
    });
  }

  Future<List<InventoryModel>> fetchInventoryData(String name) async {
    final response = await _apiHelper.fetchData('/api/Inventory/InventoryFeed/' + name);
    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      print('test json = $jsonData');
      _listInventory = [];
      for (var item in jsonData['Results']) {
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
    final response = await _apiHelper.fetchData('/api/Inventory/InventoryPrice/' + id + '/' + price);
    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      if (jsonData['SalesPriceDetails'].toString() != '[]') {
        _unitPrice.text =
            jsonData['SalesPriceDetails'][0]['Price']['value'].toString();
      } else {
        _unitPrice.text = '0.0';
      }

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
    if (saleorderitem != null) {
      _saleOrderDetailId = saleorderitem.orderDetailId;
      _inventory = _listInventory[0].inventoryId;
      _warehouse = saleorderitem.warehouseId;
      _orderQty.text = saleorderitem.orderQty.toString();
      _unitPrice.text = saleorderitem.unitPrice.toString();
      _extendedPrice.text = saleorderitem.extendedPrice.toString();
    }
    else{
      _listInventory =[];
    }
  }

  void calutlate() {
    double.parse(_unitPrice.text);
    double.parse(_orderQty.text);
    double total = double.parse(_unitPrice.text) * double.parse(_orderQty.text);
    setState(() {
      _extendedPrice.text = total.toStringAsFixed(4);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[300],
        appBar: AppBar(
          leading: new IconButton(
            icon: new Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context, saleorderitem);
            },
          ),
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
                                                  fetchInventoryData(
                                                      _inventorySearch.text);
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
                                      _inventory = value;
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
                                    onFieldSubmitted: (valueget) {
                                      calutlate();
                                    },
                                    validator: (val) => val.isEmpty
                                        ? "orderQty is required"
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
                                    onFieldSubmitted: (valueget) {
                                      calutlate();
                                    },
                                    validator: (val) => val.isEmpty
                                        ? "unitPrice is required"
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
                                        ? "extendedPrice is required"
                                        : null,
                                    autocorrect: false,
                                    autofocus: false,
                                    enabled: false,
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
                                    itemModel.saleOrderId = saleOrderId;
                                    itemModel.orderDetailId = _saleOrderDetailId;
                                    itemModel.inventoryId = _inventory;
                                    itemModel.orderQty =
                                        double.parse(_orderQty.text);
                                    itemModel.unitPrice =
                                        double.parse(_unitPrice.text);
                                    itemModel.extendedPrice =
                                        double.parse(_extendedPrice.text);
                                    itemModel.warehouseId = _warehouse;
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
