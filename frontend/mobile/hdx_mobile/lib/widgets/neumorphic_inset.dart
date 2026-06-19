import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/app_theme.dart';

/// Figma inset shadow for pill fields (`50:528` Search Box):
/// `inset 4px 4px 10px #99A6CE4D, inset -4px -4px 4px #FFFFFF`.
class NeumorphicInsetSurface extends StatelessWidget {
  final Widget child;
  final double height;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Alignment alignment;
  final double shadowBand;
  final double highlightBand;

  const NeumorphicInsetSurface({
    super.key,
    required this.child,
    this.height = AppTheme.fieldHeight,
    this.padding = AppTheme.fieldPadding,
    this.borderRadius = AppTheme.pillRadius,
    this.alignment = Alignment.centerLeft,
    this.shadowBand = 14,
    this.highlightBand = 7,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _NeumorphicInsetPainter(
          borderRadius: borderRadius,
          backgroundColor: AppTheme.background,
          shadowBand: shadowBand,
          highlightBand: highlightBand,
        ),
        child: Padding(
          padding: padding,
          child: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Align(alignment: alignment, child: child),
          ),
        ),
      ),
    );
  }
}

/// Figma home card: raised drop shadow + subtle inset (activity rows, welcome card).
class NeumorphicActivityCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double height;
  final double borderRadius;

  const NeumorphicActivityCard({
    super.key,
    required this.child,
    this.onTap,
    this.height = AppTheme.activityCardHeight,
    this.borderRadius = AppTheme.activityCardRadius,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius);
    return Container(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: AppTheme.neumorphicRaised,
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: CustomPaint(
          painter: _NeumorphicInsetPainter(
            borderRadius: borderRadius,
            backgroundColor: AppTheme.background,
            shadowBand: 7,
            highlightBand: 5,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              splashFactory: NoSplash.splashFactory,
              highlightColor: Colors.transparent,
              child: SizedBox(
                height: height,
                width: double.infinity,
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NeumorphicInsetPainter extends CustomPainter {
  static const Color _insetShadow = Color(0x4D99A6CE);

  final double borderRadius;
  final Color backgroundColor;
  final double shadowBand;
  final double highlightBand;

  _NeumorphicInsetPainter({
    required this.borderRadius,
    required this.backgroundColor,
    this.shadowBand = 14,
    this.highlightBand = 7,
  });

  void _drawEdgeFade(
    Canvas canvas,
    Rect bounds, {
    required Alignment begin,
    required Alignment end,
    required Color edgeColor,
  }) {
    canvas.drawRect(
      bounds,
      Paint()
        ..shader = LinearGradient(
          begin: begin,
          end: end,
          colors: [edgeColor, edgeColor.withValues(alpha: 0)],
        ).createShader(bounds),
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));

    canvas.drawRRect(rrect, Paint()..color = backgroundColor);

    canvas.save();
    canvas.clipRRect(rrect);

    // Figma: inset 4px 4px 10px #99A6CE4D — dark inner shadow toward bottom-right.
    _drawEdgeFade(
      canvas,
      Rect.fromLTWH(0, size.height - shadowBand, size.width, shadowBand),
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
      edgeColor: _insetShadow,
    );
    _drawEdgeFade(
      canvas,
      Rect.fromLTWH(size.width - shadowBand, 0, shadowBand, size.height),
      begin: Alignment.centerRight,
      end: Alignment.centerLeft,
      edgeColor: _insetShadow,
    );

    // Figma: inset -4px -4px 4px #FFFFFF — highlight on top/left inner edges.
    _drawEdgeFade(
      canvas,
      Rect.fromLTWH(0, 0, size.width, highlightBand),
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      edgeColor: Colors.white,
    );
    _drawEdgeFade(
      canvas,
      Rect.fromLTWH(0, 0, highlightBand, size.height),
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      edgeColor: Colors.white,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _NeumorphicInsetPainter oldDelegate) {
    return oldDelegate.borderRadius != borderRadius ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.shadowBand != shadowBand ||
        oldDelegate.highlightBand != highlightBand;
  }
}

/// InputDecoration that never picks up theme focus/fill styling.
InputDecoration neumorphicFieldDecoration({
  String? hint,
  IconData? prefixIcon,
  Widget? suffix,
}) {
  const none = InputBorder.none;
  return InputDecoration(
    isDense: true,
    filled: false,
    fillColor: Colors.transparent,
    hoverColor: Colors.transparent,
    border: none,
    enabledBorder: none,
    focusedBorder: none,
    disabledBorder: none,
    errorBorder: none,
    focusedErrorBorder: none,
    hintText: hint,
    hintStyle: GoogleFonts.rubik(
      fontSize: 16,
      fontWeight: FontWeight.w300,
      color: AppTheme.textColor.withValues(alpha: 0.5),
      height: 1.0,
    ),
    prefixIcon: prefixIcon != null
        ? Padding(
            padding: EdgeInsets.only(right: AppTheme.fieldContentGap),
            child: Align(
              alignment: Alignment.center,
              widthFactor: 1,
              heightFactor: 1,
              child: Icon(prefixIcon, color: AppTheme.textColor, size: 21),
            ),
          )
        : null,
    prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
    suffixIcon: suffix,
    suffixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 40),
    contentPadding: EdgeInsets.zero,
  );
}

/// Local theme so Material fields do not flash blue borders on focus.
ThemeData neumorphicFieldTheme(BuildContext context) {
  return Theme.of(context).copyWith(
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
    inputDecorationTheme: const InputDecorationTheme(
      filled: false,
      border: InputBorder.none,
      enabledBorder: InputBorder.none,
      focusedBorder: InputBorder.none,
      disabledBorder: InputBorder.none,
      errorBorder: InputBorder.none,
      focusedErrorBorder: InputBorder.none,
    ),
  );
}
