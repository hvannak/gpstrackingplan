class Gpsroutemodel {
   int gpsID;
   double lat;
   double lng;
   String gpsdatetime;
   String checkType;
   String customer;
   String image;
   String userId;

  Gpsroutemodel({this.gpsID, this.lat, this.lng,this.gpsdatetime,this.checkType,this.customer,this.image,this.userId});

  factory Gpsroutemodel.fromJson(Map<String, dynamic> json) {
    return Gpsroutemodel(
      gpsID: json['GpsID'],
      lat: double.parse(json['Lat']),
      lng: double.parse(json['Lng']),
      // gpsdatetime:DateTime.parse(json['Gpsdatetime']),
      gpsdatetime:json['Gpsdatetime'],
      checkType:json['CheckType'],
      customer:json['Customer'],
      image:json['Image'],
      userId:json['UserId']
    );
  }


  Map<String,dynamic> toJson(){
      return {
        "GpsID": this.gpsID,
        "Lat": this.lat,
        "Lng": this.lng,
        "Gpsdatetime": this.gpsdatetime,
        "CheckType": this.checkType,
        "Customer": this.customer,
        "Image": this.image,
        "UserId": this.userId,
      };
    }

    static List encondeToJson(List<Gpsroutemodel>list){
      List jsonList = List();
      list.map((item)=>
        jsonList.add(item.toJson())
      ).toList();
      return jsonList;
  }


  Gpsroutemodel.fromMap(dynamic obj) {
    this.lat = obj['Lat'];
    this.lng = obj['Lng'];
    this.gpsdatetime = obj['Gpsdatetime'];
    this.checkType = obj['CheckType'];
    this.customer = obj['Customer'];
    this.image = obj['Image']; 
    this.userId = obj['UserId']; 
  }
  
  Map<String, dynamic> toMap()  {
    var map = new Map<String, dynamic>();
    map["Lat"] = lat;
    map["Lng"] = lng;
    map["Gpsdatetime"] = gpsdatetime;
    map["CheckType"] = checkType;
    map["Customer"] = customer;
    map["Image"] = image;
    map["UserId"] = userId;
    return map;
  }
}