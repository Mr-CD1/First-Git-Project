import 'account_category.dart';
import 'asset_type.dart';
import 'bank_institution.dart';

class AssetAccount {
  const AssetAccount({
    required this.id,
    required this.type,
    required this.category,
    required this.name,
    required this.balance,
    required this.createdAt,
    required this.updatedAt,
    this.bank,
    this.customBankName,
    this.note,
  });

  final String id;
  final AssetType type;
  final AccountCategory category;
  final String name;
  final double balance;
  final BankInstitution? bank;
  final String? customBankName;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? note;

  double get signedBalance =>
      category == AccountCategory.liability ? -balance : balance;

  String? get bankDisplayName {
    if (type != AssetType.bankCard || bank == null) {
      return null;
    }
    if (bank == BankInstitution.other &&
        customBankName != null &&
        customBankName!.trim().isNotEmpty) {
      return customBankName!.trim();
    }
    return bank!.label;
  }

  String get displayName {
    if (name.trim().isNotEmpty) {
      return name.trim();
    }

    switch (type) {
      case AssetType.bankCard:
        return bankDisplayName ?? type.label;
      default:
        return type.label;
    }
  }

  String? get subtitle {
    if (type == AssetType.bankCard && bankDisplayName != null) {
      return bankDisplayName;
    }
    if (category == AccountCategory.liability) {
      return category.label;
    }
    return null;
  }

  AssetAccount copyWith({
    AssetType? type,
    AccountCategory? category,
    String? name,
    double? balance,
    BankInstitution? bank,
    String? customBankName,
    DateTime? updatedAt,
    String? note,
    bool clearBank = false,
    bool clearCustomBankName = false,
  }) {
    return AssetAccount(
      id: id,
      type: type ?? this.type,
      category: category ?? this.category,
      name: name ?? this.name,
      balance: balance ?? this.balance,
      bank: clearBank ? null : (bank ?? this.bank),
      customBankName: clearCustomBankName
          ? null
          : (customBankName ?? this.customBankName),
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      note: note ?? this.note,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'category': category.name,
        'name': name,
        'balance': balance,
        'bank': bank?.name,
        'customBankName': customBankName,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'note': note,
      };

  factory AssetAccount.fromJson(Map<String, dynamic> json) {
    final type = AssetType.values.byName(json['type'] as String);

    return AssetAccount(
      id: json['id'] as String,
      type: type,
      category: AccountCategory.values.byName(
        json['category'] as String? ?? type.defaultCategory.name,
      ),
      name: json['name'] as String? ?? '',
      balance: (json['balance'] as num).toDouble(),
      bank: json['bank'] != null
          ? BankInstitution.values.byName(json['bank'] as String)
          : null,
      customBankName: json['customBankName'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      note: json['note'] as String?,
    );
  }

  factory AssetAccount.create({
    required String id,
    required AssetType type,
    AccountCategory? category,
    String name = '',
    double balance = 0,
    BankInstitution? bank,
    String? customBankName,
    String? note,
  }) {
    assert(balance >= 0, 'balance 应存非负数');
    if (type.requiresBank) {
      assert(bank != null, '银行卡必须选择银行');
    }

    final now = DateTime.now();
    return AssetAccount(
      id: id,
      type: type,
      category: category ?? type.defaultCategory,
      name: name,
      balance: balance,
      bank: bank,
      customBankName: customBankName,
      createdAt: now,
      updatedAt: now,
      note: note,
    );
  }
}
