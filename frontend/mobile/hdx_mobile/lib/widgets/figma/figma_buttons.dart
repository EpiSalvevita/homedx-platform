part of '../figma_ui.dart';

class NeumorphicPillButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final double height;
  final IconData? leadingIcon;
  /// When false, the pill hugs [label] (+ optional [leadingIcon]) instead of filling width.
  final bool expanded;
  final Color? backgroundColor;
  final Color? foregroundColor;
  /// When true, uses inset styling (input fields). Default is Figma Large raised button.
  final bool inset;

  const NeumorphicPillButton({
    super.key,
    required this.label,
    this.onPressed,
    this.loading = false,
    this.height = AppTheme.buttonHeightLarge,
    this.leadingIcon,
    this.expanded = true,
    this.backgroundColor,
    this.foregroundColor,
    this.inset = false,
  });

  @override
  State<NeumorphicPillButton> createState() => _NeumorphicPillButtonState();
}

class _NeumorphicPillButtonState extends State<NeumorphicPillButton> {
  bool _hovered = false;

  static final WidgetStateProperty<Color?> _pillHoverOverlay =
      WidgetStateProperty.resolveWith((states) {
    if (states.contains(WidgetState.hovered)) {
      return AppTheme.primaryBlue.withValues(alpha: 0.08);
    }
    if (states.contains(WidgetState.focused)) {
      return AppTheme.primaryBlue.withValues(alpha: 0.12);
    }
    return null;
  });

  Widget _buildContent(Color foreground) {
    if (widget.loading) {
      return SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(strokeWidth: 2, color: foreground),
      );
    }

    final text = Text(
      widget.label,
      style: FigmaUi.rubik(fontSize: 18, fontWeight: FontWeight.w500, color: foreground),
    );

    if (widget.leadingIcon == null) return text;

    const iconSize = 22.0;
    const iconGap = 10.0;
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(widget.leadingIcon, size: iconSize, color: foreground),
        const SizedBox(width: iconGap),
        text,
        const SizedBox(width: iconSize + iconGap),
      ],
    );
  }

  EdgeInsetsGeometry _pillPadding() {
    if (widget.expanded) return AppTheme.buttonPaddingLarge;
    return const EdgeInsets.symmetric(horizontal: 26);
  }

  Color _resolveFill(Color base) {
    if (!_hovered || (widget.onPressed == null && !widget.loading)) return base;
    return Color.lerp(base, AppTheme.primaryLight, 0.45) ?? base;
  }

  List<BoxShadow>? _resolveRaisedShadow(bool enabled) {
    if (!enabled) return null;
    if (!_hovered) return AppTheme.neumorphicRaised;
    return [
      ...AppTheme.neumorphicRaised,
      BoxShadow(
        color: AppTheme.primaryBlue.withValues(alpha: 0.12),
        offset: const Offset(0, 6),
        blurRadius: 16,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final baseFill = widget.backgroundColor ?? AppTheme.background;
    final fill = _resolveFill(baseFill);
    final foreground = widget.foregroundColor ?? AppTheme.textColor;
    final labelWidget = _buildContent(foreground);
    final pillPadding = _pillPadding();
    final enabled = widget.onPressed != null || widget.loading;

    Widget pill;

    if (widget.inset) {
      pill = NeumorphicInsetSurface(
        height: widget.height,
        padding: pillPadding,
        alignment: Alignment.center,
        backgroundColor: fill,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.loading ? null : widget.onPressed,
            borderRadius: BorderRadius.circular(AppTheme.pillRadius),
            splashFactory: NoSplash.splashFactory,
            highlightColor: Colors.transparent,
            hoverColor: AppTheme.primaryBlue.withValues(alpha: 0.08),
            overlayColor: _pillHoverOverlay,
            child: SizedBox(
              width: widget.expanded ? double.infinity : null,
              height: double.infinity,
              child: widget.expanded ? Center(child: labelWidget) : labelWidget,
            ),
          ),
        ),
      );
    } else {
      pill = AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        margin: const EdgeInsets.all(2),
        width: widget.expanded ? double.infinity : null,
        height: widget.height,
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(AppTheme.pillRadius),
          border: Border.all(
            color: _hovered && enabled
                ? AppTheme.primaryBlue.withValues(alpha: 0.18)
                : Colors.transparent,
            width: 1,
          ),
          boxShadow: _resolveRaisedShadow(enabled),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.loading ? null : widget.onPressed,
            borderRadius: BorderRadius.circular(AppTheme.pillRadius),
            splashFactory: NoSplash.splashFactory,
            highlightColor: Colors.transparent,
            hoverColor: AppTheme.primaryBlue.withValues(alpha: 0.06),
            overlayColor: _pillHoverOverlay,
            child: Padding(
              padding: pillPadding,
              child: Center(child: labelWidget),
            ),
          ),
        ),
      );
    }

    if (!widget.expanded) {
      pill = Padding(
        padding: const EdgeInsets.all(4),
        child: IntrinsicWidth(child: pill),
      );
    }

    return MouseRegion(
      cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: enabled ? (_) => setState(() => _hovered = true) : null,
      onExit: enabled ? (_) => setState(() => _hovered = false) : null,
      child: pill,
    );
  }
}

class FigmaBottomActionBar extends StatelessWidget {
  final String buttonLabel;
  final VoidCallback? onPressed;
  final bool loading;

  const FigmaBottomActionBar({
    super.key,
    required this.buttonLabel,
    this.onPressed,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      decoration: BoxDecoration(
        color: AppTheme.background,
        boxShadow: [
          BoxShadow(color: AppTheme.navy.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, -4)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: NeumorphicPillButton(label: buttonLabel, onPressed: onPressed, loading: loading),
      ),
    );
  }
}
