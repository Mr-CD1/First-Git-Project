import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_data.dart';
import '../models/storage_location.dart';
import 'storage/data_storage.dart';
import 'storage/storage_config.dart';
import 'storage/storage_factory.dart';

class AssetRepository {
  AssetRepository({
    SharedPreferences? preferences,
    StorageFactory? storageFactory,
  })  : _storageFactory = storageFactory ?? StorageFactory(preferences: preferences),
        _preferences = preferences;

  static const _storageKey = StorageConfig.legacyDataKey;

  final StorageFactory _storageFactory;
  SharedPreferences? _preferences;

  Future<SharedPreferences> get _prefs async {
    return _preferences ??= await SharedPreferences.getInstance();
  }

  Future<StorageConfig> _loadMetaConfig() async {
    final prefs = await _prefs;
    final raw = prefs.getString(StorageConfig.metaKey);
    if (raw != null && raw.isNotEmpty) {
      return StorageConfig.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    }

    if (prefs.containsKey(_storageKey)) {
      return const StorageConfig(location: StorageLocation.appInternal);
    }

    return StorageConfig.defaults();
  }

  Future<void> _saveMetaConfig(StorageConfig config) async {
    final prefs = await _prefs;
    await prefs.setString(StorageConfig.metaKey, jsonEncode(config.toJson()));
  }

  Future<DataStorage> _storageFor(StorageConfig config) {
    return _storageFactory.create(config);
  }

  Future<AppData> load() async {
    final config = await _loadMetaConfig();
    final storage = await _storageFor(config);
    final data = await storage.load();

    if (data != null) {
      return data.copyWith(settings: config.applyTo(data.settings));
    }

    return AppData.empty().copyWith(
      settings: config.applyTo(AppData.empty().settings),
    );
  }

  Future<void> save(AppData data) async {
    final newConfig = StorageConfig.fromSettings(data.settings);
    if (!newConfig.isValid) {
      throw StateError('请先选择有效的自定义存储文件夹');
    }

    final oldConfig = await _loadMetaConfig();
    final newStorage = await _storageFor(newConfig);

    await newStorage.save(data);

    if (newConfig != oldConfig) {
      final oldStorage = await _storageFor(oldConfig);
      if (await oldStorage.exists()) {
        await oldStorage.clear();
      }
    }

    await _saveMetaConfig(newConfig);
  }

  Future<void> clear() async {
    final config = await _loadMetaConfig();
    final storage = await _storageFor(config);
    await storage.clear();
  }

  Future<String> describeCurrentStorage() async {
    final config = await _loadMetaConfig();
    final storage = await _storageFor(config);
    return storage.describeLocation();
  }
}
