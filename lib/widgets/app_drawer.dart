import 'package:flutter/material.dart';

enum AppSection {
  home('资产总览', Icons.account_balance_wallet_outlined),
  monthlySavings('月度留存', Icons.bar_chart_rounded),
  settings('设置', Icons.settings_outlined);

  const AppSection(this.label, this.icon);

  final String label;
  final IconData icon;
}

class AppDrawer extends StatelessWidget {
  const AppDrawer({
    super.key,
    required this.selectedSection,
    required this.onSectionSelected,
  });

  final AppSection selectedSection;
  final ValueChanged<AppSection> onSectionSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return NavigationDrawer(
      selectedIndex: AppSection.values.indexOf(selectedSection),
      onDestinationSelected: (index) {
        onSectionSelected(AppSection.values[index]);
        Navigator.of(context).pop();
      },
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 28, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.savings_outlined,
                size: 40,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 12),
              Text(
                '我的资产',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '个人资产管理',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(28, 0, 28, 8),
          child: Divider(),
        ),
        ...AppSection.values.map(
          (section) => NavigationDrawerDestination(
            icon: Icon(section.icon),
            selectedIcon: Icon(section.icon),
            label: Text(section.label),
          ),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(28, 16, 28, 8),
          child: Divider(),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
          child: Text(
            '更多功能',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        ListTile(
          leading: Icon(
            Icons.insights_outlined,
            color: theme.colorScheme.outline,
          ),
          title: Text(
            '数据分析',
            style: TextStyle(color: theme.colorScheme.outline),
          ),
          subtitle: const Text('敬请期待'),
          enabled: false,
        ),
        ListTile(
          leading: Icon(
            Icons.cloud_upload_outlined,
            color: theme.colorScheme.primary,
          ),
          title: const Text('备份与恢复'),
          subtitle: const Text('在设置页导出 / 导入 JSON'),
          onTap: () {
            Navigator.of(context).pop();
            onSectionSelected(AppSection.settings);
          },
        ),
      ],
    );
  }
}
