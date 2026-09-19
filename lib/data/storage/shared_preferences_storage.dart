import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../models/app_data.dart';
import 'data_storage.dart';
import 'storage_config.dart';

class SharedPreferencesStorage implements DataStorage {
  SharedPreferencesStorage(this._preferences);

  final SharedPreferences _preferences;

  @override
  Future<AppData?> load() async {
    final raw = _preferences.getString(StorageConfig.legacyDataKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    return AppData.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  @override
  Future<void> save(AppData data) async {
    await _preferences.setString(
      StorageConfig.legacyDataKey,
      jsonEncode(data.toJson()),
    );
  }

  @override
  Future<void> clear() async {
    await _preferences.remove(StorageConfig.legacyDataKey);
  }

  @override
  Future<bool> exists() async {
    return _preferences.containsKey(StorageConfig.legacyDataKey);
  }

  @override
  Future<String> describeLocation() async {
    return '应用内置存储';
  }
}
