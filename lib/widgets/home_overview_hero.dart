import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/currency_formatter.dart';
import 'desktop_window_caption.dart';

/// 首页顶部：导航 + 净资产汇总在同一渐变块内，仅底部圆角。
class HomeOverviewHero extends StatelessWidget {
  const HomeOverviewHero({
    super.key,
    required this.netWorth,
    required this.totalAssets,
    required this.totalLiabilities,
    required this.onOpenDrawer,
  });

  final double netWorth;
  final double totalAssets;
  final double totalLiabilities;
  final VoidCallback onOpenDrawer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(4, 0, 0, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primary.withValues(alpha: 0.92),
            colorScheme.primary,
            colorScheme.primaryContainer.withValues(alpha: 0.95),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(AppRadii.xl),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.18),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DesktopDragHeader(
            captionIconColor: colorScheme.onPrimary,
            captionHoverColor: colorScheme.onPrimary.withValues(alpha: 0.12),
            child: SizedBox(
              height: kToolbarHeight,
              child: Row(
                children: [
                  IconButton(
                    tooltip: '打开导航菜单',
                    onPressed: onOpenDrawer,
                    icon: Icon(
                      Icons.menu_rounded,
                      color: colorScheme.onPrimary,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '资产总览',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '净资产',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.onPrimary.withValues(alpha: 0.88),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  CurrencyFormatter.format(netWorth),
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _SummaryMetric(
                        label: '总资产',
                        value: CurrencyFormatter.format(totalAssets),
                        valueColor: colorScheme.onPrimary,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: colorScheme.onPrimary.withValues(alpha: 0.24),
                    ),
                    Expanded(
                      child: _SummaryMetric(
                        label: '总负债',
                        value: CurrencyFormatter.format(totalLiabilities),
                        valueColor: colorScheme.onPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: valueColor.withValues(alpha: 0.78),
                ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: valueColor,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
