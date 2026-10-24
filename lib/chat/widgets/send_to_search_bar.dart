import 'package:flutter/material.dart';

class SendToSearchBar extends StatelessWidget {
  final ValueChanged<String>? onChanged;
  const SendToSearchBar({super.key, this.onChanged});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
    child: TextField(
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      decoration: const InputDecoration(
        prefixIcon: Icon(Icons.search_rounded, size: 21),
        hintText: 'Search contacts',
      ),
    ),
  );
}
