import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<bool> saveString(String key, String value) {
    return _prefs.setString(key, value);
  }

  Future<bool> saveInt(String key, int value) {
    return _prefs.setInt(key, value);
  }

  Future<bool> saveBool(String key, bool value) {
    return _prefs.setBool(key, value);
  }

  Future<bool> saveDouble(String key, double value) {
    return _prefs.setDouble(key, value);
  }

  String? getString(String key) {
    return _prefs.getString(key);
  }

  int? getInt(String key) {
    return _prefs.getInt(key);
  }

  bool? getBool(String key) {
    return _prefs.getBool(key);
  }

  double? getDouble(String key) {
    return _prefs.getDouble(key);
  }

  Future<bool> remove(String key) {
    return _prefs.remove(key);
  }

  Future<bool> clear() {
    return _prefs.clear();
  }
}
