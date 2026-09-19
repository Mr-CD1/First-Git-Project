import 'package:flutter/material.dart';

import '../models/bank_institution.dart';

class BankInstitutionUi {
  BankInstitutionUi._();

  static String abbreviationFor(BankInstitution bank) {
    return switch (bank) {
      BankInstitution.icbc => '工行',
      BankInstitution.abc => '农行',
      BankInstitution.boc => '中行',
      BankInstitution.ccb => '建行',
      BankInstitution.cmb => '招行',
      BankInstitution.psbc => '邮储',
      BankInstitution.cib => '兴业',
      BankInstitution.spdb => '浦发',
      BankInstitution.cmbc => '民生',
      BankInstitution.citic => '中信',
      BankInstitution.ceb => '光大',
      BankInstitution.hxb => '华夏',
      BankInstitution.bob => '北银',
      BankInstitution.other => '其他',
    };
  }

  static String shortLabelFor(BankInstitution bank) {
    return switch (bank) {
      BankInstitution.icbc => '工商银行',
      BankInstitution.abc => '农业银行',
      BankInstitution.boc => '中国银行',
      BankInstitution.ccb => '建设银行',
      BankInstitution.cmb => '招商银行',
      BankInstitution.psbc => '邮储银行',
      BankInstitution.cib => '兴业银行',
      BankInstitution.spdb => '浦发银行',
      BankInstitution.cmbc => '民生银行',
      BankInstitution.citic => '中信银行',
      BankInstitution.ceb => '光大银行',
      BankInstitution.hxb => '华夏银行',
      BankInstitution.bob => '北京银行',
      BankInstitution.other => '其他银行',
    };
  }

  static Color colorFor(BankInstitution bank) {
    return switch (bank) {
      BankInstitution.icbc => const Color(0xFFC7000B),
      BankInstitution.abc => const Color(0xFF009174),
      BankInstitution.boc => const Color(0xFFB81C22),
      BankInstitution.ccb => const Color(0xFF003DA6),
      BankInstitution.cmb => const Color(0xFFC50030),
      BankInstitution.psbc => const Color(0xFF007A42),
      BankInstitution.cib => const Color(0xFF004098),
      BankInstitution.spdb => const Color(0xFF003A8C),
      BankInstitution.cmbc => const Color(0xFF00843D),
      BankInstitution.citic => const Color(0xFFE60012),
      BankInstitution.ceb => const Color(0xFF6B2D8E),
      BankInstitution.hxb => const Color(0xFFDA0024),
      BankInstitution.bob => const Color(0xFFE60012),
      BankInstitution.other => const Color(0xFF8C8C8C),
    };
  }

  static IconData iconFor(BankInstitution bank) {
    if (bank == BankInstitution.other) {
      return Icons.account_balance_outlined;
    }
    return Icons.account_balance;
  }

  /// SVG logo path from icongo/bank-logos (MIT License).
  static String? assetPathFor(BankInstitution bank) {
    if (bank == BankInstitution.other) {
      return null;
    }
    return 'assets/banks/${bank.name}.svg';
  }
}
