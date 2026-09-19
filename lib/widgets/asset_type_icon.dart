import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../models/asset_type.dart';
import '../utils/asset_type_ui.dart';

class AssetTypeIcon extends StatelessWidget {
  const AssetTypeIcon({
    super.key,
    required this.type,
    this.size = 48,
    this.selected = false,
  });

  final AssetType type;
  final double size;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final color = AssetTypeUi.colorFor(type);
    final assetPath = AssetTypeUi.assetPathFor(type);

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
      padding: EdgeInsets.all(size * 0.12),
      child: assetPath == null
          ? Icon(
              AssetTypeUi.iconFor(type),
              color: color,
              size: size * 0.48,
            )
          : ClipOval(
              child: _buildAsset(assetPath),
            ),
    );
  }

  Widget _buildAsset(String assetPath) {
    if (assetPath.endsWith('.svg')) {
      return SvgPicture.asset(
        assetPath,
        fit: BoxFit.contain,
        semanticsLabel: type.label,
      );
    }

    return Image.asset(
      assetPath,
      fit: BoxFit.contain,
      semanticLabel: type.label,
    );
  }
}
