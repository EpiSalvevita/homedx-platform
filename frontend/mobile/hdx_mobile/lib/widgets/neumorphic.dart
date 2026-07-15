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
  bool _hovered = false;

  bool get _enabled => widget.onPressed != null;

  Color _resolveBackground(Color base) {
    if (!_enabled) return base;
    if (_pressed) {
      return widget.isPrimary
          ? AppTheme.primaryBlue.withValues(alpha: 0.85)
          : AppTheme.surface;
    }
    if (_hovered) {
      return widget.isPrimary
          ? Color.lerp(AppTheme.primaryBlue, AppTheme.accentBlue, 0.18)!
          : AppTheme.primaryLight;
    }
    return base;
  }

  List<BoxShadow>? _resolveShadow() {
    if (!_enabled) return widget.isPrimary ? null : AppTheme.cardShadow;
    if (widget.isPrimary) {
      final alpha = _hovered ? 0.42 : 0.3;
      final blur = _hovered ? 16.0 : 12.0;
      final offset = _hovered ? const Offset(0, 6) : const Offset(0, 4);
      return [
        BoxShadow(
          color: AppTheme.primaryBlue.withValues(alpha: alpha),
          offset: offset,
          blurRadius: blur,
        ),
      ];
    }
    if (_hovered) {
      return [
        BoxShadow(
          color: AppTheme.primaryBlue.withValues(alpha: 0.14),
          offset: const Offset(0, 4),
          blurRadius: 14,
        ),
      ];
    }
    return AppTheme.cardShadow;
  }

  @override
  Widget build(BuildContext context) {
    final base = widget.isPrimary ? AppTheme.primaryBlue : AppTheme.cardColor;
    final fgColor = widget.isPrimary ? Colors.white : AppTheme.textColor;

    return MouseRegion(
      cursor: _enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: _enabled ? (_) => setState(() => _hovered = true) : null,
      onExit: _enabled ? (_) => setState(() => _hovered = false) : null,
      child: GestureDetector(
        onTapDown: _enabled ? (_) => setState(() => _pressed = true) : null,
        onTapUp: _enabled ? (_) => setState(() => _pressed = false) : null,
        onTapCancel: _enabled ? () => setState(() => _pressed = false) : null,
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          constraints: const BoxConstraints(
            minHeight: AppTheme.minTouchTarget,
            minWidth: AppTheme.minTouchTarget,
          ),
          alignment: Alignment.center,
          padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          decoration: BoxDecoration(
            color: _resolveBackground(base),
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: !widget.isPrimary
                ? Border.all(
                    color: _hovered
                        ? AppTheme.primaryBlue.withValues(alpha: 0.22)
                        : Colors.transparent,
                    width: 1,
                  )
                : null,
            boxShadow: _resolveShadow(),
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
      ),
    );
  }
}
