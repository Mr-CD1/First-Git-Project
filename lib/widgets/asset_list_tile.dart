import 'package:flutter/material.dart';

import '../models/account_category.dart';
import '../models/asset_account.dart';
import '../models/asset_type.dart';
import '../utils/asset_type_ui.dart';
import '../utils/currency_formatter.dart';
import 'asset_type_icon.dart';
import 'bank_icon.dart';

class AssetListTile extends StatelessWidget {
  const AssetListTile({
    super.key,
    required this.account,
    this.onTap,
  });

  final AssetAccount account;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final typeColor = AssetTypeUi.colorFor(account.type);
    final isLiability = account.category == AccountCategory.liability;
    final subtitle = _buildSubtitle();

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              _AccountAvatar(account: account, fallbackColor: typeColor),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      account.displayName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                isLiability
                    ? '-${CurrencyFormatter.format(account.balance)}'
                    : CurrencyFormatter.format(account.balance),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isLiability
                      ? theme.colorScheme.error
                      : theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _buildSubtitle() {
    final subtitle = account.subtitle;
    if (subtitle == null || subtitle == account.displayName) {
      return account.type.label;
    }
    return '${account.type.label} · $subtitle';
  }
}

class _AccountAvatar extends StatelessWidget {
  const _AccountAvatar({
    required this.account,
    required this.fallbackColor,
  });

  final AssetAccount account;
  final Color fallbackColor;

  static const _avatarSize = 44.0;

  @override
  Widget build(BuildContext context) {
    if (account.type == AssetType.bankCard && account.bank != null) {
      return BankIcon(
        bank: account.bank!,
        size: _avatarSize,
      );
    }

    if (AssetTypeUi.assetPathFor(account.type) != null) {
      return AssetTypeIcon(
        type: account.type,
        size: _avatarSize,
      );
    }

    return CircleAvatar(
      radius: _avatarSize / 2,
      backgroundColor: fallbackColor.withValues(alpha: 0.14),
      child: Icon(
        AssetTypeUi.iconFor(account.type),
        color: fallbackColor,
      ),
    );
  }
}
