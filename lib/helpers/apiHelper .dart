import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiHelper {
  String _token = '';
  String _urlSetting = '';
  String _fullname = '';
  String _userId = '';
  String _linkedCustomerID;
  String _priceClass;
  String _deleteSaleorderItems;

  ApiHelper(SharedPreferences sharedPreferences) {
    _token = (sharedPreferences.getString('token') ?? '');
    _urlSetting = (sharedPreferences.getString('url') ?? '');
    _fullname = (sharedPreferences.getString('fullname') ?? '');
    _userId = (sharedPreferences.getString('Id') ?? '');
    _linkedCustomerID = (sharedPreferences.getString('linkedCustomerID') ?? '');
    _priceClass = (sharedPreferences.getString('priceclass') ?? '');
    _deleteSaleorderItems = (sharedPreferences.getString('deleteItems') ?? '');
    if (_urlSetting == '') {
      sharedPreferences.setString('url', 'http://192.168.100.140:8184');
      _urlSetting = 'http://192.168.100.140:8184';
    }
  }

  Future<http.Response> fetchPost(String url, Map<String, dynamic> body) async {
    final response = await http.post(_urlSetting + url,
        body: json.encode(body),
        headers: {HttpHeaders.contentTypeHeader: 'application/json'});
    print('Fetch Post');
    return response;
  }

  Future<http.Response> fetchPost1(
      String url, Map<String, dynamic> body) async {
    final response =
        await http.post(_urlSetting + url, body: json.encode(body), headers: {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: "Bearer " + _token
    });
    print('Fetch Post');
    return response;
  }

  Future<http.Response> fetchPut(
      String url, Map<String, dynamic> body, int id) async {
    print(jsonEncode(body));
    var response = await http.put(_urlSetting + url + id.toString(),
        body: jsonEncode(body),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.authorizationHeader: "Bearer " + _token
        });
    print('Fetch Put');
    return response;
  }

  Future<http.Response> fetchPut1(
      String url, Map<String, dynamic> body) async {
    print(jsonEncode(body));
    var response = await http.put(_urlSetting + url,
        body: jsonEncode(body),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.authorizationHeader: "Bearer " + _token
        });
    print('Fetch Put');
    return response;
  }

  Future<http.Response> fetchData1(String url, String token1) async {
    final response = await http.get(_urlSetting + url, headers: {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: "Bearer " + token1
    });
    print('Fetch Data');
    return response;
  }

  Future<http.Response> fetchData(String url) async {
    final response = await http.get(_urlSetting + url, headers: {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: "Bearer " + _token
    });
    print('Fetch Data');
    return response;
  }

  Future<http.Response> deleteData(String url, int id) async {
    final response =
        await http.delete(_urlSetting + url + id.toString(), headers: {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: "Bearer " + _token
    });
    print('Delete Data');
    return response;
  }

  String get fullname {
    return _fullname;
  }

  String get userId {
    return _userId;
  }

  String get linkedCustomerID {
    return _linkedCustomerID;
  }

  String get priceClass {
    return _priceClass;
  }

  String get deleteSaleorderItems {
    return _deleteSaleorderItems;
  }
}
