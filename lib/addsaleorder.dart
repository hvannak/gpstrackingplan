import 'package:flutter/material.dart';
import 'package:gpstrackingplan/addsaleorderitem.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddSaleOrder extends StatefulWidget {
  @override
  _AddSaleOrderState createState() => _AddSaleOrderState();
}

class _AddSaleOrderState extends State<AddSaleOrder> {
  final _formKey = GlobalKey<FormState>();
  final _globalKey = GlobalKey<ScaffoldState>();
  String _token = '';
  String _urlSetting = ''; 
  final _orderNbr = TextEditingController();
  final _customerId = TextEditingController();
  final _description = TextEditingController();
  final _oderQty = TextEditingController();
  final _orderTotal = TextEditingController();
  final _date = TextEditingController();

  _loadSetting() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _token = (prefs.getString('token') ?? '');
      _urlSetting = (prefs.getString('url') ?? '');
      _customerId.text = (prefs.getString('linkedCustomerID') ?? '');

      print('test customerID = ${_customerId.text}');
      // print(_token);
    });
  }

  Future<Null> _selectDate(BuildContext context) async {
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
    setState(() {
        _date.text = DateFormat('yyyy-MM-dd').format(picked);
    });
  }

  @override
  void initState() {
    super.initState();
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[300],
        appBar: AppBar(
        title: Text('Add Sale Order'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add_circle),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AddSaleOrderItem()));
            },
          )
        ],
      ),
        body:Stack(
              children: <Widget>[
                SingleChildScrollView(
                  child: Container(
                    // height: 300.0,
                    // width: 450.0,
                    padding:
                        EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(20.0)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Form(
                          key: _formKey,
                          child: Column(
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 10.0),
                                child: TextFormField(
                                  controller: _orderNbr,
                                  validator: (val) => val.isEmpty
                                    ? "Username is required"
                                    : null,
                                    autocorrect: false,
                                    autofocus: false,
                                    style: TextStyle(fontSize: 14.0),
                                  decoration: InputDecoration(
                                    hintText: "OrderNbr",
                                    border: InputBorder.none,
                                    filled: true,
                                    fillColor: Colors.grey[200],
                                    contentPadding: EdgeInsets.all(15.0),
                                  ),
                                )
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 10.0),
                                child:TextFormField(
                                  controller: _customerId,
                                  validator: (val) =>
                                      val.isEmpty ? "Password is required" : null,
                                  autocorrect: false,
                                  autofocus: false,
                                  obscureText: true,
                                  style: TextStyle(fontSize: 14.0),
                                  decoration: InputDecoration(
                                      hintText: "CustomerID",
                                      border: InputBorder.none,
                                      filled: true,
                                      fillColor: Colors.grey[200],
                                      contentPadding: EdgeInsets.all(15.0)),
                                ),
                              ),
                              
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 10.0),
                                child:TextFormField(
                                controller: _description,
                                validator: (val) =>
                                    val.isEmpty ? "Password is required" : null,
                                autocorrect: false,
                                autofocus: false,
                                obscureText: true,
                                style: TextStyle(fontSize: 14.0),
                                decoration: InputDecoration(
                                    hintText: "Description",
                                    border: InputBorder.none,
                                    filled: true,
                                    fillColor: Colors.grey[200],
                                    contentPadding: EdgeInsets.all(15.0)),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 10.0),
                                child:TextFormField(
                                controller: _oderQty,
                                validator: (val) =>
                                    val.isEmpty ? "Password is required" : null,
                                autocorrect: false,
                                autofocus: false,
                                obscureText: true,
                                style: TextStyle(fontSize: 14.0),
                                decoration: InputDecoration(
                                    hintText: "OrderQty",
                                    border: InputBorder.none,
                                    filled: true,
                                    fillColor: Colors.grey[200],
                                    contentPadding: EdgeInsets.all(15.0)),
                                ),
                              ),

                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 10.0),
                                child:TextFormField(
                                controller: _orderTotal,
                                validator: (val) =>
                                    val.isEmpty ? "Password is required" : null,
                                autocorrect: false,
                                autofocus: false,
                                obscureText: true,
                                style: TextStyle(fontSize: 14.0),
                                decoration: InputDecoration(
                                    hintText: "OrderTotal",
                                    border: InputBorder.none,
                                    filled: true,
                                    fillColor: Colors.grey[200],
                                    contentPadding: EdgeInsets.all(15.0)),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 10.0),
                                child:TextFormField(
                                    controller: _date,
                                    validator: (val) => val.isEmpty
                                        ? "From date is required"
                                        : null,
                                    autocorrect: false,
                                    autofocus: false,
                                    style: TextStyle(fontSize: 14.0),
                                    decoration: InputDecoration(
                                      hintText: "Date",
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide: BorderSide(
                                            width: 0,
                                            style: BorderStyle.none,
                                          )),
                                      filled: true,
                                      fillColor: Colors.grey[200],
                                      contentPadding: EdgeInsets.all(15.0),
                                    ),
                                    onTap: () {
                                      _selectDate(context);
                                    },
                                  ),
                              ),    
                              Padding(
                                  padding: EdgeInsets.only(top: 20.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Center(
                                        child: RaisedButton(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 15.0),
                                          onPressed: () {
                                            if (_formKey.currentState
                                                .validate()) {
                                              // fetchPost();
                                              // showSnackbar(context);
                                            }
                                          },
                                          child: Text(
                                            'Submit',
                                            style: TextStyle(fontSize: 14.0),
                                          ),
                                        ),
                                      )
                                    ],
                                  ))
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
    ); 
  }
}