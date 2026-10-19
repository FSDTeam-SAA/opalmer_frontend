import 'package:flutter/material.dart';
import '../constants/api_constants.dart';

class DataImage extends StatelessWidget {
  final String? url;
  final double width;
  final double height;
  const DataImage({super.key, this.url, required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    final source = ApiConstants.buildImageUrl(url);
    final empty = SizedBox(width: width, height: height,
      child: const ColoredBox(color: Color(0xFFF3F4F6), child: Icon(Icons.image_not_supported_outlined, color: Colors.grey)));
    return source.isEmpty ? empty : Image.network(source, width: width, height: height,
      fit: BoxFit.cover, errorBuilder: (_, _, _) => empty);
  }
}
