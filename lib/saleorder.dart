import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gpstrackingplan/addsaleorder.dart';
import 'package:gpstrackingplan/waitingdialog.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_localizations.dart';
import 'helpers/apiHelper .dart';
import 'models/customermodel.dart';
import 'models/saleordermodel.dart';

class SaleOrder extends StatefulWidget {
  _SaleOrderState createState() => _SaleOrderState();
}

class _SaleOrderState extends State<SaleOrder> {
  final _globalKey = GlobalKey<ScaffoldState>();
  String customerId = '';
  List<SaleOrderModel> _list = [];
  ApiHelper _apiHelper;

  Future<List<SaleOrderModel>> fetchSaleOrderData() async {
    final response =
        await _apiHelper.fetchData('/api/SaleOrder/Customer/' + customerId);
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

  Future<List<Customermodel>> fetchCustomerData() async {
    final response = await _apiHelper.fetchData('/api/Customer/SalespersonID/' + _apiHelper.linkedCustomerID);
    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      List<Customermodel> _listCustomers= [];
      for (var item in jsonData['Results']) {
        Customermodel customermodel = Customermodel.fromJson(item);
        _listCustomers.add(customermodel);
      }
      return _listCustomers;
    } else {
      final snackBar = SnackBar(content: Text('Failed to load'));
      _globalKey.currentState.showSnackBar(snackBar);
      throw Exception('Failed to load post');
    }
  }

  Future<Customermodel> fetchGetCustomerById(String id) async {
    final response =
        await _apiHelper.fetchData('/api/Customer/CustomerID/' + id);
    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body) as List;
      List<Customermodel> customerList =
          jsonData.map((i) => Customermodel.fromJson(i)).toList();
      return customerList[0];
    } else {
      final snackBar = SnackBar(content: Text('Failed to load'));
      _globalKey.currentState.showSnackBar(snackBar);
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
        title: Text(AppLocalizations.of(context).translate('saleorder')),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add_circle),
            onPressed: () async {
              WaitingDialogs().showLoadingDialog(context,_globalKey);
              var customer = await fetchCustomerData();
              Navigator.of(context).pop();
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AddSaleOrder(
                            saleorder: null,
                            title: AppLocalizations.of(context).translate('saleorder'),
                            listCustomers: customer,
                          )));
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
                  onDismissed: (direction) {
                    deleteSaleOrder(snapshot.data[index].saleOrderId);
                    snapshot.data.removeAt(index);
                  },
                  confirmDismiss: (direction) async {
                    if (snapshot.data[index].issync == true) {
                      final snackBar = SnackBar(
                          content: Text(
                              AppLocalizations.of(context).translate('can_not_delete')));
                      _globalKey.currentState.showSnackBar(snackBar);
                      return false;
                    } else {
                      final bool result = await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text(AppLocalizations.of(context).translate('confirm')),
                            content: Text(
                                AppLocalizations.of(context).translate('confirm_delete')),
                            actions: <Widget>[
                              FlatButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                  child: Text(AppLocalizations.of(context).translate('delete'))),
                              FlatButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                child: Text(AppLocalizations.of(context).translate('cancel')),
                              ),
                            ],
                          );
                        },
                      );
                      return result;
                    }
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
                      onTap: () async {
                        if (snapshot.data[index].issync == true) {
                          final snackBar = SnackBar(
                          content: Text(
                              AppLocalizations.of(context).translate('can_not_edit')));
                              _globalKey.currentState.showSnackBar(snackBar);
                          
                        } else {
                          WaitingDialogs().showLoadingDialog(context,_globalKey);
                          var customer = await fetchCustomerData();
                          Navigator.of(context).pop();
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AddSaleOrder(
                                        saleorder: snapshot.data[index],
                                        title: AppLocalizations.of(context).translate('edit_order'),
                                        listCustomers: customer,
                                      )));
                        }
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
