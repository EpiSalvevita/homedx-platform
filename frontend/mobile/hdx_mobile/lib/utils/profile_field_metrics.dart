import 'package:flutter/material.dart';
import '../config/app_theme.dart';

/// Width-scaled inset-field tokens for the profile form.
///
/// Base values match auth-scale [AppTheme.profileField*] at [referenceWidth]
/// (Figma ~392px). Scales gently between [minScale] and [maxScale].
class ProfileFieldMetrics {
  final double fieldHeight;
  final EdgeInsets fieldPadding;
  final double fontSize;
  final double labelFontSize;
  final double iconSize;
  final double contentGap;
  final double labelOffsetLeft;
  final double labelOffsetTop;
  final double rowSpacing;
  final double rowGap;

  const ProfileFieldMetrics({
    required this.fieldHeight,
    required this.fieldPadding,
    required this.fontSize,
    required this.labelFontSize,
    required this.iconSize,
    required this.contentGap,
    required this.labelOffsetLeft,
    required this.labelOffsetTop,
    required this.rowSpacing,
    required this.rowGap,
  });

  static const double referenceWidth = 392;
  static const double minScale = 0.9;
  static const double maxScale = 1.1;

  factory ProfileFieldMetrics.fromWidth(double width) {
    final scale = (width / referenceWidth).clamp(minScale, maxScale);

    return ProfileFieldMetrics(
      fieldHeight: AppTheme.profileFieldHeight * scale,
      fieldPadding: EdgeInsets.symmetric(
        horizontal: AppTheme.profileFieldPadding.horizontal * scale,
      ),
      fontSize: AppTheme.profileFieldFontSize * scale,
      labelFontSize: AppTheme.profileFieldLabelFontSize * scale,
      iconSize: AppTheme.profileFieldIconSize * scale,
      contentGap: AppTheme.profileFieldContentGap * scale,
      labelOffsetLeft: AppTheme.profileFieldLabelOffsetLeft * scale,
      labelOffsetTop: AppTheme.profileFieldLabelOffsetTop * scale,
      rowSpacing: AppTheme.profileFieldRowSpacing * scale,
      rowGap: 16 * scale,
    );
  }
}
