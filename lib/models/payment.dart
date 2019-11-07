class Paymentmodel {
  final String docType;
  final String customer;
  final DateTime date;
  final String referenceNbr;
  final double paymentAmount;
  Paymentmodel({this.docType, this.customer, this.date, this.referenceNbr, this.paymentAmount});

  factory Paymentmodel.fromJson(Map<String, dynamic> json) {
    return Paymentmodel(
      docType: json['DocType']['value'],
      customer: json['Customer']['value'],
      date: DateTime.parse(json['Date']['value']),
      referenceNbr: json['ReferenceNbr']['value'],
      paymentAmount: json['PaymentAmount']['value']
    );
  }
}

