import 'package:flutter_application_2/models/app_data.dart';
import 'package:flutter_application_2/models/app_settings.dart';
import 'package:flutter_application_2/models/asset_account.dart';
import 'package:flutter_application_2/models/app_theme_mode.dart';
import 'package:flutter_application_2/models/storage_location.dart';
import 'package:flutter_application_2/models/asset_type.dart';
import 'package:flutter_application_2/models/balance_change_type.dart';
import 'package:flutter_application_2/models/bank_institution.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppData', () {
    test('addAccount creates a create record', () {
      final account = AssetAccount.create(
        id: '1',
        type: AssetType.wechat,
        balance: 100,
      );

      final data = AppData.empty().addAccount(account);

      expect(data.store.accounts, hasLength(1));
      expect(data.records, hasLength(1));
      expect(data.records.first.type, BalanceChangeType.create);
      expect(data.records.first.newBalance, 100);
    });

    test('updateAccount creates record only when balance changes', () {
      final account = AssetAccount.create(
        id: '1',
        type: AssetType.wechat,
        balance: 100,
      );
      final initial = AppData.empty().addAccount(account);

      final renamed = initial.updateAccount(account.copyWith(name: '日常'));
      expect(renamed.records, hasLength(1));

      final updated = initial.updateAccount(account.copyWith(balance: 200));
      expect(updated.records, hasLength(2));
      expect(updated.records.last.type, BalanceChangeType.update);
      expect(updated.records.last.previousBalance, 100);
      expect(updated.records.last.newBalance, 200);
    });

    test('removeAccount removes related records', () {
      final account = AssetAccount.create(
        id: '1',
        type: AssetType.bankCard,
        bank: BankInstitution.cmb,
        balance: 500,
      );
      final data = AppData.empty().addAccount(account).removeAccount('1');

      expect(data.store.accounts, isEmpty);
      expect(data.records, isEmpty);
    });

    test('recordCurrentMonthSnapshot replaces same month entry', () {
      final account = AssetAccount.create(
        id: '1',
        type: AssetType.wechat,
        balance: 1000,
      );
      final initial = AppData.empty().addAccount(account);
      final first = initial.recordCurrentMonthSnapshot();
      final updatedStore = first.store.updateAccount(
        account.copyWith(balance: 1500),
      );
      final second = first
          .copyWith(store: updatedStore)
          .recordCurrentMonthSnapshot();

      expect(first.monthlySnapshots, hasLength(1));
      expect(second.monthlySnapshots, hasLength(1));
      expect(second.currentMonthSnapshot?.netWorth, 1500);
    });

    test('addAccount preserves theme mode in settings', () {
      const settings = AppSettings(themeMode: AppThemeMode.dark);
      final account = AssetAccount.create(
        id: '1',
        type: AssetType.wechat,
        balance: 1,
      );
      final data = AppData.empty()
          .updateSettings(settings)
          .addAccount(account);

      expect(data.settings.themeMode, AppThemeMode.dark);
    });

    test('round-trips theme mode through json', () {
      const settings = AppSettings(themeMode: AppThemeMode.dark);
      final data = AppData.empty().updateSettings(settings);
      final restored = AppData.fromJson(data.toJson());

      expect(restored.settings.themeMode, AppThemeMode.dark);
    });

    test('round-trips storage settings through json', () {
      const settings = AppSettings(
        storageLocation: StorageLocation.localFile,
        customStoragePath: '/tmp/assets',
      );
      final data = AppData.empty().updateSettings(settings);
      final restored = AppData.fromJson(data.toJson());

      expect(restored.settings.storageLocation, StorageLocation.localFile);
      expect(restored.settings.customStoragePath, '/tmp/assets');
    });

    test('round-trips through json', () {
      final account = AssetAccount.create(
        id: '1',
        type: AssetType.huabei,
        balance: 88,
      );
      final data = AppData.empty()
          .addAccount(account)
          .updateAccount(account.copyWith(balance: 120));

      final restored = AppData.fromJson(data.toJson());

      expect(restored.store.accounts.first.balance, 120);
      expect(restored.records, hasLength(2));
    });
  });
}
