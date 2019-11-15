import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gpstrackingplan/addsaleorder.dart';
import 'package:gpstrackingplan/addsaleorderitem.dart';
import 'package:gpstrackingplan/models/saleorderitemmodel.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'models/saleordermodel.dart';

class DisplaySaleOrderItem extends StatefulWidget {
  _DisplaySaleOrderItemState createState() => _DisplaySaleOrderItemState();
}

class _DisplaySaleOrderItemState extends State<DisplaySaleOrderItem> {
  List<SaleOrderItemModel> _listSaleItem = [];
  _navigateTakePictureScreen(BuildContext context) async {
    print('IN funct');
    SaleOrderItemModel result = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => AddSaleOrderItem()));
    setState(() {
      print('result = ${result.orderQty}');
      _listSaleItem.add(result);
      print('test item result = ${_listSaleItem.length}');
    });
    return _listSaleItem;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
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
          itemCount: _listSaleItem.length,
          itemBuilder: (BuildContext context, int index) {
            return Card(
              child: Container(
                decoration: BoxDecoration(color: Colors.lightBlue[50]),
                child: ListTile(
                  title: Text(
                    _listSaleItem[index].inventoryId,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(' Warehouse ' +
                      _listSaleItem[index].warehouseId +
                      ' OrderQty ' +
                      _listSaleItem[index].orderQty.toString() +
                      ' UnitPrice ' +
                      _listSaleItem[index].unitPrice.toString() +
                      ' Total ' +
                      _listSaleItem[index].extendedPrice.toString() 
                      ) 
                      

                ),
              ),
            );
          },
        ));
  }
}
