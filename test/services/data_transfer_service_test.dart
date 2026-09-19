import 'dart:convert';

import 'package:flutter_application_2/models/app_data.dart';
import 'package:flutter_application_2/models/app_settings.dart';
import 'package:flutter_application_2/models/asset_account.dart';
import 'package:flutter_application_2/models/asset_type.dart';
import 'package:flutter_application_2/models/storage_location.dart';
import 'package:flutter_application_2/services/data_transfer_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DataTransferService', () {
    final service = DataTransferService();

    test('encodes and decodes wrapped export payload', () {
      final account = AssetAccount.create(
        id: '1',
        type: AssetType.wechat,
        balance: 100,
      );
      final data = AppData.empty().addAccount(account);
      final raw = service.encodeExport(data);
      final restored = service.decodeImport(raw);

      expect(restored.store.accounts, hasLength(1));
      expect(restored.store.accounts.first.balance, 100);
    });

    test('supports legacy raw app data json', () {
      final account = AssetAccount.create(
        id: '1',
        type: AssetType.alipay,
        balance: 200,
      );
      final data = AppData.empty().addAccount(account);
      final raw = jsonEncode(data.toJson());
      final restored = service.decodeImport(raw);

      expect(restored.store.accounts.first.balance, 200);
    });

    test('merge keeps current storage settings', () {
      const currentSettings = AppSettings(
        storageLocation: StorageLocation.customPath,
        customStoragePath: '/tmp/current',
        reminderDay: 15,
      );
      const importedSettings = AppSettings(
        storageLocation: StorageLocation.appInternal,
        reminderDay: 3,
      );

      final current = AppData.empty().updateSettings(currentSettings);
      final imported = AppData.empty().updateSettings(importedSettings);

      final merged = service.mergeImportedData(
        current: current,
        imported: imported,
      );

      expect(merged.settings.storageLocation, StorageLocation.customPath);
      expect(merged.settings.customStoragePath, '/tmp/current');
      expect(merged.settings.reminderDay, 15);
    });

    test('throws for invalid json', () {
      expect(
        () => service.decodeImport('{invalid'),
        throwsA(isA<DataTransferException>()),
      );
    });
  });
}
