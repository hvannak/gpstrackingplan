
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:gpstrackingplan/displaysaleorderitem.dart';
import 'package:gpstrackingplan/helpers/controlHelper.dart';
import 'package:gpstrackingplan/models/customermodel.dart';
import 'package:gpstrackingplan/models/saleordermodel.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_localizations.dart';
import 'helpers/apiHelper .dart';
import 'models/saleorderitemmodel.dart';

class AddSaleOrder extends StatefulWidget {
  final SaleOrderModel saleorder;
  final String title;
  final  List<Customermodel> listCustomers;
  AddSaleOrder({
    Key key,
    this.saleorder,this.title,
    this.listCustomers
  }) : super(key: key);
  @override
  _AddSaleOrderState createState() => _AddSaleOrderState(this.saleorder,this.title,this.listCustomers);
}

class _AddSaleOrderState extends State<AddSaleOrder> {
  final SaleOrderModel saleorder;
  final String title;
  final List<Customermodel> listCustomers;
  String customername;
  final _formKey = GlobalKey<FormState>();
  final _globalKey = GlobalKey<ScaffoldState>();
  var _orderNbr = TextEditingController();
  var _customerId = TextEditingController();
  var _description = TextEditingController();
  var _oderQty = TextEditingController();
  var _orderTotal = TextEditingController();
  var _date = TextEditingController();
  _AddSaleOrderState(this.saleorder,this.title,this.listCustomers);
  ApiHelper _apiHelper;
  ControlHelper _controlHelper = ControlHelper();

  _loadSetting() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _apiHelper = ApiHelper(prefs);
    });
  }

  List<SaleOrderItemModel> _listSaleItem = [];
  _navigateDisplaySaleOrderItem(BuildContext context) async {
    if (saleorder != null) {
      List<SaleOrderItemModel> result = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => DisplaySaleOrderItem(listSaleItem: saleorder.details,title: AppLocalizations.of(context).translate('edit_order'),saleOrderId: saleorder.saleOrderId,)));
      setState(() {
        _listSaleItem = result;
        _oderQty.text = getSumQty().toString();
        _orderTotal.text = getTotalPrice().toString();
      });
    } else {
      print('Else');
      List<SaleOrderItemModel> result = await Navigator.push(context,
          MaterialPageRoute(builder: (context) => DisplaySaleOrderItem(listSaleItem: _listSaleItem,title: AppLocalizations.of(context).translate('list_sale_order_item'),saleOrderId: 0,)));
      setState(() {
        _listSaleItem = result;
        _oderQty.text = getSumQty();
        _orderTotal.text = getTotalPrice();
      });
    }
    return _listSaleItem;
  }

  Future<String> fetchPost(saleOrderId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var deleteItems = (prefs.getString('deleteItems') ?? '');
    var response;
    var body = {
      'SaleOrderID': saleOrderId,
      'OrderNbr': _orderNbr.text,
      'CustomerID': _customerId.text,
      'CustomerDescr': customername,
      'OrderDesc': _description.text,
      'OrderQty': _oderQty.text,
      'OrderTotal': _orderTotal.text,
      'OrderDate': _date.text,
      'DeletedSaleOrderDetails':deleteItems,
      'Details': SaleOrderItemModel.encondeToJson(_listSaleItem)
    };
    if (saleOrderId != 0) {
      response = await _apiHelper.fetchPut1('/api/SaleOrder/Update', body);
      prefs.remove('deleteItems');
    } else {
      response = await _apiHelper.fetchPost1('/api/SaleOrder/Create', body);
    }

    print(response.statusCode);
    if (response.statusCode == 200 || response.statusCode == 204 || response.statusCode == 201) {
      Navigator.of(context).pop();
      return response.body;
    } else {
      print(response.statusCode);
      throw Exception('Failed to load post');
    }
  }

  String getSumQty() {
    double sum = 0;
    for (int i = 0; i < _listSaleItem.length; i++)
      sum += _listSaleItem[i].orderQty;
    return sum.toString();
  }

  String getTotalPrice() {
    double total = 0;
    for (int i = 0; i < _listSaleItem.length; i++)
      total += _listSaleItem[i].extendedPrice;
    return total.toStringAsFixed(2);
  }

  @override
  void initState() {
    super.initState();
    _loadSetting();
    _orderNbr.text = 'NEW';
    _customerId.text = listCustomers[0].customerID;
    customername = listCustomers[0].customerName;
    if (saleorder != null) {
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
      key: _globalKey,
      appBar: AppBar(
        title: Text(title),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.list),
            onPressed: () {
              _navigateDisplaySaleOrderItem(context);
            },
          )
        ],
      ),
      body: Stack(
        children: <Widget>[
          SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
              decoration:
                  BoxDecoration(color: Colors.white, shape: BoxShape.rectangle),
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
                              enabled: false,
                              style: TextStyle(fontSize: 14.0),
                              decoration: InputDecoration(
                                hintText: "OrderNbr",
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
                            child: DropdownButtonFormField(
                                  items: listCustomers
                                      .map((f) => DropdownMenuItem(
                                            child: AutoSizeText(
                                              f.customerName,
                                              style: TextStyle(fontSize: 10.0),
                                              maxLines: 5,
                                            ),
                                            value: f.customerID,
                                          ))
                                      .toList(),
                                  onChanged: (String value) async {
                                    int index = listCustomers.indexWhere((x)=>x.customerID == value);
                                    SharedPreferences prefs = await SharedPreferences.getInstance();
                                    setState(() {
                                      _customerId.text = value;
                                      customername = listCustomers[index].customerName;
                                      prefs.setString('priceclass', listCustomers[index].priceclass);
                                    });
                                  },
                                  validator: (val) => val == null
                                      ? "Customer is required"
                                      : null,
                                  hint: Text('Select Item'),
                                  value: _customerId.text,
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
                            controller: _description,
                            autocorrect: false,
                            autofocus: false,
                            style: TextStyle(fontSize: 14.0),
                            decoration: InputDecoration(
                                hintText: AppLocalizations.of(context).translate('description'),
                                border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide: BorderSide(
                                            width: 0,
                                            style: BorderStyle.none,
                                          )),
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
                                hintText: AppLocalizations.of(context).translate('date'),
                                border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide: BorderSide(
                                            width: 0,
                                            style: BorderStyle.none,
                                          )),
                                filled: true,
                                fillColor: Colors.grey[200],
                                contentPadding: EdgeInsets.all(15.0)),
                            onTap: () async {
                              var date =
                                  await _controlHelper.selectDate(context);
                              _date.text = date;
                            },
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
                            enabled: false,
                            style: TextStyle(fontSize: 14.0),
                            decoration: InputDecoration(
                                hintText: AppLocalizations.of(context).translate('orderqty'),
                                border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide: BorderSide(
                                            width: 0,
                                            style: BorderStyle.none,
                                          )),
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
                            enabled: false,
                            style: TextStyle(fontSize: 14.0),
                            decoration: InputDecoration(
                                hintText: AppLocalizations.of(context).translate('ordertotal'),
                                border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide: BorderSide(
                                            width: 0,
                                            style: BorderStyle.none,
                                          )),
                                filled: true,
                                fillColor: Colors.grey[200],
                                contentPadding: EdgeInsets.all(15.0)),
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
                                      AppLocalizations.of(context).translate('submit'),
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
