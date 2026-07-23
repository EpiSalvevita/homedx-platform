part of '../figma_ui.dart';

/// Typography helpers for Figma-aligned screens.
class FigmaUi {
  static TextStyle rubik({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double height = 1.055,
  }) {
    return GoogleFonts.rubik(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
    );
  }

  /// Figma Mobile/Body Light — Rubik 300, 14px, 106% line height, #142543.
  static TextStyle bodyLight({double fontSize = 14, Color? color}) {
    return rubik(
      fontSize: fontSize,
      fontWeight: FontWeight.w300,
      color: color ?? AppTheme.textColor,
      height: 1.06,
    );
  }
}
