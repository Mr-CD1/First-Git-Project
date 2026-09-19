import 'package:flutter/material.dart';

import '../models/app_data.dart';
import '../models/monthly_snapshot.dart';
import '../utils/currency_formatter.dart';
import '../theme/app_theme.dart';
import '../utils/date_formatter.dart';

class MonthlySavingsCard extends StatelessWidget {
  const MonthlySavingsCard({
    super.key,
    required this.appData,
    required this.onRecord,
    this.onOpenChart,
  });

  final AppData appData;
  final VoidCallback onRecord;
  final VoidCallback? onOpenChart;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentSnapshot = appData.currentMonthSnapshot;
    final savings = appData.currentMonthSavings;
    final history = appData.sortedMonthlySnapshots.reversed.take(6).toList();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.softPanel(theme.colorScheme),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '每月记账',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (onOpenChart != null)
                IconButton(
                  tooltip: '查看留存图表',
                  onPressed: onOpenChart,
                  icon: const Icon(Icons.bar_chart_rounded),
                ),
            ],
          ),
          if (appData.shouldShowInAppReminder) ...[
            const SizedBox(height: 8),
            _ReminderBanner(
              reminderDay: appData.settings.safeReminderDay,
            ),
          ],
          const SizedBox(height: 12),
          if (currentSnapshot == null) ...[
            Text(
              '本月尚未记录资产快照',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.tonalIcon(
              onPressed: onRecord,
              icon: const Icon(Icons.save_alt),
              label: const Text('记录本月资产'),
            ),
          ] else ...[
            _CurrentMonthSummary(
              snapshot: currentSnapshot,
              savings: savings,
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: onRecord,
              icon: const Icon(Icons.refresh),
              label: const Text('更新本月记录'),
            ),
          ],
          if (history.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              '历史留存',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            ...history.map(
              (snapshot) => _HistoryRow(snapshot: snapshot, appData: appData),
            ),
          ],
        ],
      ),
    );
  }
}

class _ReminderBanner extends StatelessWidget {
  const _ReminderBanner({required this.reminderDay});

  final int reminderDay;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.55),
        borderRadius: AppRadii.smBorder,
      ),
      child: Row(
        children: [
          Icon(
            Icons.event_available_outlined,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '已到每月 $reminderDay 号，记得记录一次资产哦',
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _CurrentMonthSummary extends StatelessWidget {
  const _CurrentMonthSummary({
    required this.snapshot,
    required this.savings,
  });

  final MonthlySnapshot snapshot;
  final double? savings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '本月净资产 ${CurrencyFormatter.format(snapshot.netWorth)}',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '记录于 ${DateFormatter.formatDateTime(snapshot.recordedAt)}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        if (savings != null) ...[
          const SizedBox(height: 8),
          Text(
            '较上月 ${_formatSavings(savings!)}',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: savings! >= 0 ? Colors.green.shade700 : theme.colorScheme.error,
            ),
          ),
        ] else ...[
          const SizedBox(height: 8),
          Text(
            '这是第一条月度记录，下月可看到留存金额',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }

  String _formatSavings(double savings) {
    if (savings > 0) {
      return '+${CurrencyFormatter.format(savings)}';
    }
    if (savings < 0) {
      return '-${CurrencyFormatter.format(savings.abs())}';
    }
    return CurrencyFormatter.format(0);
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({
    required this.snapshot,
    required this.appData,
  });

  final MonthlySnapshot snapshot;
  final AppData appData;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final savings = MonthlySnapshot.savingsFor(snapshot, appData.monthlySnapshots);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              snapshot.monthLabel,
              style: theme.textTheme.bodyMedium,
            ),
          ),
          Text(
            CurrencyFormatter.format(snapshot.netWorth),
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 96,
            child: Text(
              savings == null ? '--' : _formatSavings(savings),
              textAlign: TextAlign.right,
              style: theme.textTheme.bodySmall?.copyWith(
                color: savings == null
                    ? theme.colorScheme.onSurfaceVariant
                    : (savings >= 0
                        ? Colors.green.shade700
                        : theme.colorScheme.error),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatSavings(double savings) {
    if (savings > 0) {
      return '+${CurrencyFormatter.format(savings)}';
    }
    if (savings < 0) {
      return '-${CurrencyFormatter.format(savings.abs())}';
    }
    return CurrencyFormatter.format(0);
  }
}
