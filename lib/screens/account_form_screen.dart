import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/account_category.dart';
import '../models/app_data.dart';
import '../models/asset_account.dart';
import '../models/asset_type.dart';
import '../models/bank_institution.dart';
import '../theme/app_theme.dart';
import '../utils/asset_type_ui.dart';
import '../utils/currency_formatter.dart';
import '../widgets/asset_type_icon.dart';
import '../widgets/balance_input_sheet.dart';
import '../widgets/balance_record_tile.dart';
import '../widgets/bank_selector_dropdown.dart';

class AccountFormScreen extends StatefulWidget {
  const AccountFormScreen({
    super.key,
    required this.appData,
    this.accountId,
  });

  final AppData appData;
  final String? accountId;

  bool get isEditing => accountId != null;

  @override
  State<AccountFormScreen> createState() => _AccountFormScreenState();
}

class _AccountFormScreenState extends State<AccountFormScreen> {
  final _nameController = TextEditingController();
  final _customBankController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _uuid = const Uuid();

  late AssetType _selectedType;
  BankInstitution? _selectedBank;
  double _balance = 0;
  AssetAccount? _existingAccount;

  @override
  void initState() {
    super.initState();
    _existingAccount = widget.accountId == null
        ? null
        : widget.appData.store.findById(widget.accountId!);

    if (_existingAccount != null) {
      final account = _existingAccount!;
      _selectedType = account.type;
      _selectedBank = account.bank;
      _balance = account.balance;
      _nameController.text = account.name;
      _customBankController.text = account.customBankName ?? '';
    } else {
      _selectedType = AssetType.wechat;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _customBankController.dispose();
    super.dispose();
  }

  bool get _isLiability =>
      _selectedType.defaultCategory == AccountCategory.liability;

  List<AssetType> get _selectableTypes {
    if (widget.isEditing) {
      return [_selectedType];
    }
    return AssetType.values;
  }

  Future<void> _pickBalance() async {
    final result = await showBalanceInputSheet(
      context: context,
      title: _isLiability ? '输入当前欠款' : '输入当前余额',
      initialValue: _balance,
      isLiability: _isLiability,
    );
    if (result != null) {
      setState(() => _balance = result);
    }
  }

  String? _validateForm() {
    if (_selectedType.requiresBank && _selectedBank == null) {
      return '请选择银行';
    }
    if (_selectedBank == BankInstitution.other &&
        _customBankController.text.trim().isEmpty) {
      return '请输入银行名称';
    }
    if (_balance < 0) {
      return '金额不能为负数';
    }
    return null;
  }

  AssetAccount _buildAccount({required String id}) {
    return AssetAccount.create(
      id: id,
      type: _selectedType,
      name: _nameController.text.trim(),
      balance: _balance,
      bank: _selectedType.requiresBank ? _selectedBank : null,
      customBankName: _selectedBank == BankInstitution.other
          ? _customBankController.text.trim()
          : null,
    );
  }

  void _save() {
    final error = _validateForm();
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
      return;
    }

    final AppData nextData;
    if (widget.isEditing) {
      final updated = _existingAccount!.copyWith(
        name: _nameController.text.trim(),
        balance: _balance,
        bank: _selectedType.requiresBank ? _selectedBank : null,
        customBankName: _selectedBank == BankInstitution.other
            ? _customBankController.text.trim()
            : null,
        clearBank: !_selectedType.requiresBank,
        clearCustomBankName: _selectedBank != BankInstitution.other,
      );
      nextData = widget.appData.updateAccount(updated);
    } else {
      nextData = widget.appData.addAccount(
        _buildAccount(id: _uuid.v4()),
        uuid: _uuid,
      );
    }

    Navigator.of(context).pop(nextData);
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('删除账户'),
          content: Text('确定删除「${_existingAccount!.displayName}」吗？相关记录也会一并删除。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('删除'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      Navigator.of(context).pop(
        widget.appData.removeAccount(widget.accountId!),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final records = widget.isEditing
        ? widget.appData.recordsForAccount(widget.accountId!)
        : const [];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? '编辑账户' : '添加账户'),
        actions: [
          if (widget.isEditing)
            IconButton(
              onPressed: _delete,
              icon: const Icon(Icons.delete_outline),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            _SectionLabel(title: '账户类型'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _selectableTypes.map((type) {
                final selected = _selectedType == type;
                final color = AssetTypeUi.colorFor(type);
                return FilterChip(
                  label: Text(type.label),
                  selected: selected,
                  avatar: AssetTypeUi.assetPathFor(type) != null
                      ? AssetTypeIcon(type: type, size: 24)
                      : Icon(
                          AssetTypeUi.iconFor(type),
                          size: 18,
                          color: selected
                              ? color
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                  onSelected: widget.isEditing
                      ? null
                      : (value) {
                          if (!value) {
                            return;
                          }
                          setState(() {
                            _selectedType = type;
                            if (!type.requiresBank) {
                              _selectedBank = null;
                              _customBankController.clear();
                            }
                          });
                        },
                );
              }).toList(),
            ),
            if (_selectedType.requiresBank) ...[
              const SizedBox(height: 24),
              BankSelectorDropdown(
                selectedBank: _selectedBank,
                onSelected: (bank) => setState(() => _selectedBank = bank),
              ),
              if (_selectedBank == BankInstitution.other) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _customBankController,
                  decoration: const InputDecoration(
                    labelText: '银行名称',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ],
            const SizedBox(height: 24),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: _selectedType.requiresBank ? '账户备注（可选）' : '账户名称（可选）',
                border: const OutlineInputBorder(),
                hintText: '例如：日常微信、工资卡',
              ),
            ),
            const SizedBox(height: 24),
            _SectionLabel(
              title: _isLiability ? '当前欠款' : '当前余额',
            ),
            const SizedBox(height: 8),
            InkWell(
              borderRadius: AppRadii.mdBorder,
              onTap: _pickBalance,
              child: Ink(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                decoration: AppTheme.softPanel(theme.colorScheme),
                child: Row(
                  children: [
                    Icon(
                      Icons.dialpad,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _isLiability
                            ? '欠款 ${CurrencyFormatter.format(_balance)}'
                            : CurrencyFormatter.format(_balance),
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      '点击输入',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (widget.isEditing) ...[
              const SizedBox(height: 32),
              _SectionLabel(title: '变动记录'),
              const SizedBox(height: 8),
              if (records.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    '暂无变动记录',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              else
                ...records.map(
                  (record) => BalanceRecordTile(
                    record: record,
                    isLiability: _isLiability,
                  ),
                ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: FilledButton(
            onPressed: _save,
            child: Text(widget.isEditing ? '保存修改' : '添加账户'),
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
    );
  }
}
