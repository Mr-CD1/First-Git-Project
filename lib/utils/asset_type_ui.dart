import 'package:flutter/material.dart';

import '../models/asset_type.dart';

class AssetTypeUi {
  AssetTypeUi._();

  static IconData iconFor(AssetType type) {
    return switch (type) {
      AssetType.wechat => Icons.chat_bubble_outline,
      AssetType.alipay => Icons.account_balance_wallet_outlined,
      AssetType.bankCard => Icons.credit_card,
      AssetType.cash => Icons.payments_outlined,
      AssetType.huabei => Icons.receipt_long_outlined,
      AssetType.other => Icons.more_horiz,
    };
  }

  static Color colorFor(AssetType type) {
    return switch (type) {
      AssetType.wechat => const Color(0xFF07C160),
      AssetType.alipay => const Color(0xFF1677FF),
      AssetType.bankCard => const Color(0xFFFF8F1F),
      AssetType.cash => const Color(0xFF13C2C2),
      AssetType.huabei => const Color(0xFF1677FF),
      AssetType.other => const Color(0xFF8C8C8C),
    };
  }

  /// Brand logo assets. Huabei/Alipay from Alipay official design pack.
  static String? assetPathFor(AssetType type) {
    return switch (type) {
      AssetType.wechat => 'assets/payment/wechat.svg',
      AssetType.alipay => 'assets/payment/alipay.png',
      AssetType.huabei => 'assets/payment/huabei.png',
      _ => null,
    };
  }
}
