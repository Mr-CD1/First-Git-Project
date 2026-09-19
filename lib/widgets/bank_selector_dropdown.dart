import 'package:flutter/material.dart';

import '../models/bank_institution.dart';
import '../theme/app_theme.dart';
import '../utils/bank_institution_ui.dart';
import 'bank_icon.dart';

/// 在当前页面内联展开的可滚动银行列表，不使用全屏路由菜单。
class BankSelectorDropdown extends StatefulWidget {
  const BankSelectorDropdown({
    super.key,
    required this.selectedBank,
    required this.onSelected,
  });

  final BankInstitution? selectedBank;
  final ValueChanged<BankInstitution> onSelected;

  @override
  State<BankSelectorDropdown> createState() => _BankSelectorDropdownState();
}

class _BankSelectorDropdownState extends State<BankSelectorDropdown> {
  static const _panelMaxHeight = 220.0;

  bool _expanded = false;

  void _toggleExpanded() {
    setState(() => _expanded = !_expanded);
  }

  void _selectBank(BankInstitution bank) {
    widget.onSelected(bank);
    setState(() => _expanded = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Material(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
          borderRadius: AppRadii.lgBorder,
          child: InkWell(
            borderRadius: AppRadii.lgBorder,
            onTap: _toggleExpanded,
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: '选择银行',
                hintText: '请选择银行',
                suffixIcon: Icon(
                  _expanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: AppRadii.lgBorder,
                  borderSide: BorderSide(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.35),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: AppRadii.lgBorder,
                  borderSide: BorderSide(
                    color: colorScheme.primary,
                    width: 1.5,
                  ),
                ),
              ),
              isEmpty: widget.selectedBank == null,
              child: widget.selectedBank == null
                  ? Text(
                      '请选择银行',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    )
                  : _BankOptionRow(
                      bank: widget.selectedBank!,
                      iconSize: 28,
                      compact: true,
                    ),
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Material(
              elevation: 1,
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
              borderRadius: AppRadii.mdBorder,
              clipBehavior: Clip.antiAlias,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: _panelMaxHeight),
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  itemCount: BankInstitution.values.length,
                  separatorBuilder: (_, __) => Divider(
                    height: 1,
                    color: colorScheme.outlineVariant.withValues(alpha: 0.2),
                  ),
                  itemBuilder: (context, index) {
                    final bank = BankInstitution.values[index];
                    final selected = bank == widget.selectedBank;

                    return InkWell(
                      onTap: () => _selectBank(bank),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: _BankOptionRow(
                                bank: bank,
                                iconSize: 30,
                                compact: true,
                              ),
                            ),
                            if (selected)
                              Icon(
                                Icons.check_rounded,
                                size: 20,
                                color: colorScheme.primary,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          crossFadeState: _expanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 180),
          sizeCurve: Curves.easeOut,
        ),
      ],
    );
  }
}

class _BankOptionRow extends StatelessWidget {
  const _BankOptionRow({
    required this.bank,
    this.iconSize = 32,
    this.compact = false,
  });

  final BankInstitution bank;
  final double iconSize;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        BankIcon(bank: bank, size: iconSize),
        SizedBox(width: compact ? 10 : 12),
        Expanded(
          child: Text(
            BankInstitutionUi.shortLabelFor(bank),
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: compact ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
