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
}
