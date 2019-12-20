class Gpsroutemodel {
   int gpsID;
   double lat;
   double lng;
   DateTime gpsdatetime;
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
      gpsdatetime:DateTime.parse(json['Gpsdatetime']),
      checkType:json['CheckType'],
      customer:json['Customer'],
      image:json['Image'],
      userId:json['UserId']
    );
  }

  Gpsroutemodel.fromMap(dynamic obj) {
    this.lat = obj['Lat'];
    this.lng = obj['Lng'];
    this.gpsdatetime = DateTime.parse(obj['Gpsdatetime']);
    this.checkType = obj['CheckType'];
    this.customer = obj['Customer'];
    this.image = obj['Image'];
    
  }
  
  Map<String, dynamic> toMap()  {
    var map = new Map<String, dynamic>();
    map["Lat"] = lat;
    map["Lng"] = lng;
    map["Gpsdatetime"] = gpsdatetime.toString();
    map["CheckType"] = checkType;
    map["Customer"] = customer;
    map["Image"] = image;
    return map;
  }
}