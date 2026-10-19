import 'package:flutter/material.dart';

class BrandLogo extends StatelessWidget {
  final double size;
  final String assetPath;
  const BrandLogo({
    super.key,
    this.size = 160,
    this.assetPath = 'assets/images/achieverplus-logo.png',
  });
  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: BoxConstraints(maxWidth: size, maxHeight: size),
    child: Image.asset(
      assetPath,
      fit: BoxFit.contain,
      semanticLabel: 'AchieverPlus logo',
    ),
  );
}
