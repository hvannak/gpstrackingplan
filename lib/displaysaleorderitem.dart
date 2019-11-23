import 'package:flutter/material.dart';
import 'package:gpstrackingplan/addsaleorderitem.dart';
import 'package:gpstrackingplan/models/saleorderitemmodel.dart';


class DisplaySaleOrderItem extends StatefulWidget {
  final List<SaleOrderItemModel> listSaleItem;
  DisplaySaleOrderItem(this.listSaleItem);
  _DisplaySaleOrderItemState createState() => _DisplaySaleOrderItemState(this.listSaleItem);
}

class _DisplaySaleOrderItemState extends State<DisplaySaleOrderItem> {
  List<SaleOrderItemModel> listSaleItem = [];
  _DisplaySaleOrderItemState(this.listSaleItem);
  _navigateTakePictureScreen(BuildContext context) async {
    print('IN funct');
    SaleOrderItemModel result = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => AddSaleOrderItem()));
    setState(() {
      print('result = ${result.orderQty}');
      listSaleItem.add(result);
      print('test item result page display = ${listSaleItem.length}');
    });
    return listSaleItem;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: new IconButton(
            icon: new Icon(Icons.arrow_back),
            onPressed: (){ 
              print('test listSaleItem,${ listSaleItem[0].warehouseId}');
              Navigator.pop(context,  listSaleItem);
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
            return Card(
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
            );
          },
        ));
  }
}
