import 'package:flutter/material.dart';
import '../config/app_theme.dart';

/// White card container with subtle shadow.
class NeumorphicContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final bool convex; // kept for API compat; ignored
  final double depth; // kept for API compat; ignored
  final double? width;
  final double? height;

  const NeumorphicContainer({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = 16,
    this.convex = true,
    this.depth = 8,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: AppTheme.cardShadow,
      ),
      child: child,
    );
  }
}

/// Button: blue filled (isPrimary) or white card style.
class NeumorphicButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final bool isPrimary;

  const NeumorphicButton({
    super.key,
    required this.child,
    this.onPressed,
    this.padding,
    this.borderRadius = 14,
    this.isPrimary = false,
  });

  @override
  State<NeumorphicButton> createState() => _NeumorphicButtonState();
}

class _NeumorphicButtonState extends State<NeumorphicButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final bg = widget.isPrimary ? AppTheme.primaryBlue : AppTheme.cardColor;
    final fgColor = widget.isPrimary ? Colors.white : AppTheme.textColor;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        decoration: BoxDecoration(
          color: _pressed
              ? (widget.isPrimary ? AppTheme.primaryBlue.withValues(alpha: 0.85) : AppTheme.surface)
              : bg,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          boxShadow: widget.isPrimary
              ? [
                  BoxShadow(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                    offset: const Offset(0, 4),
                    blurRadius: 12,
                  ),
                ]
              : AppTheme.cardShadow,
        ),
        child: DefaultTextStyle(
          style: TextStyle(
            fontSize: 16,
            color: fgColor,
            fontWeight: FontWeight.w600,
          ),
          child: IconTheme(
            data: IconThemeData(color: fgColor),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
