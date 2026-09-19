import '../../models/app_data.dart';

abstract class DataStorage {
  Future<AppData?> load();

  Future<void> save(AppData data);

  Future<void> clear();

  Future<bool> exists();

  Future<String> describeLocation();
}
