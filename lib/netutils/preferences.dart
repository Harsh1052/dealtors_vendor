import 'package:shared_preferences/shared_preferences.dart';
class SharedPreferencesHelper {
  String user_id,name,email_address,mobile_no,business_name,is_profile_business_category,isApprove_open,later_app_version;

  static Future<String> getPreference(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }
  static Future<bool> setPreference(String key,String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(key, value);
  }
  static Future<bool> clearPreference(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.remove(key);
  }
  static Future<bool> clearAllPreference() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.clear();
  }
}
