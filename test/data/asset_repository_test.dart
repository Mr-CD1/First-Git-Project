import 'dart:convert';
import 'dart:io';

import 'package:flutter_application_2/data/asset_repository.dart';
import 'package:flutter_application_2/data/storage/storage_config.dart';
import 'package:flutter_application_2/models/app_data.dart';
import 'package:flutter_application_2/models/app_settings.dart';
import 'package:flutter_application_2/models/asset_account.dart';
import 'package:flutter_application_2/models/asset_type.dart';
import 'package:flutter_application_2/models/storage_location.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AssetRepository storage', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('asset_repo_test');
      SharedPreferences.setMockInitialValues({});
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('loads legacy shared preferences data by default', () async {
      final account = AssetAccount.create(
        id: '1',
        type: AssetType.wechat,
        balance: 500,
      );
      final data = AppData.empty().addAccount(account);

      SharedPreferences.setMockInitialValues({
        StorageConfig.legacyDataKey: jsonEncode(data.toJson()),
      });

      final repository = AssetRepository();
      final loaded = await repository.load();

      expect(loaded.store.accounts, hasLength(1));
      expect(loaded.store.accounts.first.balance, 500);
    });

    test('migrates data from app internal storage to custom path', () async {
      final account = AssetAccount.create(
        id: '1',
        type: AssetType.wechat,
        balance: 888,
      );
      final initial = AppData.empty().addAccount(account);
      final repository = AssetRepository();

      await repository.save(initial);

      final customDir = Directory('${tempDir.path}/custom_storage');
      final migratedSettings = initial.settings.copyWith(
        storageLocation: StorageLocation.customPath,
        customStoragePath: customDir.path,
      );
      final migratedData = initial.updateSettings(migratedSettings);

      await repository.save(migratedData);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.containsKey(StorageConfig.legacyDataKey), isFalse);

      final customFile = File(
        '${customDir.path}/${StorageConfig.dataFileName}',
      );
      expect(await customFile.exists(), isTrue);

      final reloaded = await repository.load();
      expect(reloaded.store.accounts.first.balance, 888);
      expect(
        reloaded.settings.storageLocation,
        StorageLocation.customPath,
      );
    });

    test('persists storage settings in saved data json', () async {
      final repository = AssetRepository();
      final customDir = Directory('${tempDir.path}/settings_storage');
      final data = AppData.empty().updateSettings(
        AppSettings(
          storageLocation: StorageLocation.customPath,
          customStoragePath: customDir.path,
          reminderEnabled: false,
        ),
      );

      await repository.save(data);
      final loaded = await repository.load();

      expect(loaded.settings.storageLocation, StorageLocation.customPath);
      expect(loaded.settings.customStoragePath, customDir.path);
      expect(loaded.settings.reminderEnabled, isFalse);
    });
  });
}
