class Customermodel {
  String customerID;
  String customerName;
  String priceclass;

  Customermodel({this.customerID, this.customerName, this.priceclass});

  factory Customermodel.fromJson(Map<String, dynamic> json) {
    return Customermodel(
      customerID: json['CustomerID']['value'],
      customerName: json['CustomerName']['value'],
      priceclass: json['PriceClassID']['value']
    );
  }

  Map<String,dynamic> toJson(){
      return {
        "CustomerID": this.customerID,
        "CustomerName": this.customerName,
        "PriceClassID": this.priceclass
      };
    }

    static List encondeToJson(List<Customermodel>list){
      List jsonList = List();
      list.map((item)=>
        jsonList.add(item.toJson())
      ).toList();
      return jsonList;
  }


  Customermodel.fromMap(dynamic obj) {
    this.customerID = obj['CustomerID'];
    this.customerName = obj['CustomerName'];
    this.priceclass = obj['PriceClassID'];
  }
  
  Map<String, dynamic> toMap()  {
    var map = new Map<String, dynamic>();
    map["CustomerID"] = customerID;
    map["CustomerName"] = customerName;
    map["PriceClassID"] = priceclass;
    return map;
  }
}
