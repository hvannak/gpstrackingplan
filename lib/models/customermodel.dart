class Customermodel {
  final String customerID;
  final String customerName;
  final String priceclass;

  Customermodel({this.customerID, this.customerName, this.priceclass});

  factory Customermodel.fromJson(Map<String, dynamic> json) {
    return Customermodel(
      customerID: json['CustomerID']['value'],
      customerName: json['CustomerName']['value'],
      priceclass: json['PriceClassID']['value']
    );
  }
}
