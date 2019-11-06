class Gpsroutemodel {
  final int gpsID;
  final double lat;
  final double lng;
  final DateTime gpsdatetime;
  final String checkType;
  final String customer;
  final String image;
  final String userId;

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
}