import 'dart:convert';
import 'dart:io';

import '../../models/app_data.dart';
import 'data_storage.dart';
import 'storage_config.dart';

class CustomPathStorage implements DataStorage {
  CustomPathStorage(this.directoryPath);

  final String directoryPath;

  File get _file {
    return File('$directoryPath/${StorageConfig.dataFileName}');
  }

  @override
  Future<AppData?> load() async {
    final file = _file;
    if (!await file.exists()) {
      return null;
    }
    final raw = await file.readAsString();
    if (raw.isEmpty) {
      return null;
    }
    return AppData.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  @override
  Future<void> save(AppData data) async {
    final file = _file;
    await Directory(directoryPath).create(recursive: true);
    await file.writeAsString(jsonEncode(data.toJson()));
  }

  @override
  Future<void> clear() async {
    final file = _file;
    if (await file.exists()) {
      await file.delete();
    }
  }

  @override
  Future<bool> exists() async {
    return _file.exists();
  }

  @override
  Future<String> describeLocation() async {
    return _file.path;
  }
}
