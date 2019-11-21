import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiHelper {

  Future<http.Response> fetchPost(String url, Map<String, dynamic> body) async {
    final response = await http.post(url,
        body: json.encode(body),
        headers: {HttpHeaders.contentTypeHeader: 'application/json'});
    print('Fetch Post');
    return response;
  }

 Future<http.Response> fetchPost1(String url, Map<String, dynamic> body,String token1) async {
    final response = await http.post(url,
        body: json.encode(body),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.authorizationHeader: "Bearer " + token1
          });
    print('Fetch Post');
    return response;
  }

  Future<http.Response> fetchPut(String url, Map<String, dynamic> body,int id,String token1) async {
    var response = await http.put(url + id.toString(),
          body: jsonEncode(body),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader: "Bearer " + token1
          });
    print('Fetch Put');
    return response;
  }

  Future<http.Response> fetchData(String url,String token1) async {
    final response = await http.get(url, headers: {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: "Bearer " + token1
    });
    print('Fetch Data');
    return response;
  }

  Future<http.Response> deleteData(String url,int id,String token1) async {
    final response = await http.delete(
        url + id.toString(),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.authorizationHeader: "Bearer " + token1
        });
    print('Delete Data');
    return response;
  }

}
