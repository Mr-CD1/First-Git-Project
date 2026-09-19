import 'package:flutter_application_2/models/asset_account.dart';
import 'package:flutter_application_2/models/asset_store.dart';
import 'package:flutter_application_2/models/asset_type.dart';
import 'package:flutter_application_2/models/bank_institution.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AssetAccount', () {
    test('bank card uses bank display name when name is empty', () {
      final account = AssetAccount.create(
        id: '1',
        type: AssetType.bankCard,
        bank: BankInstitution.cmb,
        balance: 1000,
      );

      expect(account.displayName, '招商银行');
      expect(account.signedBalance, 1000);
    });

    test('huabei is stored as positive balance but signed as negative', () {
      final account = AssetAccount.create(
        id: '2',
        type: AssetType.huabei,
        balance: 1200,
      );

      expect(account.category.name, 'liability');
      expect(account.balance, 1200);
      expect(account.signedBalance, -1200);
    });

    test('round-trips through json', () {
      final account = AssetAccount.create(
        id: '3',
        type: AssetType.bankCard,
        bank: BankInstitution.other,
        customBankName: '地方农商行',
        name: '储蓄卡',
        balance: 500,
        note: '测试',
      );

      final restored = AssetAccount.fromJson(account.toJson());

      expect(restored.id, account.id);
      expect(restored.type, account.type);
      expect(restored.category, account.category);
      expect(restored.bank, account.bank);
      expect(restored.customBankName, account.customBankName);
      expect(restored.displayName, '储蓄卡');
      expect(restored.balance, 500);
      expect(restored.note, '测试');
    });
  });

  group('AssetStore', () {
    test('calculates assets, liabilities and net worth', () {
      final store = AssetStore(accounts: [
        AssetAccount.create(
          id: '1',
          type: AssetType.wechat,
          balance: 3200,
        ),
        AssetAccount.create(
          id: '2',
          type: AssetType.bankCard,
          bank: BankInstitution.cmb,
          balance: 7880,
        ),
        AssetAccount.create(
          id: '3',
          type: AssetType.huabei,
          balance: 1200,
        ),
      ]);

      expect(store.totalAssets, 11080);
      expect(store.totalLiabilities, 1200);
      expect(store.netWorth, 9880);
      expect(store.assets, hasLength(2));
      expect(store.liabilities, hasLength(1));
    });

    test('round-trips through json', () {
      final store = AssetStore(accounts: [
        AssetAccount.create(
          id: '1',
          type: AssetType.alipay,
          balance: 100,
        ),
        AssetAccount.create(
          id: '2',
          type: AssetType.huabei,
          balance: 50,
        ),
      ]);

      final restored = AssetStore.fromJson(store.toJson());

      expect(restored.accounts, hasLength(2));
      expect(restored.netWorth, 50);
    });
  });
}
