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
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? color : color.withValues(alpha: 0.25),
          width: selected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: selected ? 0.18 : 0.08),
            blurRadius: selected ? 8 : 4,
            offset: const Offset(0, 2),
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
