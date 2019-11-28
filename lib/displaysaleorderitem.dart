import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:gpstrackingplan/addsaleorderitem.dart';
import 'package:gpstrackingplan/models/saleorderitemmodel.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/inventorymodel.dart';

class DisplaySaleOrderItem extends StatefulWidget {
  final List<SaleOrderItemModel> listSaleItem;
  DisplaySaleOrderItem(this.listSaleItem);
  _DisplaySaleOrderItemState createState() =>
      _DisplaySaleOrderItemState(this.listSaleItem);
}

class _DisplaySaleOrderItemState extends State<DisplaySaleOrderItem> {
  List<SaleOrderItemModel> listSaleItem = [];
  _DisplaySaleOrderItemState(this.listSaleItem);
  final _formKey = GlobalKey<FormState>();
  final _globalKey = GlobalKey<ScaffoldState>();
  String _token = '';
  String _urlSetting = '';
  List<InventoryModel> _listInventory = [];

  _loadSetting() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _token = (prefs.getString('token') ?? '');
      _urlSetting = (prefs.getString('url') ?? '');
    });
  }

  _navigateTakePictureScreen(BuildContext context) async {
    SaleOrderItemModel result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => AddSaleOrderItem(
                  saleorderitem: null,
                )));
    setState(() {
      listSaleItem.add(result);
    });
    return listSaleItem;
  }

  Future<List<InventoryModel>> fetchInventoryById(String id) async {
    final response = await http
        .get(_urlSetting + '/api/Inventory/InventoryID/' + id, headers: {
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
      return _listInventory;
    } else {
      final snackBar = SnackBar(content: Text('Failed to load'));
      _globalKey.currentState.showSnackBar(snackBar);
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
        appBar: AppBar(
          leading: new IconButton(
            icon: new Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context, listSaleItem);
            },
          ),
          title: Text('List Sale Order'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.add_circle),
              onPressed: () {
                _navigateTakePictureScreen(context);
              },
            )
          ],
        ),
        body: ListView.builder(
          itemCount: listSaleItem.length,
          itemBuilder: (BuildContext context, int index) {
            return Slidable(
              actionPane: SlidableDrawerActionPane(),
              actionExtentRatio: 0.25,
              // return Card(
              child: Container(
                decoration: BoxDecoration(color: Colors.lightBlue[50]),
                child: ListTile(
                    title: Text(
                      listSaleItem[index].inventoryId,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(' Warehouse ' +
                        listSaleItem[index].warehouseId +
                        ' OrderQty ' +
                        listSaleItem[index].orderQty.toString() +
                        ' UnitPrice ' +
                        listSaleItem[index].unitPrice.toString() +
                        ' Total ' +
                        listSaleItem[index].extendedPrice.toString())),
              ),
              secondaryActions: <Widget>[
                IconSlideAction(
                    caption: 'Edit',
                    color: Colors.blue[300],
                    icon: Icons.edit,
                    onTap: () {
                      fetchInventoryById(listSaleItem[index].inventoryId)
                          .then((result) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AddSaleOrderItem(
                                      saleorderitem: listSaleItem[index],
                                      listIn: result,
                                    )));
                      });
                    }),
                IconSlideAction(
                  caption: 'Delete',
                  color: Colors.red,
                  icon: Icons.delete,
                  onTap: () {
                    // deleteSaleOrder(snapshot.data[index].saleOrderId);
                    // setState(() {
                    //  snapshot.data.removeAt(index);
                    //  fetchSaleOrderData();
                    // });
                  },
                ),
              ],
            );
          },
        ));
  }
}
