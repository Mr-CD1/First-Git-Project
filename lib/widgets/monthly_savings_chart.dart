import 'package:flutter/material.dart';

import '../models/monthly_chart_item.dart';
import '../theme/app_theme.dart';
import '../utils/currency_formatter.dart';

class MonthlySavingsChart extends StatelessWidget {
  const MonthlySavingsChart({
    super.key,
    required this.items,
    this.maxBars = 12,
  });

  final List<MonthlyChartItem> items;
  final int maxBars;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const _EmptyChart();
    }

    final theme = Theme.of(context);
    final visibleItems = items.length <= maxBars
        ? items
        : items.sublist(items.length - maxBars);
    final maxAbs = visibleItems
        .map((item) => item.savings.abs())
        .fold<double>(0, (max, value) => value > max ? value : max);
    final chartMax = maxAbs == 0 ? 1.0 : maxAbs;

    return Container(
      height: 280,
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
      decoration: AppTheme.softPanel(theme.colorScheme),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '每月留存（柱状图）',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: visibleItems.map((item) {
                return Expanded(
                  child: _BarColumn(
                    item: item,
                    chartMax: chartMax,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _BarColumn extends StatelessWidget {
  const _BarColumn({
    required this.item,
    required this.chartMax,
  });

  final MonthlyChartItem item;
  final double chartMax;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPositive = item.savings >= 0;
    final color = isPositive ? Colors.green.shade600 : theme.colorScheme.error;
    final ratio = (item.savings.abs() / chartMax).clamp(0.05, 1.0);
    const maxBarHeight = 140.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            _compactAmount(item.savings),
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            height: maxBarHeight * ratio,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.85),
              borderRadius: AppRadii.smBorder,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  String _compactAmount(double amount) {
    final abs = amount.abs();
    final prefix = amount >= 0 ? '+' : '-';
    if (abs >= 10000) {
      return '$prefix${(abs / 10000).toStringAsFixed(1)}w';
    }
    if (abs >= 1000) {
      return '$prefix${(abs / 1000).toStringAsFixed(1)}k';
    }
    return '$prefix${abs.toStringAsFixed(0)}';
  }
}

class _EmptyChart extends StatelessWidget {
  const _EmptyChart();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 220,
      padding: const EdgeInsets.all(24),
      decoration: AppTheme.softPanel(theme.colorScheme),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bar_chart_outlined,
            size: 48,
            color: theme.colorScheme.outline,
          ),
          const SizedBox(height: 12),
          Text(
            '暂无留存数据',
            style: theme.textTheme.titleSmall,
          ),
          const SizedBox(height: 4),
          Text(
            '至少记录两个月资产后可看到柱状图',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class MonthlySavingsLegend extends StatelessWidget {
  const MonthlySavingsLegend({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _LegendDot(color: Colors.green.shade600, label: '留存增加'),
        const SizedBox(width: 20),
        _LegendDot(color: theme.colorScheme.error, label: '留存减少'),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({
    required this.color,
    required this.label,
  });

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class MonthlySavingsDetailList extends StatelessWidget {
  const MonthlySavingsDetailList({
    super.key,
    required this.items,
  });

  final List<MonthlyChartItem> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final reversed = items.reversed.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '明细',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        ...reversed.map((item) {
          final isPositive = item.savings >= 0;
          return Card(
            elevation: 0,
            margin: const EdgeInsets.symmetric(vertical: 4),
            color: theme.colorScheme.surfaceContainerHighest
                .withValues(alpha: 0.35),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: (isPositive
                        ? Colors.green.shade600
                        : theme.colorScheme.error)
                    .withValues(alpha: 0.15),
                child: Icon(
                  isPositive ? Icons.trending_up : Icons.trending_down,
                  color: isPositive
                      ? Colors.green.shade700
                      : theme.colorScheme.error,
                ),
              ),
              title: Text(item.fullLabel),
              subtitle: Text(
                '净资产 ${CurrencyFormatter.format(item.snapshot.netWorth)}',
              ),
              trailing: Text(
                isPositive
                    ? '+${CurrencyFormatter.format(item.savings)}'
                    : '-${CurrencyFormatter.format(item.savings.abs())}',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isPositive
                      ? Colors.green.shade700
                      : theme.colorScheme.error,
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
