import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gpstrackingplan/models/takeleavemodel.dart';
import 'package:intl/intl.dart';
import '../takeleave.dart';
import 'apiHelper .dart';

class DataSearchLeave extends SearchDelegate<String> {
  final List<Leave> _leaveList;
  ApiHelper _apiHelper;

  DataSearchLeave(this._leaveList,this._apiHelper);

  Future<Leave> deletLeaveData(int leaveId) async {
    final response = await _apiHelper.deleteData('/api/TakeLeaves/',leaveId);
    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      Leave leave = Leave.fromJson(jsonData);
      return leave;
    } else {
      print(response.statusCode);
      throw Exception('Failed to load post');
    }
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    print('buildAction');
    return [
      IconButton(
        icon: Icon(Icons.search),
        onPressed: () {
          // query = to database;
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Text(query);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestionList = query.isEmpty
        ? _leaveList
        : _leaveList
            .where((p) =>
                p.employeeName.contains(query) ||
                p.workPlace.contains(query) ||
                p.reasion.contains(query))
            .toList();
    return ListView.builder(
      itemCount: suggestionList.length,
      itemBuilder: (BuildContext context, int index) {
        return new Dismissible(
          key: new Key(suggestionList[index].leaveID.toString()),
          onDismissed: (direction) {
            deletLeaveData(suggestionList[index].leaveID);
            suggestionList.removeAt(index);
          },
          child: Container(
            child: ListTile(
              leading: Icon(Icons.person),
              title: Text(suggestionList[index].employeeName),
              subtitle: Text(suggestionList[index].workPlace +
                  '-(' +
                  DateFormat("yyy/MM/dd")
                      .format(suggestionList[index].fromDate) +
                  '-' +
                  DateFormat("yyy/MM/dd").format(suggestionList[index].toDate) +
                  ")"),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MyTakeLeaveAddEdit(
                              leave: suggestionList[index],
                              title: 'Edit Leave',
                            )));
              },
            ),
          ),
        );
      },
    );
  }
}
