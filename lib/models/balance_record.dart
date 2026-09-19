import 'balance_change_type.dart';

class BalanceRecord {
  const BalanceRecord({
    required this.id,
    required this.accountId,
    required this.type,
    required this.previousBalance,
    required this.newBalance,
    required this.createdAt,
    this.note,
  });

  final String id;
  final String accountId;
  final BalanceChangeType type;
  final double previousBalance;
  final double newBalance;
  final DateTime createdAt;
  final String? note;

  double get delta => newBalance - previousBalance;

  Map<String, dynamic> toJson() => {
        'id': id,
        'accountId': accountId,
        'type': type.name,
        'previousBalance': previousBalance,
        'newBalance': newBalance,
        'createdAt': createdAt.toIso8601String(),
        'note': note,
      };

  factory BalanceRecord.fromJson(Map<String, dynamic> json) {
    return BalanceRecord(
      id: json['id'] as String,
      accountId: json['accountId'] as String,
      type: BalanceChangeType.values.byName(json['type'] as String),
      previousBalance: (json['previousBalance'] as num).toDouble(),
      newBalance: (json['newBalance'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      note: json['note'] as String?,
    );
  }

  factory BalanceRecord.create({
    required String id,
    required String accountId,
    required BalanceChangeType type,
    required double previousBalance,
    required double newBalance,
    String? note,
  }) {
    return BalanceRecord(
      id: id,
      accountId: accountId,
      type: type,
      previousBalance: previousBalance,
      newBalance: newBalance,
      createdAt: DateTime.now(),
      note: note,
    );
  }
}
