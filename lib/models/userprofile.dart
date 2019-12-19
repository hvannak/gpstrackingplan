class Userprofile {
   int  iD;
   String fullName;
   String email;
   String userName;
   String password;
   String linkedCustomerID;
   String telephone;

  Userprofile({this.iD,this.fullName, this.email, this.userName,this.password,this.linkedCustomerID, this.telephone});

  factory Userprofile.fromJson(Map<String, dynamic> json) {
    return Userprofile(
      iD: json['Id'],
      fullName: json['FullName'],
      email: json['Email'],
      userName: json['UserName'],
      password: json['Password'],
      linkedCustomerID: json['LinkedCustomerID'],
      telephone: json['Telephone']
    );
  }

  Userprofile.fromMap(dynamic obj) {
    this.fullName = obj['FullName'];
    this.email = obj['Email'];
    this.userName = obj['UserName'];
    this.password = obj['Password'];
    this.linkedCustomerID = obj['LinkedCustomerID'];
    this.telephone = obj['Telephone'];
  }
  
  Map<String, dynamic> toMap()  {
    var map = new Map<String, dynamic>();
    map["FullName"] = fullName;
    map["Email"] = email;
    map["UserName"] = userName;
    map["Password"] = password;
    map["LinkedCustomerID"] = linkedCustomerID;
    map["Telephone"] = telephone;
    return map;
  }

}