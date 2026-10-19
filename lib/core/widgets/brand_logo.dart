import 'package:flutter/material.dart';

class BrandLogo extends StatelessWidget {
  final double size;
  const BrandLogo({super.key, this.size = 160});
  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: BoxConstraints(maxWidth: size, maxHeight: size),
    child: Image.asset(
      'assets/images/achieverplus-logo.png',
      fit: BoxFit.contain,
      semanticLabel: 'AchieverPlus logo',
    ),
  );
}
