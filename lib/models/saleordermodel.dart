class SaleOrderModel {
  final int saleOrderId;
  final String orderNumber;
  final DateTime orderDate;
  final String customerId;
  final String customerDesc;
  final String orderDesc;
  final double orderQty;
  final double orderTotal;
  final String delete;
  final bool issync;
  
  SaleOrderModel({this.saleOrderId, this.orderNumber, this.orderDate, this.customerId, this.customerDesc, this.orderDesc, this.orderQty, this.orderTotal, this.delete, this.issync});

  factory SaleOrderModel.fromJson(Map<String, dynamic> json) {
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
      issync: json['IsSyn']
    );
  }
}

