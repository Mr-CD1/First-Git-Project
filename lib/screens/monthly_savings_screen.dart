import 'package:flutter/material.dart';

import '../models/app_data.dart';
import '../theme/app_theme.dart';
import '../widgets/monthly_savings_chart.dart';

class MonthlySavingsScreen extends StatelessWidget {
  const MonthlySavingsScreen({
    super.key,
    required this.appData,
  });

  final AppData appData;

  @override
  Widget build(BuildContext context) {
    final items = appData.monthlyChartItems;
    final totalSavings =
        items.fold<double>(0, (sum, item) => sum + item.savings);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        if (items.isNotEmpty) ...[
          _SummaryCards(
            monthCount: items.length,
            totalSavings: totalSavings,
            latestSavings: items.last.savings,
          ),
          const SizedBox(height: 16),
        ],
        MonthlySavingsChart(items: items),
        const SizedBox(height: 12),
        const MonthlySavingsLegend(),
        const SizedBox(height: 20),
        MonthlySavingsDetailList(items: items),
      ],
    );
  }
}

class _SummaryCards extends StatelessWidget {
  const _SummaryCards({
    required this.monthCount,
    required this.totalSavings,
    required this.latestSavings,
  });

  final int monthCount;
  final double totalSavings;
  final double latestSavings;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MiniStatCard(
            label: '统计月数',
            value: '$monthCount',
            icon: Icons.date_range_outlined,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _MiniStatCard(
            label: '累计留存',
            value: _formatSigned(totalSavings),
            icon: Icons.savings_outlined,
            valueColor: totalSavings >= 0
                ? Colors.green.shade700
                : Theme.of(context).colorScheme.error,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _MiniStatCard(
            label: '最近一月',
            value: _formatSigned(latestSavings),
            icon: Icons.show_chart,
            valueColor: latestSavings >= 0
                ? Colors.green.shade700
                : Theme.of(context).colorScheme.error,
          ),
        ),
      ],
    );
  }

  String _formatSigned(double value) {
    if (value > 0) {
      return '+${value.toStringAsFixed(0)}';
    }
    if (value < 0) {
      return value.toStringAsFixed(0);
    }
    return '0';
  }
}

class _MiniStatCard extends StatelessWidget {
  const _MiniStatCard({
    required this.label,
    required this.value,
    required this.icon,
    this.valueColor,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: AppTheme.softPanelPrimary(theme.colorScheme),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(height: 8),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
