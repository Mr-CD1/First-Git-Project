enum BankInstitution {
  icbc('中国工商银行'),
  abc('中国农业银行'),
  boc('中国银行'),
  ccb('中国建设银行'),
  cmb('招商银行'),
  psbc('中国邮政储蓄银行'),
  cib('兴业银行'),
  spdb('浦发银行'),
  cmbc('中国民生银行'),
  citic('中信银行'),
  ceb('光大银行'),
  hxb('华夏银行'),
  bob('北京银行'),
  other('其他银行');

  const BankInstitution(this.label);

  final String label;
}
