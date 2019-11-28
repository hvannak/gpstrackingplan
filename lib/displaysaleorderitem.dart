import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gpstrackingplan/addsaleorderitem.dart';
import 'package:gpstrackingplan/models/saleorderitemmodel.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/apiHelper .dart';
import 'models/inventorymodel.dart';

class DisplaySaleOrderItem extends StatefulWidget {
  final List<SaleOrderItemModel> listSaleItem;
  final String title;
  DisplaySaleOrderItem({Key key, this.listSaleItem, this.title})
      : super(key: key);
  _DisplaySaleOrderItemState createState() =>
      _DisplaySaleOrderItemState(this.listSaleItem, this.title);
}

class _DisplaySaleOrderItemState extends State<DisplaySaleOrderItem> {
  final List<SaleOrderItemModel> listSaleItem;
  final String title;
  _DisplaySaleOrderItemState(this.listSaleItem, this.title);
  final _globalKey = GlobalKey<ScaffoldState>();
  List<InventoryModel> _listInventory = [];
  ApiHelper _apiHelper;

  _loadSetting() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _apiHelper = ApiHelper(prefs);
    });
  }

  _navigateAddSaleOrderItem(BuildContext context) async {
    SaleOrderItemModel result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => AddSaleOrderItem(
                  saleorderitem: null,
                  title: "Add Items",
                )));
    if(result != null){
      setState(() {
        listSaleItem.add(result);
      });
    }
    return listSaleItem;
  }

  _navigateEditSaleOrderItem(BuildContext context,SaleOrderItemModel itemModel,List<InventoryModel> listInventory) async {
    SaleOrderItemModel result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => AddSaleOrderItem(
                  saleorderitem: itemModel,
                  listIn:listInventory,
                  title: "Edit Items",
                )));
    print('Edit list item');
    print(result.orderQty);
    var index = listSaleItem.indexWhere((f)=>f.orderDetailId == result.orderDetailId);
    print(index);
    setState(() {
      listSaleItem[index] = result;
    });
    return listSaleItem;
  }

  Future<List<InventoryModel>> fetchInventoryById(String id) async {
    final response = await _apiHelper.fetchData('/api/Inventory/InventoryID/' + id);
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
        key: _globalKey,
        appBar: AppBar(
          leading: new IconButton(
            icon: new Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context, listSaleItem);
            },
          ),
          title: Text(title),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.add_circle),
              onPressed: () {
                _navigateAddSaleOrderItem(context);
              },
            )
          ],
        ),
        body: ListView.builder(
          itemCount: (listSaleItem == null ? 0 : listSaleItem.length),
          itemBuilder: (BuildContext context, int index) {
            return new Dismissible(
              key: new Key(listSaleItem[index].saleOrderId.toString()),
              onDismissed: (direction) {
                // deleteSaleOrder(listSaleItem[index].saleOrderId);
                listSaleItem.removeAt(index);
              },
              child: Card(
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
                      listSaleItem[index].extendedPrice.toString()),
                  onTap: () async {
                    var inventoryList = await fetchInventoryById(listSaleItem[index].inventoryId);
                    _navigateEditSaleOrderItem(context,listSaleItem[index],inventoryList);
                  },
                ),
              ),
              confirmDismiss: (direction) async {
                final bool result = await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text("Confirm"),
                      content: const Text(
                          "Are you sure you want to delete this item?"),
                      actions: <Widget>[
                        FlatButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text("DELETE")),
                        FlatButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text("CANCEL"),
                        ),
                      ],
                    );
                  },
                );
                return result;
              },
            );
          },
        ));
  }
}
