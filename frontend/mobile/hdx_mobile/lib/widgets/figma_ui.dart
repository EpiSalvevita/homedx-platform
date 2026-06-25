import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/app_theme.dart';
import '../utils/app_assets.dart';
import '../utils/profile_field_metrics.dart';
import 'neumorphic_inset.dart';

/// Shared UI primitives matching the homeDX Figma "Final" page.
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

class FigmaScreen extends StatelessWidget {
  final Widget? header;
  final Widget body;
  final Widget? bottomBar;
  final bool extendBodyBehindHeader;

  const FigmaScreen({
    super.key,
    this.header,
    required this.body,
    this.bottomBar,
    this.extendBodyBehindHeader = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      bottomNavigationBar: bottomBar,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (header != null) header!,
          Expanded(child: body),
        ],
      ),
    );
  }
}

/// Figma blue top bar (`50:617`): 118px, #80A2F9, drop shadow 4/4/10 #99A6CE4D.
class FigmaBlueTopBar extends StatelessWidget {
  final Widget child;

  const FigmaBlueTopBar({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    final contentHeight = (AppTheme.homeHeaderHeight - topInset).clamp(56.0, AppTheme.homeHeaderHeight);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.accentBlue,
        boxShadow: AppTheme.homeHeaderShadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: topInset),
          SizedBox(height: contentHeight, child: child),
        ],
      ),
    );
  }
}

/// Home top bar: logo + optional trailing menu.
class FigmaHomeHeader extends StatelessWidget {
  final VoidCallback? onMenuTap;
  final Widget? trailing;

  const FigmaHomeHeader({super.key, this.onMenuTap, this.trailing});

  @override
  Widget build(BuildContext context) {
    return FigmaBlueTopBar(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(AppTheme.screenHorizontalPadding, 0, AppTheme.screenHorizontalPadding, 16),
        child: Row(
          children: [
            Image.asset(
              AppAssets.logo,
              width: AppAssets.logoHeaderWidth,
              height: AppAssets.logoHeaderHeight,
              fit: BoxFit.contain,
            ),
            const Spacer(),
            if (trailing != null) trailing!,
            if (onMenuTap != null)
              IconButton(
                onPressed: onMenuTap,
                icon: const Icon(Icons.menu, color: AppTheme.textColor, size: 28),
              ),
          ],
        ),
      ),
    );
  }
}

/// Inner screens: back chevron + title (Figma uses arrow-left pattern).
class FigmaBackHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBack;
  final List<Widget>? actions;
  final bool showBack;
  /// Figma inner-screen blue top bar (118px, #80A2F9 + drop shadow).
  final bool blueTopBar;

  const FigmaBackHeader({
    super.key,
    required this.title,
    this.onBack,
    this.actions,
    this.showBack = true,
    this.blueTopBar = false,
  });

  @override
  Size get preferredSize => Size.fromHeight(blueTopBar ? AppTheme.homeHeaderHeight : 56);

  @override
  Widget build(BuildContext context) {
    final row = Row(
      children: [
        if (showBack)
          IconButton(
            onPressed: onBack ?? () => Navigator.maybePop(context),
            icon: Transform.rotate(
              angle: 3.14159,
              child: const Icon(Icons.arrow_forward_ios, size: 20, color: AppTheme.textColor),
            ),
          )
        else
          const SizedBox(width: 48),
        Expanded(
          child: Text(
            title,
            style: FigmaUi.rubik(fontSize: 20, fontWeight: FontWeight.w500, color: AppTheme.textColor),
          ),
        ),
        if (actions != null) ...actions!,
      ],
    );

    if (blueTopBar) {
      return FigmaBlueTopBar(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, AppTheme.screenHorizontalPadding, 16),
          child: row,
        ),
      );
    }

    return Material(
      color: AppTheme.background,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 56,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: row,
          ),
        ),
      ),
    );
  }
}

class FigmaSectionTitle extends StatelessWidget {
  final String text;

  const FigmaSectionTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: FigmaUi.rubik(fontSize: 16, fontWeight: FontWeight.w500, color: AppTheme.textColor),
    );
  }
}

class FigmaInfoBanner extends StatelessWidget {
  final String message;

  const FigmaInfoBanner({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return FigmaInsetInfoCard(
      icon: Icons.info_outline,
      title: message,
    );
  }
}

/// Inset info row — same inverted neumorphic surface as [FigmaInfoBanner].
class FigmaInsetInfoCard extends StatelessWidget {
  final IconData? icon;
  final String? title;
  final String? subtitle;
  final Widget? trailing;
  final Widget? child;
  final VoidCallback? onTap;
  final double? height;
  final Color? iconColor;

  const FigmaInsetInfoCard({
    super.key,
    this.icon,
    this.title,
    this.subtitle,
    this.trailing,
    this.child,
    this.onTap,
    this.height,
    this.iconColor,
  });

  double _resolveHeight() {
    if (height != null) return height!;
    if (child != null) return AppTheme.activityCardHeight;
    if (subtitle != null && subtitle!.isNotEmpty) return AppTheme.infoInsetCardHeight;
    return AppTheme.infoBannerHeight;
  }

  EdgeInsetsGeometry _resolvePadding() {
    if (child != null) return AppTheme.activityCardPadding;
    if (subtitle != null && subtitle!.isNotEmpty) return AppTheme.infoInsetCardPadding;
    return const EdgeInsets.symmetric(horizontal: AppTheme.infoBannerHorizontalPadding);
  }

  @override
  Widget build(BuildContext context) {
    final content = child ??
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, color: iconColor ?? AppTheme.primaryBlue, size: 21),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (title != null)
                    Text(
                      title!,
                      style: FigmaUi.rubik(
                        fontSize: subtitle != null ? 15 : 14,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textColor,
                      ),
                    ),
                  if (subtitle != null && subtitle!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: FigmaUi.rubik(
                        fontSize: 13,
                        fontWeight: FontWeight.w300,
                        color: AppTheme.textColorSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 8),
              trailing!,
            ],
          ],
        );

    final card = NeumorphicInsetCard(
      height: _resolveHeight(),
      padding: _resolvePadding(),
      invertedInset: true,
      backgroundColor: AppTheme.insetWellFill,
      child: content,
    );

    if (onTap == null) return card;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: card,
      ),
    );
  }
}

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
    this.fontSize = 16,
    this.labelFontSize = 14,
    this.labelOffsetLeft = 38,
    this.labelOffsetTop = -10,
    this.iconSize = 21,
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

/// Neumorphic pill dropdown with floating label (doctor signup Fachrichtung).
class NeumorphicInsetDropdown extends StatelessWidget {
  final String label;
  final IconData? prefixIcon;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final String? Function(String?)? validator;
  final double fieldHeight;
  final EdgeInsetsGeometry fieldPadding;
  final double fontSize;
  final double labelFontSize;
  final double labelOffsetLeft;
  final double labelOffsetTop;
  final double iconSize;
  final double contentGap;

  const NeumorphicInsetDropdown({
    super.key,
    required this.label,
    this.prefixIcon,
    required this.value,
    required this.items,
    required this.onChanged,
    this.validator,
    this.fieldHeight = AppTheme.fieldHeight,
    this.fieldPadding = AppTheme.fieldPadding,
    this.fontSize = 16,
    this.labelFontSize = 14,
    this.labelOffsetLeft = 38,
    this.labelOffsetTop = -10,
    this.iconSize = 21,
    this.contentGap = AppTheme.fieldContentGap,
  });

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      initialValue: value,
      validator: validator,
      builder: (field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
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
                    child: InputDecorator(
                      decoration: neumorphicFieldDecoration(
                        prefixIcon: prefixIcon,
                        iconSize: iconSize,
                        contentGap: contentGap,
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: field.value,
                          items: items
                              .map(
                                (item) => DropdownMenuItem<String>(
                                  value: item,
                                  child: Text(
                                    item,
                                    style: FigmaUi.rubik(
                                      fontSize: fontSize,
                                      fontWeight: FontWeight.w300,
                                      color: AppTheme.textColor,
                                      height: 1.0,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (selected) {
                            field.didChange(selected);
                            onChanged(selected);
                          },
                          isExpanded: true,
                          icon: const Icon(Icons.keyboard_arrow_down, color: AppTheme.textColorSecondary),
                          style: FigmaUi.rubik(
                            fontSize: fontSize,
                            fontWeight: FontWeight.w300,
                            color: AppTheme.textColor,
                            height: 1.0,
                          ),
                          dropdownColor: AppTheme.background,
                        ),
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

class NeumorphicPillButton extends StatelessWidget {
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

  Widget _buildContent(Color foreground) {
    if (loading) {
      return SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(strokeWidth: 2, color: foreground),
      );
    }

    final text = Text(
      label,
      style: FigmaUi.rubik(fontSize: 18, fontWeight: FontWeight.w500, color: foreground),
    );

    if (leadingIcon == null) return text;

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(leadingIcon, size: 22, color: foreground),
        const SizedBox(width: 10),
        text,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final fill = backgroundColor ?? AppTheme.background;
    final foreground = foregroundColor ?? AppTheme.textColor;
    final labelWidget = _buildContent(foreground);
    final horizontalPadding = expanded ? null : const EdgeInsets.symmetric(horizontal: 26);

    Widget pill;

    if (inset) {
      pill = NeumorphicInsetSurface(
        height: height,
        padding: horizontalPadding ?? const EdgeInsets.symmetric(horizontal: 26),
        alignment: Alignment.center,
        backgroundColor: fill,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: loading ? null : onPressed,
            borderRadius: BorderRadius.circular(AppTheme.pillRadius),
            splashFactory: NoSplash.splashFactory,
            highlightColor: Colors.transparent,
            child: SizedBox(
              width: expanded ? double.infinity : null,
              height: double.infinity,
              child: expanded ? Center(child: labelWidget) : labelWidget,
            ),
          ),
        ),
      );
    } else {
      final enabled = onPressed != null || loading;
      pill = Container(
        width: expanded ? double.infinity : null,
        height: height,
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(AppTheme.pillRadius),
          boxShadow: enabled ? AppTheme.neumorphicRaised : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: loading ? null : onPressed,
            borderRadius: BorderRadius.circular(AppTheme.pillRadius),
            splashFactory: NoSplash.splashFactory,
            highlightColor: Colors.transparent,
            child: Padding(
              padding: expanded ? AppTheme.buttonPaddingLarge : horizontalPadding!,
              child: expanded ? Center(child: labelWidget) : labelWidget,
            ),
          ),
        ),
      );
    }

    if (!expanded) {
      pill = IntrinsicWidth(child: pill);
    }

    return pill;
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

class LoginHeroBanner extends StatelessWidget {
  const LoginHeroBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final heroHeight = (width * 0.85).clamp(280.0, 412.0);

        return ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(24),
            bottomRight: Radius.circular(24),
          ),
          child: SizedBox(
            width: width,
            height: heroHeight,
            child: ColoredBox(
              color: AppTheme.surface,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    left: width * 0.04,
                    bottom: 24,
                    child: Image.asset(
                      AppAssets.loginDoctor,
                      height: heroHeight * 0.68,
                      fit: BoxFit.contain,
                    ),
                  ),
                  Positioned(
                    top: heroHeight * 0.21,
                    left: width * 0.52,
                    child: Image.asset(
                      AppAssets.iconDna,
                      width: width * 0.18,
                      height: heroHeight * 0.13,
                      fit: BoxFit.contain,
                    ),
                  ),
                  Positioned(
                    top: heroHeight * 0.37,
                    right: width * 0.18,
                    child: Image.asset(
                      AppAssets.iconHeartbeat,
                      width: width * 0.14,
                      height: heroHeight * 0.09,
                      fit: BoxFit.contain,
                    ),
                  ),
                  Positioned(
                    top: heroHeight * 0.56,
                    right: width * 0.2,
                    child: Image.asset(
                      AppAssets.iconFirstAid,
                      width: width * 0.15,
                      height: heroHeight * 0.11,
                      fit: BoxFit.contain,
                    ),
                  ),
                  Positioned(
                    right: width * 0.11,
                    bottom: 24,
                    child: _loginLogo(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static Widget _loginLogo() {
    return Image.asset(
      AppAssets.logo,
      width: AppAssets.logoLoginWidth,
      height: AppAssets.logoLoginHeight,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
    );
  }
}

/// Raised home surface: #F5F5F5 + dual drop shadow (quick-action tiles, welcome card).
class FigmaRaisedTapCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double borderRadius;
  final double? height;
  final bool expandHeight;

  const FigmaRaisedTapCard({
    super.key,
    required this.child,
    this.onTap,
    this.borderRadius = AppTheme.quickActionCardRadius,
    this.height,
    this.expandHeight = false,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius);
    final card = Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: radius,
        boxShadow: AppTheme.neumorphicRaised,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: radius,
        child: expandHeight
            ? SizedBox(width: double.infinity, height: double.infinity, child: child)
            : SizedBox(height: height, width: double.infinity, child: child),
      ),
    );

    if (onTap == null) return card;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: card,
      ),
    );
  }
}

class FigmaWelcomeCard extends StatelessWidget {
  final String name;
  final String email;
  final VoidCallback? onTap;

  const FigmaWelcomeCard({super.key, required this.name, required this.email, this.onTap});

  @override
  Widget build(BuildContext context) {
    return FigmaRaisedTapCard(
      height: AppTheme.welcomeCardHeight,
      onTap: onTap,
      child: Padding(
        padding: AppTheme.welcomeCardPadding,
        child: Row(
          children: [
            SizedBox(
              width: 82,
              height: 82,
              child: Center(
                child: Icon(Icons.person_outline, size: 48, color: AppTheme.primaryBlue),
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Willkommen,\n$name',
                    style: FigmaUi.rubik(fontSize: 20, fontWeight: FontWeight.w500, color: AppTheme.textColor, height: 1.2),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    email,
                    style: FigmaUi.rubik(fontSize: 12, fontWeight: FontWeight.w300, color: AppTheme.textColorSecondary),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 18, color: AppTheme.textColorSecondary),
          ],
        ),
      ),
    );
  }
}

/// Figma raised card: #F5F5F5 + dual drop shadow only (`50:661` test results).
class NeumorphicRaisedCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double height;
  final double borderRadius;
  final EdgeInsetsGeometry padding;

  const NeumorphicRaisedCard({
    super.key,
    required this.child,
    this.onTap,
    this.height = AppTheme.testResultCardHeight,
    this.borderRadius = AppTheme.activityCardRadius,
    this.padding = AppTheme.testResultCardPadding,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius);
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: radius,
        boxShadow: AppTheme.neumorphicRaised,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: radius,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          splashFactory: NoSplash.splashFactory,
          highlightColor: Colors.transparent,
          child: SizedBox(
            height: height,
            width: double.infinity,
            child: Padding(padding: padding, child: child),
          ),
        ),
      ),
    );
  }
}

class FigmaQuickActionTile extends StatelessWidget {
  final String? assetPath;
  final IconData? icon;
  final String label;
  final VoidCallback onTap;
  final double iconHeight;

  const FigmaQuickActionTile({
    super.key,
    this.assetPath,
    this.icon,
    required this.label,
    required this.onTap,
    this.iconHeight = 48,
  }) : assert(assetPath != null || icon != null);

  @override
  Widget build(BuildContext context) {
    return FigmaRaisedTapCard(
      expandHeight: true,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 20, 12, 16),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: assetPath != null
                    ? Image.asset(assetPath!, height: iconHeight, fit: BoxFit.contain)
                    : Icon(icon!, size: 40, color: AppTheme.primaryBlue),
              ),
            ),
            Text(
              label,
              textAlign: TextAlign.center,
              style: FigmaUi.rubik(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.textColor),
            ),
          ],
        ),
      ),
    );
  }
}

class FigmaActivityRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const FigmaActivityRow({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FigmaRaisedTapCard(
      height: AppTheme.activityCardHeight,
      onTap: onTap,
      child: Padding(
        padding: AppTheme.activityCardPadding,
        child: Row(
          children: [
            SizedBox(
              width: 38,
              height: 38,
              child: Center(child: Icon(icon, size: 22, color: AppTheme.primaryBlue)),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(title, style: FigmaUi.rubik(fontSize: 15, fontWeight: FontWeight.w500, color: AppTheme.textColor)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: FigmaUi.rubik(fontSize: 13, fontWeight: FontWeight.w300, color: AppTheme.textColorSecondary)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.textColorSecondary),
          ],
        ),
      ),
    );
  }
}

class FigmaListCard extends StatelessWidget {
  final Widget leading;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const FigmaListCard({
    super.key,
    required this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppTheme.neumorphicRaised,
          ),
          padding: const EdgeInsets.all(22),
          child: Row(
            children: [
              leading,
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: FigmaUi.rubik(fontSize: 16, fontWeight: FontWeight.w500, color: AppTheme.textColor)),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(subtitle!, style: FigmaUi.rubik(fontSize: 13, fontWeight: FontWeight.w300, color: AppTheme.textColorSecondary), maxLines: 2, overflow: TextOverflow.ellipsis),
                    ],
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
        ),
      ),
    );
  }
}

class FigmaResultBadge extends StatelessWidget {
  final String label;
  final bool isPositive;

  const FigmaResultBadge({super.key, required this.label, required this.isPositive});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppTheme.resultBadgePadding,
      decoration: BoxDecoration(
        color: isPositive ? AppTheme.resultBadgePositive : AppTheme.resultBadgeNegative,
        borderRadius: BorderRadius.circular(AppTheme.resultBadgeRadius),
      ),
      child: Text(
        label,
        style: FigmaUi.rubik(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.textColor, height: 1.05),
      ),
    );
  }
}

class FigmaSegmentedTabs extends StatelessWidget {
  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const FigmaSegmentedTabs({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 39,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.neumorphicInset,
      ),
      child: Row(
        children: List.generate(labels.length, (i) {
          final selected = i == selectedIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () => onSelected(i),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected ? AppTheme.primaryBlue : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  labels[i],
                  style: FigmaUi.rubik(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: selected ? Colors.white : AppTheme.textColor,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
