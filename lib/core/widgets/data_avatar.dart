import 'package:flutter/material.dart';
import '../constants/api_constants.dart';

/// A user photo must come from the API. Missing/broken photos use a neutral icon.
class DataAvatar extends StatelessWidget {
  final String? url;
  final double radius;
  const DataAvatar({super.key, this.url, this.radius = 20});

  @override
  Widget build(BuildContext context) {
    final resolved = ApiConstants.buildImageUrl(url);
    const icon = Icon(Icons.person_outline, color: Color(0xFF871DAD));
    return ClipOval(child: SizedBox(
      width: radius * 2, height: radius * 2,
      child: ColoredBox(color: const Color(0xFFF3F4F6), child: resolved.isEmpty
        ? icon
        : Image.network(resolved, fit: BoxFit.cover, errorBuilder: (_, _, _) => icon)),
    ));
  }
}
