import 'package:shared_preferences/shared_preferences.dart';

import '../../models/storage_location.dart';
import 'custom_path_storage.dart';
import 'data_storage.dart';
import 'local_file_storage.dart';
import 'shared_preferences_storage.dart';
import 'storage_config.dart';

class StorageFactory {
  StorageFactory({SharedPreferences? preferences})
      : _preferences = preferences;

  SharedPreferences? _preferences;

  Future<SharedPreferences> get _prefs async {
    return _preferences ??= await SharedPreferences.getInstance();
  }

  Future<DataStorage> create(StorageConfig config) async {
    switch (config.location) {
      case StorageLocation.appInternal:
        return SharedPreferencesStorage(await _prefs);
      case StorageLocation.localFile:
        return LocalFileStorage();
      case StorageLocation.customPath:
        final path = config.customPath?.trim();
        if (path == null || path.isEmpty) {
          throw StateError('自定义存储路径未设置');
        }
        return CustomPathStorage(path);
    }
  }
}
