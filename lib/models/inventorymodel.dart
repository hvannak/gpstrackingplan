class InventoryModel {
  final String inventoryId;
  final String inventoryDesc;
  InventoryModel({this.inventoryId, this.inventoryDesc});
  factory InventoryModel.fromJson(Map<String, dynamic> json) {
    return InventoryModel(
      inventoryId: json['InventoryID']['value'],
      inventoryDesc: json['Description']['value'],
    );
  }
}
