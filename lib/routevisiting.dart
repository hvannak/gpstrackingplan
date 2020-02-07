import 'dart:convert';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gpstrackingplan/cameraphoto.dart';
import 'package:gpstrackingplan/models/customermodel.dart';
import 'package:gpstrackingplan/routemapping.dart';
import 'package:gpstrackingplan/waitingdialog.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'app_localizations.dart';
import 'helpers/apiHelper .dart';
import 'helpers/database_helper.dart';
import 'models/gpsroutemodel.dart';

// class Routevisiting extends StatelessWidget {
//   List<Customermodel> customerLocal;
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           AppLocalizations.of(context).translate('route_visit'),
//         ),
//         actions: <Widget>[
//           IconButton(
//             icon: Icon(Icons.view_list),
//             onPressed: () {
//               Navigator.push(context,
//                   MaterialPageRoute(builder: (context) => RouteMapping()));
//             },
//           )
//         ],
//       ),
//       body: MyRouteVisiting(),
//     );
//   }
// }

//    //yyyy-MM-dd,HH:mm:ss

class Routevisiting extends StatefulWidget {
  final String imagePath;
  final  List<Customermodel> customerLocal;
   Routevisiting({Key key, this.imagePath , this.customerLocal}) : super(key: key);

  @override
  _MyRouteVisitingState createState() => _MyRouteVisitingState(this.customerLocal);
}

class _MyRouteVisitingState extends State<Routevisiting> {
  final List<Customermodel> customerLocal;
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
  List<Customermodel> _listCustomer=[];
  ApiHelper _apiHelper;
  var _customerId = TextEditingController();
  String customername;
  _MyRouteVisitingState(this.customerLocal);

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

  fetchPostOnline() async {
    try {
      WaitingDialogs().showLoadingDialog(context, _globalKey);
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
      print('save online');
      final response = await _apiHelper.fetchPost1('/api/Gpstrackings', body);
      print(response.statusCode);
      if (response.statusCode == 200) {
        Navigator.of(context).pop();
        Navigator.pop(context);
        return response.body;
      } else {
        print(response.statusCode);
        throw Exception('Failed to load post');
      }
    } catch (e) {
      Navigator.of(context).pop();
      final snackBar = SnackBar(content: Text('Cannot connect to host'));
      _globalKey.currentState.showSnackBar(snackBar);
    }
  }

  fetchPostOffline() async {
    WaitingDialogs().showLoadingDialog(context, _globalKey);
    var gpsroute = Gpsroutemodel(
        lat: _lat,
        lng: _lng,
        gpsdatetime: DateTime.now().toIso8601String(),
        checkType: _checkType,
        customer: _customer,
        image: _imagebase64,
        userId: null);
    var db = DatabaseHelper();
    print('save offine');
    db.saveGpsroute(gpsroute);
    Navigator.of(context).pop();
    Navigator.pop(context);
  }

  Future<void> _handleSubmit(BuildContext context) async {
    try {
      var db = DatabaseHelper();
      if (await db.checkconnection()) {
        fetchPostOnline();
      } else {
        fetchPostOffline();
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    _firstCamera = cameras.first;
  }

  _navigateTakePictureScreen(BuildContext context) async {
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TakePictureScreen(camera: _firstCamera),
          fullscreenDialog: true,
        ));
    imageCache.clear();
    setState(() {
      _imagePath = result;
      print('test image = $_imagePath');
      File imagefile = new File(_imagePath);
      List<int> imageBytes = imagefile.readAsBytesSync();
      _imagebase64 = "data:image/png;base64," + base64Encode(imageBytes);
    });

    Scaffold.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text("Image is captured")));
  }

 Future<List<Customermodel>> fetchCustomerData(String name) async {
    _listCustomer.clear();
    var db = DatabaseHelper();
    var searchList = await db.getCustomerlocal(name);
    for(var itm in searchList){
      Customermodel customermodel = Customermodel.fromMap(itm);
      _listCustomer.add(customermodel);
    }
    setState(() {
      _customer = _listCustomer[0].customerName;
    });
    return _listCustomer;
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

    // _listCustomer.insert(0, new Customermodel(customerID: 'NEW', customerName: 'NEW'));
    // _listCustomer.insert(1, new Customermodel(customerID: 'OLD', customerName: 'OLD'));
    _customerId.text = _listCustomer[0].customerID;
    customername = _listCustomer[0].customerName;   
    // _customer = _listCustomer[0].customerName;
  // customerLocal.insert(0, new Customermodel(customerID: 'NEW', customerName: 'NEW'));
  // customerLocal.insert(1, new Customermodel(customerID: 'OLD', customerName: 'OLD'));
  //   _customerId.text = customerLocal[0].customerID;
  //   customername = customerLocal[0].customerName;    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            AppLocalizations.of(context).translate('route_visit'),
          ),
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
                                                // var db = DatabaseHelper();
                                                // db.getCustomerlocal(valueget);
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
                                                  fetchCustomerData(_customerSearch.text);                                          
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
                                    print(value);
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
                              
                              // Padding(
                              //   padding: EdgeInsets.symmetric(vertical: 10.0),
                              //   child: DropdownButtonFormField(
                              //     items: customerLocal
                              //         .map((f) => DropdownMenuItem(
                              //               child: AutoSizeText(
                              //                 f.customerName,
                              //                 style: TextStyle(fontSize: 10.0),
                              //                 maxLines: 5,
                              //               ),
                              //               value: f.customerID,
                              //             ))
                              //         .toList(),
                              //     onChanged: (String value) async {
                              //       int index = customerLocal.indexWhere(
                              //           (x) => x.customerID == value);
                              //       SharedPreferences prefs =
                              //           await SharedPreferences.getInstance();
                              //       setState(() {
                              //         _customerId.text = value;
                              //         customername =
                              //             customerLocal[index].customerName;
                              //         prefs.setString('priceclass',
                              //             customerLocal[index].priceclass);
                              //       });
                              //     },
                              //     validator: (val) => val == null
                              //         ? "Customer is required"
                              //         : null,
                              //     hint: Text('Select Item'),
                              //     value: _customerId.text,
                              //     decoration: InputDecoration(
                              //       border: OutlineInputBorder(
                              //           borderRadius: BorderRadius.circular(8),
                              //           borderSide: BorderSide(
                              //             style: BorderStyle.solid,
                              //           )),
                              //       filled: true,
                              //       fillColor: Colors.grey[200],
                              //       contentPadding: EdgeInsets.all(15.0),
                              //     ),
                              //   ),
                              // ),

                              
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
                                              _handleSubmit(context);
                                            } else {
                                              final snackBar = SnackBar(
                                                  content: Text(
                                                      'Fail to save. Please take photo!'));
                                              _globalKey.currentState
                                                  .showSnackBar(snackBar);
                                            }
                                          },
                                          child: Text(
                                            AppLocalizations.of(context)
                                                .translate('save'),
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
