import 'package:shared_preferences/shared_preferences.dart';

class PreferenceHelper {
  String _token = '';
  String _urlSetting = '';
  PreferenceHelper(SharedPreferences sharedPreferences){
    _token = (sharedPreferences.getString('token') ?? '');
    _urlSetting = (sharedPreferences.getString('url') ?? '');
  }

  String get token{
    return _token;
  }

  String get urlSetting{
    return _urlSetting;
  }

}
