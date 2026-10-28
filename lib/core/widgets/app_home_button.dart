import 'package:flutter/material.dart';
import '../navigation/role_navigation.dart';

/// An action in the page's own header, never an extra navigation bar.
class AppHomeButton extends StatelessWidget {
  final Color? color;
  const AppHomeButton({super.key, this.color});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: roleNavigation.changed,
      builder: (_, _, _) {
        if (!roleNavigation.available) {
          return const SizedBox.shrink();
        }
        return IconButton(
          tooltip: 'Home',
          onPressed: roleNavigation.goHome,
          color: color,
          icon: const Icon(Icons.home_outlined),
        );
      },
    );
  }
}

/// Adds the same action to custom page headers while keeping titles flexible.
class AppPageHeader extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisSize mainAxisSize;
  final Color? homeColor;
  const AppPageHeader({
    super.key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisSize = MainAxisSize.max,
    this.homeColor,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: roleNavigation.changed,
      builder: (_, _, _) {
        final show = roleNavigation.available;
        final items = [...children];
        if (show) {
          if (!items.any((w) => w is Flexible || w is Spacer)) {
            final index = items.indexWhere((w) => w is Text || w is Row);
            if (index >= 0) {
              final title = items[index];
              items[index] = Expanded(
                child: title is Row
                    ? Row(
                        children: title.children
                            .map((w) => w is Text ? Flexible(child: w) : w)
                            .toList(),
                      )
                    : title,
              );
            } else {
              items.add(const Spacer());
            }
          }
          items.add(AppHomeButton(color: homeColor));
        }
        return Row(
          mainAxisAlignment: mainAxisAlignment,
          crossAxisAlignment: crossAxisAlignment,
          mainAxisSize: mainAxisSize,
          children: items,
        );
      },
    );
  }
}
