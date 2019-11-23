import 'package:gpstrackingplan/models/saleorderitemmodel.dart';

class SaleOrderModel {
  int saleOrderId;
  String orderNumber;
  DateTime orderDate;
  String customerId;
  String customerDesc;
  String orderDesc;
  double orderQty;
  double orderTotal;
  String delete;
  bool issync;
  List<SaleOrderItemModel> details;

  SaleOrderModel(
      {this.saleOrderId,
      this.orderNumber,
      this.orderDate,
      this.customerId,
      this.customerDesc,
      this.orderDesc,
      this.orderQty,
      this.orderTotal,
      this.delete,
      this.issync,
      this.details});

  factory SaleOrderModel.fromJson(Map<String, dynamic> json) {
    var list = json['Details'] as List;
    List<SaleOrderItemModel> itemList = list.map((i) => SaleOrderItemModel.fromJson(i)).toList();
    return SaleOrderModel(
        saleOrderId: json['SaleOrderID'],
        orderNumber: json['OrderNbr'],
        orderDate: DateTime.parse(json['OrderDate']),
        customerId: json['CustomerID'],
        customerDesc: json['CustomerDescr'],
        orderDesc: json['OrderDesc'],
        orderQty: json['OrderQty'],
        orderTotal: json['OrderTotal'],
        delete: json['DeletedSaleOrderDetails'],
        issync: json['IsSyn'],
        details: itemList);
  }
}
