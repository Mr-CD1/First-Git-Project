import 'package:flutter/material.dart';

import '../models/bank_institution.dart';
import '../utils/bank_institution_ui.dart';
import 'bank_icon.dart';

class BankSelectorGrid extends StatelessWidget {
  const BankSelectorGrid({
    super.key,
    required this.selectedBank,
    required this.onSelected,
  });

  final BankInstitution? selectedBank;
  final ValueChanged<BankInstitution> onSelected;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: BankInstitution.values.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 12,
        crossAxisSpacing: 8,
        childAspectRatio: 0.82,
      ),
      itemBuilder: (context, index) {
        final bank = BankInstitution.values[index];
        final selected = bank == selectedBank;

        return _BankSelectorTile(
          bank: bank,
          selected: selected,
          onTap: () => onSelected(bank),
        );
      },
    );
  }
}

class _BankSelectorTile extends StatelessWidget {
  const _BankSelectorTile({
    required this.bank,
    required this.selected,
    required this.onTap,
  });

  final BankInstitution bank;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = BankInstitutionUi.colorFor(bank);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: selected
                ? color.withValues(alpha: 0.08)
                : Colors.transparent,
            border: Border.all(
              color: selected ? color : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              BankIcon(bank: bank, selected: selected),
              const SizedBox(height: 8),
              Text(
                BankInstitutionUi.shortLabelFor(bank),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: selected
                      ? color
                      : theme.colorScheme.onSurfaceVariant,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
