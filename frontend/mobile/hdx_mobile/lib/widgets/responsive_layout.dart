import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Breakpoints shared across web and adaptive layouts.
class AppBreakpoints {
  /// Matches marketing pages (`MarketingSection.wideBreakpoint`).
  static const double wide = 768;

  /// Max content width on wide native screens (tablets). Same 800px column
  /// the web layout uses (`AdaptiveScreen`, `test_result_screen.dart`).
  static const double contentMaxWidth = 800;

  /// Routes that intentionally use full browser width on web.
  static bool isFullWidthWebRoute(String path) {
    if (path == '/' || path == '/about') return true;
    return false;
  }

  /// Grid columns for home quick-action tiles (each row fills available width).
  ///
  /// Caps columns so tiles stay wide enough for long German labels (e.g.
  /// Benachrichtigungen) on a single line at 16px.
  static int quickActionCrossAxisCount(
    double width,
    int itemCount, {
    double spacing = 20,
    double minTileWidth = 180,
    int maxColumns = 4,
  }) {
    if (itemCount <= 0) return 1;

    var cols = maxColumns;
    if (cols > itemCount) cols = itemCount;

    while (cols > 1) {
      final tileWidth = (width - spacing * (cols - 1)) / cols;
      if (tileWidth >= minTileWidth) break;
      cols--;
    }
    return cols;
  }

  /// Responsive column count for raised tile grids (doctors, products, etc.).
  static int gridCrossAxisCount(
    double width,
    int itemCount, {
    double spacing = 20,
    double minTileWidth = 200,
    int maxColumns = 4,
  }) {
    if (itemCount <= 0) return 1;

    var cols = maxColumns;
    if (cols > itemCount) cols = itemCount;

    while (cols > 1) {
      final tileWidth = (width - spacing * (cols - 1)) / cols;
      if (tileWidth >= minTileWidth) break;
      cols--;
    }
    return cols;
  }

  /// Column count for a fixed-size tile grid (independent of how many items exist).
  static int layoutGridCrossAxisCount(
    double width, {
    double spacing = 20,
    double minTileWidth = 200,
    int maxColumns = 4,
  }) {
    var cols = maxColumns;
    while (cols > 1) {
      final tileWidth = (width - spacing * (cols - 1)) / cols;
      if (tileWidth >= minTileWidth) break;
      cols--;
    }
    return cols;
  }
}

/// Caps content width on wide **native** screens (Android/iOS tablets).
///
/// Below [AppBreakpoints.wide], and always on web (which has its own shell and
/// column), [child] is returned unchanged, so phone and web layouts are
/// untouched. Layout only; it never changes what is shown.
class NativeContentWidth extends StatelessWidget {
  final Widget child;

  /// Overrides [kIsWeb] in tests.
  @visibleForTesting
  final bool? isWebOverride;

  const NativeContentWidth({
    super.key,
    required this.child,
    this.isWebOverride,
  });

  @override
  Widget build(BuildContext context) {
    if (isWebOverride ?? kIsWeb) return child;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        if (width < AppBreakpoints.wide ||
            width <= AppBreakpoints.contentMaxWidth) {
          return child;
        }
        // Symmetric padding instead of Align: keeps the vertical constraints
        // exactly as given (tight stays tight, loose stays loose). An Align
        // would expand to the max height, e.g. a Scaffold bottom bar would
        // then fill the whole screen.
        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: (width - AppBreakpoints.contentMaxWidth) / 2,
          ),
          child: child,
        );
      },
    );
  }
}
