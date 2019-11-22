import 'package:shared_preferences/shared_preferences.dart';

class PreferenceHelper {
  String _token = '';
  String _urlSetting = '';
  String _fullname = '';
  String _userId = '';
  String _linkedCustomerID;
  PreferenceHelper(SharedPreferences sharedPreferences) {
    _token = (sharedPreferences.getString('token') ?? '');
    _urlSetting = (sharedPreferences.getString('url') ?? '');
    _fullname = (sharedPreferences.getString('fullname') ?? '');
    _userId = (sharedPreferences.getString('Id') ?? '');
    _linkedCustomerID = (sharedPreferences.getString('linkedCustomerID') ?? '');
    if (_urlSetting == '') {
      sharedPreferences.setString('url', 'http://192.168.100.140:8184');
      _urlSetting = 'http://192.168.100.140:8184';
    }
  }

  String get token {
    return _token;
  }

  String get urlSetting {
    return _urlSetting;
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
}
