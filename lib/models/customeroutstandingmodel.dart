class OutstandingModel {
  final String typeDocType;
  final String customer;
  final DateTime date;
  final String referenceNbr;
  final double balance;
  final String currency;
  OutstandingModel({this.typeDocType, this.customer, this.date, this.referenceNbr, this.balance, this.currency});

  factory OutstandingModel.fromJson(Map<String, dynamic> json) {
    return OutstandingModel(
      typeDocType: json['TypeDocType']['value'],
      customer: json['Customer']['value'],
      date: DateTime.parse(json['Date']['value']),
      referenceNbr: json['ReferenceNbr']['value'],
      balance: json['Balance']['value'],
      currency: json['Currency']['value']
    );
  }
}
