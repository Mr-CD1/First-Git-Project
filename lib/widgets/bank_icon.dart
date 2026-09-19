import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../models/bank_institution.dart';
import '../utils/bank_institution_ui.dart';

class BankIcon extends StatelessWidget {
  const BankIcon({
    super.key,
    required this.bank,
    this.size = 48,
    this.selected = false,
  });

  final BankInstitution bank;
  final double size;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final color = BankInstitutionUi.colorFor(bank);
    final assetPath = BankInstitutionUi.assetPathFor(bank);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: selected ? color.withValues(alpha: 0.12) : Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: selected ? 0.22 : 0.1),
            blurRadius: selected ? 12 : 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: EdgeInsets.all(size * 0.1),
      child: assetPath != null
          ? ClipOval(
              child: SvgPicture.asset(
                assetPath,
                fit: BoxFit.contain,
                semanticsLabel: BankInstitutionUi.shortLabelFor(bank),
              ),
            )
          : Center(
              child: Icon(
                BankInstitutionUi.iconFor(bank),
                color: color,
                size: size * 0.42,
              ),
            ),
    );
  }
}
