import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gpstrackingplan/models/gpsroutemodel.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/apiHelper .dart';

class RouteMapping extends StatefulWidget {
  @override
  _RouteMappingState createState() => _RouteMappingState();
}

class _RouteMappingState extends State<RouteMapping> {
  List<Gpsroutemodel> _listRoute = [];
  Map<String, Marker> _markers = {};
  Completer<GoogleMapController> _controller = Completer();
  ApiHelper _apiHelper;
  
  _loadSetting() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _apiHelper = ApiHelper(prefs);
    });
  }

  Future<List<Gpsroutemodel>> fetchRouteData(DateTime from, DateTime to) async {
    final response = await _apiHelper.fetchData('/api/Gpstrackings/GpstrackingsByDate/' +
     DateFormat('yyyy-MM-dd').format(from) + '/' + DateFormat('yyyy-MM-dd').format(to) + '/' + _apiHelper.userId);

    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      _listRoute = [];
      for (var item in jsonData) {
        Gpsroutemodel routemodel = Gpsroutemodel.fromJson(item);
        _listRoute.add(routemodel);
      }
      return _listRoute;
    } else {
      print(response.statusCode);
      throw Exception('Failed to load post');
    }
  }

  Future<void> _onMapCreated(GoogleMapController controller) async {
    await fetchRouteData(DateTime.now(), DateTime.now());
    _controller.complete(controller);
    setState(() {
      _markers.clear();
      for (final itm in _listRoute) {
        final marker = Marker(
          markerId: MarkerId(itm.gpsID.toString()),
          position: LatLng(itm.lat, itm.lng),
          infoWindow: InfoWindow(
            title: itm.customer,
            snippet: itm.checkType,
          ),
        );
        _markers[itm.gpsID.toString()] = marker;
      }
    });
  }

  Future<void> _goToLocation(CameraPosition cameraPosition) async {
    print('In Location');
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }

  @override
  void initState() {
    super.initState();
    _loadSetting();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: AppBar(
          title: Text('Your Routing Map'),
        ),
        body: Stack(
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: GoogleMap(
                mapType: MapType.normal,
                initialCameraPosition: CameraPosition(
                  target: const LatLng(11.559113, 104.871960),
                  tilt: 40,
                  zoom: 8,
                ),
                onMapCreated: _onMapCreated,
                markers: _markers.values.toSet(),
              ),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Container(
                  height: 100.0,
                  child: FutureBuilder(
                    future: fetchRouteData(DateTime.now(), DateTime.now()),
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      if (snapshot.data == null) {
                        return Container(
                          child: Center(child: Text('Loading...')),
                        );
                      } else {
                        return ListView.builder(
                          itemCount: snapshot.data.length,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (BuildContext context, int index) {
                            return new Container(
                                margin: EdgeInsets.symmetric(vertical: 10.0),
                                width: 300.0,
                                child: Card(
                                  child: Wrap(
                                    children: <Widget>[
                                      ListTile(
                                        leading: Icon(Icons.person),
                                        title:
                                            Text(snapshot.data[index].customer),
                                        subtitle: Text(
                                            snapshot.data[index].checkType +
                                                "=>" +
                                                DateFormat("yyy/MM/dd,HH:mm:ss")
                                                    .format(snapshot.data[index]
                                                        .gpsdatetime)),
                                        onTap: () {
                                          final CameraPosition _location = CameraPosition(
                                                            bearing: 100,
                                                            target: LatLng(snapshot.data[index].lat, snapshot.data[index].lng),
                                                            tilt: 30,
                                                            zoom: 15);
                                          _goToLocation(_location);
                                        },
                                      )
                                    ],
                                  ),
                                ));
                          },
                        );
                      }
                    },
                  )),
            )
          ],
        ));
  }
}
