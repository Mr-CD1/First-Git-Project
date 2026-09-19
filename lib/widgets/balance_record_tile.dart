import 'package:flutter/material.dart';

import '../models/balance_change_type.dart';
import '../models/balance_record.dart';
import '../utils/currency_formatter.dart';
import '../utils/date_formatter.dart';

class BalanceRecordTile extends StatelessWidget {
  const BalanceRecordTile({
    super.key,
    required this.record,
    required this.isLiability,
  });

  final BalanceRecord record;
  final bool isLiability;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCreate = record.type == BalanceChangeType.create;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 6),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.type.label,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _buildDescription(isCreate),
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormatter.formatDateTime(record.createdAt),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (!isCreate)
            Text(
              _formatDelta(record.delta),
              style: theme.textTheme.titleSmall?.copyWith(
                color: _deltaColor(theme, record.delta),
                fontWeight: FontWeight.w700,
              ),
            ),
        ],
      ),
    );
  }

  String _buildDescription(bool isCreate) {
    if (isCreate) {
      final label = isLiability ? '初始欠款' : '初始余额';
      return '$label ${CurrencyFormatter.format(record.newBalance)}';
    }

    return '${CurrencyFormatter.format(record.previousBalance)} → '
        '${CurrencyFormatter.format(record.newBalance)}';
  }

  String _formatDelta(double delta) {
    if (delta > 0) {
      return '+${CurrencyFormatter.format(delta)}';
    }
    if (delta < 0) {
      return '-${CurrencyFormatter.format(delta.abs())}';
    }
    return CurrencyFormatter.format(0);
  }

  Color _deltaColor(ThemeData theme, double delta) {
    if (delta > 0) {
      return isLiability ? theme.colorScheme.error : Colors.green.shade700;
    }
    if (delta < 0) {
      return isLiability ? Colors.green.shade700 : theme.colorScheme.error;
    }
    return theme.colorScheme.onSurfaceVariant;
  }
}
