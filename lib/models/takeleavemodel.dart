class Leave {
  final int leaveID;
  final String employeeName;
  final String workPlace;
  final DateTime fromDate;
  final DateTime toDate;
  final String reasion;

  Leave({this.leaveID, this.employeeName, this.workPlace, this.fromDate,this.toDate,this.reasion});

  factory Leave.fromJson(Map<String, dynamic> json) {
    return Leave(
      leaveID: json['LeaveID'],
      employeeName: json['EmployeeName'],
      workPlace: json['WorkPlace'],
      fromDate: DateTime.parse(json['FromDate']),
      toDate: DateTime.parse(json['ToDate']),
      reasion: json['Reasion']
    );
  }
}