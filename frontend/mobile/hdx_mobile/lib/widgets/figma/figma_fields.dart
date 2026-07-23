part of '../figma_ui.dart';

/// Profile input — same pill inset tile as login ([NeumorphicInsetField]).
class ProfileInsetField extends StatelessWidget {
  final ProfileFieldMetrics metrics;
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final bool obscureText;
  final Widget? suffix;

  const ProfileInsetField({
    super.key,
    required this.metrics,
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.validator,
    this.obscureText = false,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return NeumorphicInsetField(
      controller: controller,
      label: label,
      prefixIcon: icon,
      keyboardType: keyboardType,
      validator: validator,
      obscureText: obscureText,
      suffix: suffix,
      fieldHeight: metrics.fieldHeight,
      fieldPadding: metrics.fieldPadding,
      fontSize: metrics.fontSize,
      labelFontSize: metrics.labelFontSize,
      labelOffsetLeft: metrics.labelOffsetLeft,
      labelOffsetTop: metrics.labelOffsetTop,
      iconSize: metrics.iconSize,
      contentGap: metrics.contentGap,
    );
  }
}

/// Error line shown directly below neumorphic inset fields.
class NeumorphicFieldError extends StatelessWidget {
  final String? text;

  const NeumorphicFieldError({super.key, this.text});

  @override
  Widget build(BuildContext context) {
    if (text == null || text!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8, left: 12, right: 12),
      child: Text(
        text!,
        style: FigmaUi.rubik(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: AppTheme.errorColor,
          height: 1.3,
        ),
      ),
    );
  }
}

/// Neumorphic pill input with floating label (login / signup fields).
/// Uses inverted inset — mirror of [NeumorphicPillButton] raised shadows pushed inward
/// (shadow top/left, highlight bottom/right).
class NeumorphicInsetField extends StatelessWidget {
  final TextEditingController? controller;
  final String label;
  final String? hint;
  final IconData? prefixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final Widget? suffix;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final VoidCallback? onFieldSubmitted;
  final double fieldHeight;
  final EdgeInsetsGeometry fieldPadding;
  final double fontSize;
  final double labelFontSize;
  final double labelOffsetLeft;
  final double labelOffsetTop;
  final double iconSize;
  final double contentGap;

  const NeumorphicInsetField({
    super.key,
    this.controller,
    required this.label,
    this.hint,
    this.prefixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.suffix,
    this.focusNode,
    this.textInputAction,
    this.onFieldSubmitted,
    this.fieldHeight = AppTheme.fieldHeight,
    this.fieldPadding = AppTheme.fieldPadding,
    this.fontSize = 17,
    this.labelFontSize = 15,
    this.labelOffsetLeft = 38,
    this.labelOffsetTop = -10,
    this.iconSize = 22,
    this.contentGap = AppTheme.fieldContentGap,
  });

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      validator: (fieldValue) {
        final value = controller?.text ?? fieldValue ?? '';
        return validator?.call(value.isEmpty ? null : value);
      },
      builder: (field) {
        final textStyle = FigmaUi.rubik(
          fontSize: fontSize,
          fontWeight: FontWeight.w300,
          color: AppTheme.textColor,
          height: 1.0,
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                NeumorphicInsetSurface(
                  height: fieldHeight,
                  padding: fieldPadding,
                  invertedInset: true,
                  backgroundColor: AppTheme.background,
                  child: Theme(
                    data: neumorphicFieldTheme(context),
                    child: TextField(
                      controller: controller,
                      focusNode: focusNode,
                      onChanged: field.didChange,
                      obscureText: obscureText,
                      keyboardType: keyboardType,
                      textInputAction: textInputAction,
                      onSubmitted: onFieldSubmitted != null ? (_) => onFieldSubmitted!() : null,
                      textAlignVertical: TextAlignVertical.center,
                      cursorColor: AppTheme.textColor,
                      style: textStyle,
                      decoration: neumorphicFieldDecoration(
                        hint: hint,
                        prefixIcon: prefixIcon,
                        suffix: suffix,
                        iconSize: iconSize,
                        hintFontSize: fontSize,
                        contentGap: contentGap,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: labelOffsetLeft,
                  top: labelOffsetTop,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.background,
                      borderRadius: BorderRadius.circular(38),
                    ),
                    child: Text(
                      label,
                      style: FigmaUi.rubik(
                        fontSize: labelFontSize,
                        fontWeight: FontWeight.w300,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            NeumorphicFieldError(text: field.errorText),
          ],
        );
      },
    );
  }
}

/// Styled picker menu aligned to inset fields (replaces Material [DropdownButton] menu).
Future<String?> showNeumorphicInsetPickerMenu({
  required BuildContext context,
  required List<String> items,
  required Rect anchor,
  required Size overlaySize,
  String? current,
}) {
  return showMenu<String>(
    context: context,
    position: RelativeRect.fromSize(
      Rect.fromLTWH(anchor.left, anchor.top + anchor.height + 6, anchor.width, 0),
      overlaySize,
    ),
    color: AppTheme.background,
    elevation: 0,
    surfaceTintColor: Colors.transparent,
    shadowColor: const Color(0x4D99A6CE),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppTheme.activityCardRadius),
      side: BorderSide(color: AppTheme.navy.withValues(alpha: 0.08)),
    ),
    constraints: BoxConstraints(
      minWidth: anchor.width,
      maxWidth: anchor.width,
    ),
    items: items
        .map(
          (item) => PopupMenuItem<String>(
            value: item,
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: item == current ? AppTheme.primaryLight : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                item,
                style: FigmaUi.rubik(
                  fontSize: 15,
                  fontWeight: item == current ? FontWeight.w500 : FontWeight.w300,
                  color: AppTheme.textColor,
                  height: 1.0,
                ),
              ),
            ),
          ),
        )
        .toList(),
  );
}

/// Neumorphic pill dropdown with floating label (profile Geschlecht, doctor signup Fachrichtung).
class NeumorphicInsetDropdown extends StatefulWidget {
  final String label;
  final IconData? prefixIcon;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final String? Function(String?)? validator;
  final String hint;
  final double fieldHeight;
  final EdgeInsetsGeometry fieldPadding;
  final double fontSize;
  final double labelFontSize;
  final double labelOffsetLeft;
  final double labelOffsetTop;
  final double iconSize;
  final double contentGap;
  final bool isExpanded;

  const NeumorphicInsetDropdown({
    super.key,
    required this.label,
    this.prefixIcon,
    required this.value,
    required this.items,
    required this.onChanged,
    this.validator,
    this.hint = 'Auswählen',
    this.fieldHeight = AppTheme.fieldHeight,
    this.fieldPadding = AppTheme.fieldPadding,
    this.fontSize = 17,
    this.labelFontSize = 15,
    this.labelOffsetLeft = 38,
    this.labelOffsetTop = -10,
    this.iconSize = 22,
    this.contentGap = AppTheme.fieldContentGap,
    this.isExpanded = true,
  });

  @override
  State<NeumorphicInsetDropdown> createState() => _NeumorphicInsetDropdownState();
}

class _NeumorphicInsetDropdownState extends State<NeumorphicInsetDropdown> {
  final GlobalKey _anchorKey = GlobalKey();

  Future<void> _openMenu(BuildContext context, FormFieldState<String> field) async {
    final box = _anchorKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;

    final overlay = Navigator.of(context).overlay!;
    final overlayBox = overlay.context.findRenderObject()! as RenderBox;
    final topLeft = box.localToGlobal(Offset.zero, ancestor: overlayBox);
    final anchorInOverlay = topLeft & box.size;

    final selected = await showNeumorphicInsetPickerMenu(
      context: context,
      items: widget.items,
      anchor: anchorInOverlay,
      overlaySize: overlayBox.size,
      current: field.value,
    );
    if (selected == null) return;
    field.didChange(selected);
    widget.onChanged(selected);
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = FigmaUi.rubik(
      fontSize: widget.fontSize,
      fontWeight: FontWeight.w300,
      color: AppTheme.textColor,
      height: 1.0,
    );

    return FormField<String>(
      key: ValueKey(widget.value),
      initialValue: widget.value,
      validator: widget.validator,
      builder: (field) {
        final display = field.value;
        final hasValue = display != null && display.isNotEmpty;
        final selectedLabel = hasValue ? display : widget.hint;
        final valueStyle = hasValue
            ? textStyle
            : textStyle.copyWith(color: AppTheme.textColor.withValues(alpha: 0.5));

        final valueRow = Row(
          children: [
            if (widget.prefixIcon != null) ...[
              Icon(widget.prefixIcon, size: widget.iconSize, color: AppTheme.textColor),
              SizedBox(width: widget.contentGap),
            ],
            if (widget.isExpanded)
              Expanded(
                child: Text(
                  selectedLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: valueStyle,
                ),
              )
            else
              Text(
                selectedLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: valueStyle,
              ),
            const SizedBox(width: 8),
            Icon(Icons.keyboard_arrow_down_rounded, size: 22, color: AppTheme.textColorSecondary),
          ],
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              key: _anchorKey,
              clipBehavior: Clip.none,
              children: [
                NeumorphicInsetSurface(
                  height: widget.fieldHeight,
                  padding: widget.fieldPadding,
                  invertedInset: true,
                  backgroundColor: AppTheme.background,
                  alignment: Alignment.centerLeft,
                  child: valueRow,
                ),
                Positioned.fill(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _openMenu(context, field),
                      splashFactory: NoSplash.splashFactory,
                      highlightColor: Colors.transparent,
                      child: const SizedBox.expand(),
                    ),
                  ),
                ),
                Positioned(
                  left: widget.labelOffsetLeft,
                  top: widget.labelOffsetTop,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.background,
                      borderRadius: BorderRadius.circular(38),
                    ),
                    child: Text(
                      widget.label,
                      style: FigmaUi.rubik(
                        fontSize: widget.labelFontSize,
                        fontWeight: FontWeight.w300,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            NeumorphicFieldError(text: field.errorText),
          ],
        );
      },
    );
  }
}
