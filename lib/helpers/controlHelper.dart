import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ControlHelper {

  Future<String> selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2018),
      lastDate: DateTime(2050),
      builder: (BuildContext context, Widget child) {
        return Theme(
          data: ThemeData.dark(),
          child: child,
        );
      },
    );
    return DateFormat('yyyy/MM/dd').format(picked);
  }
}