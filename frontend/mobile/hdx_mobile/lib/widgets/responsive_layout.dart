/// Breakpoints shared across web and adaptive layouts.
class AppBreakpoints {
  /// Matches marketing pages (`MarketingSection.wideBreakpoint`).
  static const double wide = 768;

  /// Routes that intentionally use full browser width on web.
  static bool isFullWidthWebRoute(String path) {
    if (path == '/' || path == '/about') return true;
    return false;
  }

  /// Grid columns for home quick-action tiles on mobile/narrow layouts.
  static int quickActionCrossAxisCount(double width) {
    if (width >= 440) return 3;
    return 2;
  }
}
