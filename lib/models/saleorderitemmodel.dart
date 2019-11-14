
class SaleOrderItemModel {
  final int orderDetailId;
  final String saleOrderId;
  final String inventoryId;
  final String inventoryDesc;
  final String warehouseId;
  final double orderQty;
  final double unitPrice;
  final double extendedPrice;

  
  SaleOrderItemModel({this.orderDetailId, this.saleOrderId, this.inventoryId, this.inventoryDesc, this.warehouseId, this.orderQty, this.unitPrice, this.extendedPrice});

  factory SaleOrderItemModel.fromJson(Map<String, dynamic> json) {
    return SaleOrderItemModel(
      orderDetailId: json['OrderDetailID'],
      saleOrderId: json['SaleOrderID'],
      inventoryId: json['InventoryID'],
      inventoryDesc: json['InventoryDescr'],
      warehouseId: json['WarehouseID'],
      orderQty: json['OrderQty'],
      unitPrice: json['UnitPrice'],
      extendedPrice: json['ExtendedPrice']
    );
  }
}
