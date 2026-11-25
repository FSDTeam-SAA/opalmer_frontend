import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Layout breakpoints and helpers for adapting phone layouts to tablets
/// (iPad, Android tablets) in both orientations.
///
/// Phones keep their original layout: every helper here is a no-op when the
/// available width is at or below the relevant max width.
abstract final class Responsive {
  /// Devices whose shortest side is at least this are treated as tablets.
  static const double tabletShortestSide = 600;

  /// Readable width for regular pages (lists, details, settings).
  static const double pageMaxWidth = 800;

  /// Width for dashboards that lay cards out in a grid.
  static const double dashboardMaxWidth = 1100;

  /// Width for focused flows such as sign-in, OTP and short forms.
  static const double formMaxWidth = 540;

  static bool isTablet(BuildContext context) =>
      MediaQuery.sizeOf(context).shortestSide >= tabletShortestSide;

  static bool isLandscape(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return size.width > size.height;
  }

  /// Horizontal padding that keeps content inside [maxWidth] while letting the
  /// scroll view itself span the full screen width.
  static double gutter(
    BuildContext context, {
    double maxWidth = pageMaxWidth,
    double base = 20,
  }) => gutterFor(
    MediaQuery.sizeOf(context).width,
    maxWidth: maxWidth,
    base: base,
  );

  static double gutterFor(
    double width, {
    double maxWidth = pageMaxWidth,
    double base = 20,
  }) {
    final extra = (width - maxWidth) / 2;
    return extra > 0 ? base + extra : base;
  }

  /// Number of grid columns for tiles that should be at least [minTileWidth]
  /// wide, clamped to [maxColumns].
  static int columns(
    double width, {
    double minTileWidth = 340,
    int maxColumns = 3,
    double spacing = 16,
  }) {
    final count = ((width + spacing) / (minTileWidth + spacing)).floor();
    return count.clamp(1, maxColumns);
  }
}

/// Centers [child] and caps its width on wide screens. On narrow screens the
/// child is returned unchanged, so phone layouts are untouched.
///
/// Use it for `Scaffold.body` or any full-width block.
class ResponsiveBody extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const ResponsiveBody({
    super.key,
    required this.child,
    this.maxWidth = Responsive.pageMaxWidth,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (!constraints.hasBoundedWidth || constraints.maxWidth <= maxWidth) {
          return child;
        }
        return Align(
          alignment: Alignment.topCenter,
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: maxWidth,
              maxWidth: maxWidth,
              maxHeight: constraints.maxHeight,
            ),
            child: child,
          ),
        );
      },
    );
  }
}

/// A decorative header image that fills the screen width.
///
/// On phones it behaves like `Image.asset(fit: BoxFit.fitWidth)`. On wide
/// screens the natural height would become very large, so the height is
/// capped at [maxHeight] and the artwork is stretched horizontally to fit.
/// Cropping is avoided on purpose: these header graphics are not uniform, and
/// a crop can leave white text over a light area.
class ResponsiveHeaderImage extends StatelessWidget {
  final String asset;

  /// Width divided by height of the source image.
  final double aspectRatio;
  final double maxHeight;

  const ResponsiveHeaderImage({
    super.key,
    required this.asset,
    required this.aspectRatio,
    this.maxHeight = 340,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final naturalHeight = width / aspectRatio;
        if (naturalHeight <= maxHeight) {
          return Image.asset(
            asset,
            width: double.infinity,
            fit: BoxFit.fitWidth,
          );
        }
        return SizedBox(
          width: double.infinity,
          height: maxHeight,
          child: Image.asset(asset, fit: BoxFit.fill),
        );
      },
    );
  }
}

/// Lays [children] out in rows of equal-width columns. Falls back to a plain
/// column when only one column fits, so it can replace a vertical list of
/// cards without changing the phone layout.
class ResponsiveWrapGrid extends StatelessWidget {
  final List<Widget> children;
  final double minTileWidth;
  final int maxColumns;
  final double spacing;
  final double runSpacing;

  const ResponsiveWrapGrid({
    super.key,
    required this.children,
    this.minTileWidth = 340,
    this.maxColumns = 3,
    this.spacing = 16,
    this.runSpacing = 16,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = Responsive.columns(
          width,
          minTileWidth: minTileWidth,
          maxColumns: maxColumns,
          spacing: spacing,
        );
        if (columns <= 1) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0) SizedBox(height: runSpacing),
                children[i],
              ],
            ],
          );
        }
        final rows = <Widget>[];
        for (var start = 0; start < children.length; start += columns) {
          final end = math.min(start + columns, children.length);
          rows.add(
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = start; i < start + columns; i++) ...[
                  if (i > start) SizedBox(width: spacing),
                  Expanded(
                    child: i < end ? children[i] : const SizedBox.shrink(),
                  ),
                ],
              ],
            ),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < rows.length; i++) ...[
              if (i > 0) SizedBox(height: runSpacing),
              rows[i],
            ],
          ],
        );
      },
    );
  }
}
