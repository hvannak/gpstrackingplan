import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gpstrackingplan/addsaleorderitem.dart';
import 'package:gpstrackingplan/models/saleorderitemmodel.dart';
import 'package:gpstrackingplan/waitingdialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_localizations.dart';
import 'helpers/apiHelper .dart';
import 'models/inventorymodel.dart';

class DisplaySaleOrderItem extends StatefulWidget {
  final List<SaleOrderItemModel> listSaleItem;
  final String title;
  final int saleOrderId;
  DisplaySaleOrderItem({Key key, this.listSaleItem, this.title,this.saleOrderId})
      : super(key: key);
  _DisplaySaleOrderItemState createState() =>
      _DisplaySaleOrderItemState(this.listSaleItem, this.title,this.saleOrderId);
}

class _DisplaySaleOrderItemState extends State<DisplaySaleOrderItem> {
  List<SaleOrderItemModel> listSaleItem;
  final String title;
  final int saleOrderId;
  _DisplaySaleOrderItemState(this.listSaleItem, this.title,this.saleOrderId);
  final _globalKey = GlobalKey<ScaffoldState>();
  List<InventoryModel> _listInventory = [];
  String _deleteSaleorderItems='';
  ApiHelper _apiHelper;

  _loadSetting() async {
    print('list item');
    print(listSaleItem.length);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _apiHelper = ApiHelper(prefs);
      _deleteSaleorderItems = _apiHelper.deleteSaleorderItems;
    });
  }

  _navigateAddSaleOrderItem(BuildContext context) async {
    SaleOrderItemModel result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => AddSaleOrderItem(
                  saleorderitem: null,
                  listIn: null,
                  saleOrderId: saleOrderId,
                  title: "Add Items",
                )));

    if(result != null){
      setState(() {
        if(listSaleItem == null)
          listSaleItem = [];
        listSaleItem.add(result);
      });
    }
    return listSaleItem;
  }

  _navigateEditSaleOrderItem(BuildContext context,SaleOrderItemModel itemModel,List<InventoryModel> listInventory,int index) async {
    SaleOrderItemModel result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => AddSaleOrderItem(
                  saleorderitem: itemModel,
                  listIn:listInventory,
                  saleOrderId: itemModel.saleOrderId,
                  title: "Edit Items",
                )));
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
              onDismissed: (direction) async{
                if(listSaleItem[index].orderDetailId != 0){
                  _deleteSaleorderItems += listSaleItem[index].orderDetailId.toString() + ',';
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  prefs.setString('deleteItems', _deleteSaleorderItems);
                  // print(_deleteSaleorderItems);
                }
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
                    WaitingDialogs().showLoadingDialog(context,_globalKey);
                    var inventoryList = await fetchInventoryById(listSaleItem[index].inventoryId);
                    Navigator.of(context).pop();
                    _navigateEditSaleOrderItem(context,listSaleItem[index],inventoryList,index);
                  },
                ),
              ),
              confirmDismiss: (direction) async {
                final bool result = await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title:  Text(AppLocalizations.of(context).translate('confirm')),
                      content:  Text(
                          AppLocalizations.of(context).translate('confirm_delete')),
                      actions: <Widget>[
                        FlatButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: Text(AppLocalizations.of(context).translate('delete'))),
                        FlatButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: Text(AppLocalizations.of(context).translate('cancel')),
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
