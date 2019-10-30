class Customermodel {
  final String customerID;
  final String customerName;

  Customermodel({this.customerID, this.customerName});

  factory Customermodel.fromJson(Map<String, dynamic> json) {
    return Customermodel(
      customerID: json['CustomerID']['value'],
      customerName: json['CustomerName']['value']
    );
  }
}