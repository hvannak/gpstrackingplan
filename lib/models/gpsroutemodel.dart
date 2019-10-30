class Gpsroutemodel {
  final String gpsID;
  final String lat;
  final String lng;
  final DateTime gpsdatetime;
  final String checkType;
  final String customer;
  final String image;
  final String userId;

  Gpsroutemodel({this.gpsID, this.lat, this.lng,this.gpsdatetime,this.checkType,this.customer,this.image,this.userId});

  factory Gpsroutemodel.fromJson(Map<String, dynamic> json) {
    return Gpsroutemodel(
      gpsID: json['GpsID'],
      lat: json['Lat'],
      lng: json['Lng'],
      gpsdatetime: json['Gpsdatetime'],
      checkType:json['CheckType'],
      customer:json['Customer'],
      image:json['Image'],
      userId:json['UserId']
    );
  }
}