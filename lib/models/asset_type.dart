import 'account_category.dart';

enum AssetType {
  wechat('微信', AccountCategory.asset),
  alipay('支付宝', AccountCategory.asset),
  bankCard('银行卡', AccountCategory.asset),
  cash('现金', AccountCategory.asset),
  providentFund('公积金', AccountCategory.asset),
  huabei('花呗', AccountCategory.liability),
  other('其他', AccountCategory.asset);

  const AssetType(this.label, this.defaultCategory);

  final String label;
  final AccountCategory defaultCategory;

  bool get requiresBank => this == AssetType.bankCard;
}
