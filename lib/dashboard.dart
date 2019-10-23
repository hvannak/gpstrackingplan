import 'package:flutter/material.dart';

class Dashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard')
      ),
      body: Center(
        child: RaisedButton(
          child: Text('Route Visit'),
          onPressed: () {
            
          },
        ),
      ),
    );
  }
}