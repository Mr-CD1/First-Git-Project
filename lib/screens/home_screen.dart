import 'package:flutter/material.dart';

import '../models/app_data.dart';
import '../widgets/asset_list_tile.dart';
import '../widgets/home_overview_hero.dart';
import '../widgets/empty_accounts_view.dart';
import '../widgets/monthly_savings_card.dart';
import 'account_form_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.appData,
    required this.onAppDataChanged,
    this.onOpenMonthlyChart,
    required this.onOpenDrawer,
  });

  final AppData appData;
  final Future<void> Function(AppData data) onAppDataChanged;
  final VoidCallback? onOpenMonthlyChart;
  final VoidCallback onOpenDrawer;

  Future<void> _openAccountForm(
    BuildContext context, {
    String? accountId,
  }) async {
    final result = await Navigator.of(context).push<AppData>(
      MaterialPageRoute(
        builder: (context) => AccountFormScreen(
          appData: appData,
          accountId: accountId,
        ),
      ),
    );

    if (result != null) {
      await onAppDataChanged(result);
    }
  }

  Future<void> _recordMonthlySnapshot(BuildContext context) async {
    final nextData = appData.recordCurrentMonthSnapshot();
    await onAppDataChanged(nextData);
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('已记录本月资产快照')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = appData.store;
    final assets = store.assets
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    final liabilities = store.liabilities
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    final hasAccounts = store.accounts.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        HomeOverviewHero(
          netWorth: store.netWorth,
          totalAssets: store.totalAssets,
          totalLiabilities: store.totalLiabilities,
          onOpenDrawer: onOpenDrawer,
        ),
        Expanded(
          child: ListView(
            children: [
              MonthlySavingsCard(
                appData: appData,
                onRecord: () => _recordMonthlySnapshot(context),
                onOpenChart: onOpenMonthlyChart,
              ),
              if (!hasAccounts)
                const EmptyAccountsView()
              else ...[
                if (assets.isNotEmpty) ...[
                  _SectionTitle(title: '资产', count: assets.length),
                  ...assets.map(
                    (account) => AssetListTile(
                      account: account,
                      onTap: () =>
                          _openAccountForm(context, accountId: account.id),
                    ),
                  ),
                ],
                if (liabilities.isNotEmpty) ...[
                  _SectionTitle(title: '负债', count: liabilities.length),
                  ...liabilities.map(
                    (account) => AssetListTile(
                      account: account,
                      onTap: () =>
                          _openAccountForm(context, accountId: account.id),
                    ),
                  ),
                ],
              ],
              const SizedBox(height: 88),
            ],
          ),
        ),
      ],
    );
  }
}

class HomeFab extends StatelessWidget {
  const HomeFab({
    super.key,
    required this.onPressed,
  });

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: onPressed,
      icon: const Icon(Icons.add),
      label: const Text('添加账户'),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    required this.count,
  });

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
      child: Row(
        children: [
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$count',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
