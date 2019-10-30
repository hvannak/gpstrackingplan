import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:camera/camera.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Routevisit extends StatefulWidget {
   @override
  _RoutevisitState createState() => _RoutevisitState();
}
class _RoutevisitState extends State<Routevisit> {
  CameraDescription _firstCamera;
  @override
  void initState() {
    super.initState();
    main();
  }
  
  Future<void> main() async {
  // Obtain a list of the available cameras on the device.
  final cameras = await availableCameras();
  // Get a specific camera from the list of available cameras.
  _firstCamera = cameras.first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Route Visit'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FlatButton(
              child: Text("Take Photo"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                  builder: (context) => TakePictureScreen(camera: _firstCamera),
                  ),
                );         
              }
            ),
          ],
        ),
      ),
    );
  }

}

// A screen that allows users to take a picture using a given camera.
class TakePictureScreen extends StatefulWidget {
  final CameraDescription camera;
  const TakePictureScreen({
    Key key,
    @required this.camera,
  }) : super(key: key);
  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  CameraController _controller;
  Future<void> _initializeControllerFuture;
  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.medium,
    );
    _initializeControllerFuture = _controller.initialize();
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Take a picture')),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return CameraPreview(_controller);
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.camera_alt),
        onPressed: () async {
          try {
            await _initializeControllerFuture;
           final path = join(
              (await getTemporaryDirectory()).path,
              '${DateTime.now()}.png',
            );
            await _controller.takePicture(path);

            File imagefile = new File(path); 
            // Convert to amazon requirements
            List<int> imageBytes = imagefile.readAsBytesSync();
            String base64Image = base64Encode(imageBytes);

            Navigator.of(context).push(MaterialPageRoute(builder:(context)=>DisplayPictureScreen(imagePath: path, imagebase64: base64Image,)));
          print('Base64 image $base64Image ');
          print('You have got $path as result');
          } catch (e) {
            print(e);
          }
        },
      ),
    );
  }
}

class DisplayPictureScreen extends StatefulWidget {
  final String imagePath;
  final String imagebase64;
  const DisplayPictureScreen({Key key, this.imagePath, this.imagebase64}) : super(key: key);

  @override
  _DisplayPictureScreenState createState() => _DisplayPictureScreenState(
    this.imagePath, this.imagebase64
  );
}
class _DisplayPictureScreenState extends State<DisplayPictureScreen> {
  Position _currentPosition; 
  final String imagePath;
  final String imagebase64;
 _DisplayPictureScreenState(this.imagePath, this.imagebase64) ;
  final _formKey = GlobalKey<FormState>();
  String _token = '';
  String _urlSetting = '';

  double _lat ;
  double _lng ;
  DateTime _fromDate = DateTime.now();
  var _typeValue = 'checkin';
  var _customerValue = 'new';

  _loadSetting() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _token = (prefs.getString('token') ?? '');
      _urlSetting = (prefs.getString('url') ?? '');
      print(_urlSetting);
      print(_token);
    });
  }
  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _loadSetting();
    _fromDate = new DateTime.now();
  }

  Future<String> fetchPost() async {
    var body = {
      'GpsID': '0',
      'Lat': _lat, 
      'Lng': _lng, 
      'Gpsdatetime': DateFormat('yyyy/MM/dd HH:mm').format(_fromDate), 
      'CheckType': _typeValue, 
      'Customer' : _customerValue , 
      'Image' : imagebase64 ,
      };
    print('test data to upload = $body');
    print(_urlSetting);
    final 
        response = await http.post(_urlSetting + '/Gpstrackings',
          body: json.encode(body),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader: "Bearer " + _token
          }); 
        if (response.statusCode == 200) {
            return response.body;
    } else {
      print(response.statusCode);
      throw Exception('Failed to load post');
    }   
  }

  @override
  Widget build(BuildContext context) {
    print('Test Image result = $imagePath');
    print ('test location = $_currentPosition');
    
    return Scaffold(
      appBar: AppBar(title: Text('Check In')),
      body:Stack(
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
                            child: Image.file(File(imagePath), height: 200,
                          ),
                          ),
                          Padding(
                          padding: EdgeInsets.symmetric(vertical: 5.0), 
                            child: DropdownButton<String>(
                            hint: new Text('Type'),
                            value: _typeValue,
                            icon: Icon(Icons.arrow_downward),
                            iconSize: 14,
                            elevation: 16,
                            style: TextStyle(color: Colors.deepPurple),
                            onChanged: (String newValue) {
                              setState(() {
                                _typeValue = newValue;
                              });
                            },
                            items: <String>['checkin', 'checkout', 'farm/depo', 'supdepo']
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            )
                          ),

                          Padding(
                          padding: EdgeInsets.symmetric(vertical: 5.0), 
                            child: DropdownButton<String>(
                            hint: new Text('Customer'),
                            value: _customerValue,
                            icon: Icon(Icons.arrow_downward),
                            iconSize: 14,
                            elevation: 16,
                            style: TextStyle(color: Colors.deepPurple),
                            // underline: Container(
                            //   height: 2,
                            //   color: Colors.deepPurpleAccent,
                            // ),
                            onChanged: (String newValue) {
                              setState(() {
                                _customerValue = newValue;
                              });
                            },
                            items: <String>['new', 'old']
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            )
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 5.0), 
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Center(child: RaisedButton (
                                    padding: EdgeInsets.symmetric(
                                      vertical: 15.0
                                    ),
                                    shape: new RoundedRectangleBorder(
                                      borderRadius: new BorderRadius.circular(8.0),
                                    ),
                                    onPressed: () {
                                      if (_formKey.currentState.validate()){
                                        fetchPost();
                                      }
                                    },
                                    child: Text(
                                      'Check In',
                                      style: TextStyle(fontSize:  14.0),
                                      
                                    ),
                                  ),
                                  )
                                ]
                            )
                          ),
                        ]
                        )
                      )
                    )
               ] 
              ) 
            )
          )
        ]
      )
    );
      
  }



  _getCurrentLocation() {
    final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
    geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
        setState(() {
        _currentPosition = position;
        _lat = position.latitude;
        _lng = position.longitude;
      });
    }).catchError((e) {
      print(e);
    });
  }
}