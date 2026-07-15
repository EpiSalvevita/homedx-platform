/// Breakpoints shared across web and adaptive layouts.
class AppBreakpoints {
  /// Matches marketing pages (`MarketingSection.wideBreakpoint`).
  static const double wide = 768;

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
