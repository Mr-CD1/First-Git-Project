import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../../models/app_data.dart';
import 'data_storage.dart';
import 'storage_config.dart';

class LocalFileStorage implements DataStorage {
  Future<File> get _file async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/${StorageConfig.dataFileName}');
  }

  @override
  Future<AppData?> load() async {
    final file = await _file;
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
    final file = await _file;
    await file.parent.create(recursive: true);
    await file.writeAsString(jsonEncode(data.toJson()));
  }

  @override
  Future<void> clear() async {
    final file = await _file;
    if (await file.exists()) {
      await file.delete();
    }
  }

  @override
  Future<bool> exists() async {
    return (await _file).exists();
  }

  @override
  Future<String> describeLocation() async {
    final file = await _file;
    return file.path;
  }
}
