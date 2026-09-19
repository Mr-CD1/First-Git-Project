import 'account_category.dart';
import 'asset_account.dart';

class AssetStore {
  const AssetStore({this.accounts = const []});

  final List<AssetAccount> accounts;

  double get totalAssets => accounts
      .where((account) => account.category == AccountCategory.asset)
      .fold(0, (sum, account) => sum + account.balance);

  double get totalLiabilities => accounts
      .where((account) => account.category == AccountCategory.liability)
      .fold(0, (sum, account) => sum + account.balance);

  double get netWorth => totalAssets - totalLiabilities;

  List<AssetAccount> get assets => accounts
      .where((account) => account.category == AccountCategory.asset)
      .toList();

  List<AssetAccount> get liabilities => accounts
      .where((account) => account.category == AccountCategory.liability)
      .toList();

  List<AssetAccount> get sortedByUpdated {
    final sorted = [...accounts]
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return sorted;
  }

  AssetStore copyWith({List<AssetAccount>? accounts}) =>
      AssetStore(accounts: accounts ?? this.accounts);

  AssetStore addAccount(AssetAccount account) =>
      copyWith(accounts: [...accounts, account]);

  AssetStore updateAccount(AssetAccount updated) {
    return copyWith(
      accounts: accounts
          .map((account) => account.id == updated.id ? updated : account)
          .toList(),
    );
  }

  AssetStore removeAccount(String id) => copyWith(
        accounts: accounts.where((account) => account.id != id).toList(),
      );

  AssetAccount? findById(String id) {
    for (final account in accounts) {
      if (account.id == id) {
        return account;
      }
    }
    return null;
  }

  Map<String, dynamic> toJson() => {
        'accounts': accounts.map((account) => account.toJson()).toList(),
      };

  factory AssetStore.fromJson(Map<String, dynamic> json) {
    final list = (json['accounts'] as List<dynamic>? ?? [])
        .map(
          (item) => AssetAccount.fromJson(item as Map<String, dynamic>),
        )
        .toList();
    return AssetStore(accounts: list);
  }

  factory AssetStore.empty() => const AssetStore();
}
