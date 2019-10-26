import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';

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
       
            Navigator.of(context).push(MaterialPageRoute(builder:(context)=>DisplayPictureScreen(imagePath: path)));

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
  const DisplayPictureScreen({Key key, this.imagePath}) : super(key: key);

  @override
  _DisplayPictureScreenState createState() => _DisplayPictureScreenState(
    this.imagePath
  );
}
class _DisplayPictureScreenState extends State<DisplayPictureScreen> {
  Position _currentPosition; 
  final String imagePath;
 _DisplayPictureScreenState(this.imagePath) ;
  
  @override
  Widget build(BuildContext context) {
    print('Test Image result = $imagePath');
    return Scaffold(
      appBar: AppBar(title: Text('Check In')),
      body:  Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
        
          Image.file(File(imagePath), height: 250,
                        ),
      
          if (_currentPosition != null)
                Text(
                    "LAT: ${_currentPosition.latitude}, LNG: ${_currentPosition.longitude}​, DateTime: ${DateTime.now()}", ),
          if(_currentPosition == null)          
              FlatButton(
                child: Text("Get location"),
                onPressed: () {
                  _getCurrentLocation();
                },
                  color: Colors.lightBlue,
                  textColor: Colors.white,
              ),
          RaisedButton(
                  
                  child: Text('Check In'),
                  onPressed: () {

                  },
                  color: Colors.lightBlue,
                  textColor: Colors.white,
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
      });
    }).catchError((e) {
      print(e);
    });
  }
}