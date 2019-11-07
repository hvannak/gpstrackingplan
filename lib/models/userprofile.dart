class Userprofile {
  final String iD;
  final String fullName;
  final String email;
  final String userName;
  final String linkedCustomerID;

  Userprofile({this.iD,this.fullName, this.email, this.userName,this.linkedCustomerID});

  factory Userprofile.fromJson(Map<String, dynamic> json) {
    return Userprofile(
      iD: json['Id'],
      fullName: json['FullName'],
      email: json['Email'],
      userName: json['UserName'],
      linkedCustomerID: json['LinkedCustomerID']
    );
  }
}