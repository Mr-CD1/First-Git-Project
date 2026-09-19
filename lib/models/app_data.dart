import 'package:uuid/uuid.dart';

import 'app_settings.dart';
import 'asset_account.dart';
import 'asset_store.dart';
import 'balance_change_type.dart';
import 'balance_record.dart';
import 'monthly_chart_item.dart';
import 'monthly_snapshot.dart';

class AppData {
  const AppData({
    this.store = const AssetStore(),
    this.records = const [],
    this.monthlySnapshots = const [],
    this.settings = const AppSettings(),
  });

  final AssetStore store;
  final List<BalanceRecord> records;
  final List<MonthlySnapshot> monthlySnapshots;
  final AppSettings settings;

  List<MonthlySnapshot> get sortedMonthlySnapshots =>
      MonthlySnapshot.sorted(monthlySnapshots);

  MonthlySnapshot? snapshotForMonth(int year, int month) {
    for (final snapshot in monthlySnapshots) {
      if (snapshot.year == year && snapshot.month == month) {
        return snapshot;
      }
    }
    return null;
  }

  MonthlySnapshot? get currentMonthSnapshot {
    final now = DateTime.now();
    return snapshotForMonth(now.year, now.month);
  }

  bool get hasRecordedCurrentMonth => currentMonthSnapshot != null;

  bool get shouldShowInAppReminder {
    if (!settings.reminderEnabled || hasRecordedCurrentMonth) {
      return false;
    }
    final now = DateTime.now();
    return now.day >= settings.safeReminderDay;
  }

  double? get currentMonthSavings {
    final current = currentMonthSnapshot;
    if (current == null) {
      return null;
    }
    return MonthlySnapshot.savingsFor(current, monthlySnapshots);
  }

  List<MonthlyChartItem> get monthlyChartItems {
    final items = <MonthlyChartItem>[];
    for (final snapshot in sortedMonthlySnapshots) {
      final savings = MonthlySnapshot.savingsFor(snapshot, monthlySnapshots);
      if (savings != null) {
        items.add(MonthlyChartItem(snapshot: snapshot, savings: savings));
      }
    }
    return items;
  }

  List<BalanceRecord> recordsForAccount(String accountId) {
    final accountRecords = records
        .where((record) => record.accountId == accountId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return accountRecords;
  }

  AppData copyWith({
    AssetStore? store,
    List<BalanceRecord>? records,
    List<MonthlySnapshot>? monthlySnapshots,
    AppSettings? settings,
  }) {
    return AppData(
      store: store ?? this.store,
      records: records ?? this.records,
      monthlySnapshots: monthlySnapshots ?? this.monthlySnapshots,
      settings: settings ?? this.settings,
    );
  }

  AppData addAccount(AssetAccount account, {Uuid? uuid}) {
    final idGenerator = uuid ?? const Uuid();
    final record = BalanceRecord.create(
      id: idGenerator.v4(),
      accountId: account.id,
      type: BalanceChangeType.create,
      previousBalance: 0,
      newBalance: account.balance,
      note: '创建账户',
    );

    return copyWith(
      store: store.addAccount(account),
      records: [...records, record],
    );
  }

  AppData updateAccount(AssetAccount updated, {Uuid? uuid}) {
    final existing = store.findById(updated.id);
    if (existing == null) {
      return this;
    }

    final idGenerator = uuid ?? const Uuid();
    final nextRecords = [...records];
    if (existing.balance != updated.balance) {
      nextRecords.add(
        BalanceRecord.create(
          id: idGenerator.v4(),
          accountId: updated.id,
          type: BalanceChangeType.update,
          previousBalance: existing.balance,
          newBalance: updated.balance,
          note: '修改余额',
        ),
      );
    }

    return copyWith(
      store: store.updateAccount(updated),
      records: nextRecords,
    );
  }

  AppData removeAccount(String accountId) {
    return copyWith(
      store: store.removeAccount(accountId),
      records: records.where((record) => record.accountId != accountId).toList(),
    );
  }

  AppData recordCurrentMonthSnapshot({Uuid? uuid}) {
    final now = DateTime.now();
    final idGenerator = uuid ?? const Uuid();
    final snapshot = MonthlySnapshot(
      id: idGenerator.v4(),
      year: now.year,
      month: now.month,
      netWorth: store.netWorth,
      totalAssets: store.totalAssets,
      totalLiabilities: store.totalLiabilities,
      recordedAt: now,
    );

    final others = monthlySnapshots
        .where(
          (item) => !(item.year == now.year && item.month == now.month),
        )
        .toList();

    return copyWith(monthlySnapshots: [...others, snapshot]);
  }

  AppData updateSettings(AppSettings settings) => copyWith(settings: settings);

  Map<String, dynamic> toJson() => {
        'store': store.toJson(),
        'records': records.map((record) => record.toJson()).toList(),
        'monthlySnapshots':
            monthlySnapshots.map((snapshot) => snapshot.toJson()).toList(),
        'settings': settings.toJson(),
      };

  factory AppData.fromJson(Map<String, dynamic> json) {
    final storeJson = json['store'] as Map<String, dynamic>?;
    final recordList = (json['records'] as List<dynamic>? ?? [])
        .map((item) => BalanceRecord.fromJson(item as Map<String, dynamic>))
        .toList();
    final snapshotList = (json['monthlySnapshots'] as List<dynamic>? ?? [])
        .map(
          (item) => MonthlySnapshot.fromJson(item as Map<String, dynamic>),
        )
        .toList();

    return AppData(
      store: storeJson != null
          ? AssetStore.fromJson(storeJson)
          : AssetStore.empty(),
      records: recordList,
      monthlySnapshots: snapshotList,
      settings: AppSettings.fromJson(json['settings'] as Map<String, dynamic>?),
    );
  }

  factory AppData.empty() => const AppData();
}
