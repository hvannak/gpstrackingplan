class Paymentmodel {
  final String docType;
  final String customer;
  final DateTime date;
  final String phone1;
  final String referenceNbr;
  final double paymentAmount;
  Paymentmodel({this.docType, this.customer, this.date, this.phone1, this.referenceNbr, this.paymentAmount});

  factory Paymentmodel.fromJson(Map<String, dynamic> json) {
    return Paymentmodel(
      docType: json['DocType']['value'],
      customer: json['Customer']['value'],
      date: DateTime.parse(json['Date']['value']),
      phone1: json['Phone1']['value'],
      referenceNbr: json['ReferenceNbr']['value'],
      paymentAmount: json['PaymentAmount']['value']
    );
  }
}

