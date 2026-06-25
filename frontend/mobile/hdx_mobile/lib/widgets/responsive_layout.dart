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
  /// Uses a single row when every tile can stay at least [minTileWidth] wide;
  /// otherwise falls back to 2–3 columns on narrow screens.
  static int quickActionCrossAxisCount(double width, int itemCount, {double spacing = 20}) {
    if (itemCount <= 0) return 1;

    const minTileWidth = 96.0;
    final singleRowTileWidth = (width - spacing * (itemCount - 1)) / itemCount;
    if (singleRowTileWidth >= minTileWidth) {
      return itemCount;
    }

    if (width >= wide) return itemCount > 3 ? 3 : itemCount;
    if (width >= 440) return itemCount > 3 ? 3 : itemCount;
    return itemCount > 2 ? 2 : itemCount;
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
