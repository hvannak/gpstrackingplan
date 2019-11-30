import 'dart:convert';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gpstrackingplan/cameraphoto.dart';
import 'package:gpstrackingplan/models/customermodel.dart';
import 'package:gpstrackingplan/routemapping.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'helpers/apiHelper .dart';


class Routevisiting extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Route Visiting'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.view_list),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => RouteMapping()));
            },
          )
        ],
      ),
      body: MyRouteVisiting(),
    );
  }
}

//    //yyyy-MM-dd,HH:mm:ss

class MyRouteVisiting extends StatefulWidget {
  final String imagePath;
  const MyRouteVisiting({Key key, this.imagePath}) : super(key: key);

  @override
  _MyRouteVisitingState createState() => _MyRouteVisitingState();
}

class _MyRouteVisitingState extends State<MyRouteVisiting> {
  final _formKey = GlobalKey<FormState>();
  final _globalKey = GlobalKey<ScaffoldState>();
  var _firstCamera;

  String _checkType = 'IN';
  String _customer = 'NEW';
  String _imagePath = '';
  double _lat;
  double _lng;
  String _imagebase64;
  var _customerSearch = TextEditingController();
  List<Customermodel> _listCustomer = [];
  ApiHelper _apiHelper;

  _loadSetting() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _apiHelper = ApiHelper(prefs);
    });
  }

  _getCurrentLocation() {
    final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
    geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
      setState(() {
        _lat = position.latitude;
        _lng = position.longitude;
      });
    }).catchError((e) {
      print(e);
    });
  }

  Future<String> fetchPost() async {
    var body = {
      'GpsID': '0',
      'Lat': _lat,
      'Lng': _lng,
      'Gpsdatetime':
          DateFormat('yyyy-MM-dd,HH:mm:ss').format(new DateTime.now()),
      'CheckType': _checkType,
      'Customer': _customer,
      'Image': _imagebase64,
    };
    final response = await _apiHelper.fetchPost1('/api/Gpstrackings', body);
    print(response.statusCode);
    if (response.statusCode == 200) {
      return response.body;
    } else {
      print(response.statusCode);
      throw Exception('Failed to load post');
    }
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    _firstCamera = cameras.first;
  }

  Future<List<Customermodel>> fetchCustomerData(String name) async {
    final response = await _apiHelper.fetchData('/api/Customer/CustomerName/' + name);
    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      _listCustomer = [];
      for (var item in jsonData) {
        Customermodel customermodel = Customermodel.fromJson(item);
        _listCustomer.add(customermodel);
      }
      setState(() {
        _customer = _listCustomer[0].customerName;
        _listCustomer.sort((a, b) => b.customerName.compareTo(a.customerName));
        print(_listCustomer.length);
      });
      return _listCustomer;
    } else {
      final snackBar = SnackBar(content: Text('Failed to load'));
      _globalKey.currentState.showSnackBar(snackBar);
      print(response.statusCode);
      throw Exception('Failed to load post');
    }
  }

  _navigateTakePictureScreen(BuildContext context) async {
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => TakePictureScreen(camera: _firstCamera)));
    setState(() {
      _imagePath = result;
      File imagefile = new File(_imagePath);
      List<int> imageBytes = imagefile.readAsBytesSync();
      _imagebase64 = "data:image/png;base64," + base64Encode(imageBytes);
    });

    Scaffold.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text("Image is captured")));
  }

  @override
  void initState() {
    super.initState();
    _loadSetting();
    _initCamera();
    _getCurrentLocation();
    _listCustomer
        .add(new Customermodel(customerID: 'NEW', customerName: 'NEW'));
    _listCustomer
        .add(new Customermodel(customerID: 'OLD', customerName: 'OLD'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[300],
        key: _globalKey,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _navigateTakePictureScreen(context);
          },
          child: Icon(Icons.camera_alt),
          backgroundColor: Colors.green,
        ),
        body: Stack(
          children: <Widget>[
            SingleChildScrollView(
              child: Container(
                child: Column(
                  children: <Widget>[
                    Padding(
                        padding: EdgeInsets.all(5.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 10.0),
                                child: DropdownButtonFormField(
                                  items: [
                                    DropdownMenuItem<String>(
                                      child: Text('Check In'),
                                      value: 'IN',
                                    ),
                                    DropdownMenuItem<String>(
                                      child: Text('Check Out'),
                                      value: 'OUT',
                                    ),
                                    DropdownMenuItem<String>(
                                      child: Text('Depo/Farm'),
                                      value: 'CUS',
                                    ),
                                    DropdownMenuItem<String>(
                                      child: Text('Sub Depo'),
                                      value: 'SUB',
                                    ),
                                  ],
                                  onChanged: (String value) {
                                    setState(() {
                                      _checkType = value;
                                    });
                                  },
                                  validator: (val) => val == null
                                      ? "Check type is required"
                                      : null,
                                  hint: Text('Select Item'),
                                  value: _checkType,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                          style: BorderStyle.solid,
                                        )),
                                    filled: true,
                                    fillColor: Colors.grey[200],
                                    contentPadding: EdgeInsets.all(15.0),
                                  ),
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Expanded(
                                    child: Padding(
                                        padding:
                                            EdgeInsets.symmetric(vertical: 1.0),
                                        child: TextFormField(
                                          controller: _customerSearch,
                                          textInputAction:
                                              TextInputAction.search,
                                          onFieldSubmitted: (valueget) {
                                            fetchCustomerData(valueget);
                                          },
                                          autocorrect: false,
                                          autofocus: false,
                                          style: TextStyle(fontSize: 14.0),
                                          decoration: InputDecoration(
                                            hintText: "Search Customer",
                                            border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                borderSide: BorderSide(
                                                  width: 0,
                                                  style: BorderStyle.none,
                                                )),
                                            filled: true,
                                            fillColor: Colors.grey[200],
                                            contentPadding:
                                                EdgeInsets.all(15.0),
                                          ),
                                        )),
                                  ),
                                  Expanded(
                                    child: Padding(
                                        padding: EdgeInsets.only(top: 5.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            Center(
                                              child: RaisedButton(
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 15.0),
                                                shape:
                                                    new RoundedRectangleBorder(
                                                  borderRadius:
                                                      new BorderRadius.circular(
                                                          8.0),
                                                ),
                                                onPressed: () {
                                                  fetchCustomerData(
                                                      _customerSearch.text);
                                                },
                                                child: Text(
                                                  'Search',
                                                  style:
                                                      TextStyle(fontSize: 14.0),
                                                ),
                                              ),
                                            )
                                          ],
                                        )),
                                  )
                                ],
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 10.0),
                                child: DropdownButtonFormField(
                                  items: _listCustomer
                                      .map((f) => DropdownMenuItem(
                                            child: AutoSizeText(
                                              f.customerName,
                                              style: TextStyle(fontSize: 10.0),
                                              maxLines: 5,
                                            ),
                                            value: f.customerName,
                                          ))
                                      .toList(),
                                  onChanged: (String value) {
                                    setState(() {
                                      _customer = value;
                                    });
                                  },
                                  validator: (val) => val == null
                                      ? "Customer is required"
                                      : null,
                                  hint: Text('Select Item'),
                                  value: _customer,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                          style: BorderStyle.solid,
                                        )),
                                    filled: true,
                                    fillColor: Colors.grey[200],
                                    contentPadding: EdgeInsets.all(15.0),
                                  ),
                                ),
                              ),
                              Padding(
                                  padding: EdgeInsets.only(top: 5.0),
                                  child: Container(
                                    child: _imagePath == ''
                                        ? Image.asset(
                                            'assets/images/user.png',
                                            color: Colors.blue,
                                            height: 180.0,
                                            width: 180.0,
                                          )
                                        : Image.file(File(_imagePath)),
                                    width: 200.0,
                                    height: 200.0,
                                  )),
                              Padding(
                                  padding: EdgeInsets.only(top: 5.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Center(
                                        child: RaisedButton(
                                          color: Colors.lightBlue,
                                          padding: EdgeInsets.symmetric(
                                              vertical: 15.0),
                                          shape: new RoundedRectangleBorder(
                                            borderRadius:
                                                new BorderRadius.circular(8.0),
                                          ),
                                          onPressed: () {
                                            if (_formKey.currentState
                                                    .validate() &&
                                                _imagePath != '') {
                                              fetchPost();
                                              Navigator.pop(context);
                                            } else {
                                              final snackBar = SnackBar(
                                                  content: Text(
                                                      'Fail to save. Please take photo!'));
                                              _globalKey.currentState
                                                  .showSnackBar(snackBar);
                                            }
                                          },
                                          child: Text(
                                            'Save',
                                            style: TextStyle(
                                              fontSize: 18.0,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ))
                            ],
                          ),
                        ))
                  ],
                ),
              ),
            )
          ],
        ));
  }
}
