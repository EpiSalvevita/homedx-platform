import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/app_theme.dart';
import '../utils/app_assets.dart';
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
    return NeumorphicActivityCard(
      height: AppTheme.infoBannerHeight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.infoBannerHorizontalPadding),
        child: Row(
          children: [
            const Icon(Icons.info_outline, color: AppTheme.primaryBlue, size: 21),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: FigmaUi.rubik(fontSize: 14, fontWeight: FontWeight.w400, color: AppTheme.textColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Neumorphic pill input with floating label (login / profile fields).
class NeumorphicInsetField extends StatelessWidget {
  final TextEditingController? controller;
  final String label;
  final String? hint;
  final IconData? prefixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final Widget? suffix;

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
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            NeumorphicInsetSurface(
              child: Theme(
                data: neumorphicFieldTheme(context),
                child: TextFormField(
                  controller: controller,
                  obscureText: obscureText,
                  keyboardType: keyboardType,
                  validator: validator,
                  expands: !obscureText,
                  maxLines: obscureText ? 1 : null,
                  textAlignVertical: TextAlignVertical.center,
                  cursorColor: AppTheme.textColor,
                  style: FigmaUi.rubik(fontSize: 16, fontWeight: FontWeight.w300, color: AppTheme.textColor, height: 1.0),
                  decoration: neumorphicFieldDecoration(
                    hint: hint,
                    prefixIcon: prefixIcon,
                    suffix: suffix,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 38,
              top: -10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.background,
                  borderRadius: BorderRadius.circular(38),
                ),
                child: Text(
                  label,
                  style: FigmaUi.rubik(fontSize: 14, fontWeight: FontWeight.w300, color: AppTheme.primaryBlue),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class NeumorphicPillButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final double height;
  /// When true, uses inset styling (input fields). Default is Figma Large raised button.
  final bool inset;

  const NeumorphicPillButton({
    super.key,
    required this.label,
    this.onPressed,
    this.loading = false,
    this.height = AppTheme.buttonHeightLarge,
    this.inset = false,
  });

  @override
  Widget build(BuildContext context) {
    final labelWidget = loading
        ? const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.textColor),
          )
        : Text(
            label,
            style: FigmaUi.rubik(fontSize: 18, fontWeight: FontWeight.w500, color: AppTheme.textColor),
          );

    if (inset) {
      return NeumorphicInsetSurface(
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: 26),
        alignment: Alignment.center,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: loading ? null : onPressed,
            borderRadius: BorderRadius.circular(AppTheme.pillRadius),
            splashFactory: NoSplash.splashFactory,
            highlightColor: Colors.transparent,
            child: SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: Center(child: labelWidget),
            ),
          ),
        ),
      );
    }

    final enabled = onPressed != null || loading;
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: AppTheme.background,
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
            padding: AppTheme.buttonPaddingLarge,
            child: Center(child: labelWidget),
          ),
        ),
      ),
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

class LoginHeroBanner extends StatelessWidget {
  const LoginHeroBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(24),
        bottomRight: Radius.circular(24),
      ),
      child: Container(
        width: double.infinity,
        height: 412,
        color: AppTheme.surface,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 15,
              bottom: 24,
              child: Image.asset(AppAssets.loginDoctor, height: 280, fit: BoxFit.contain),
            ),
            Positioned(top: 88, left: 215, child: Image.asset(AppAssets.iconDna, width: 72, height: 52)),
            Positioned(top: 151, right: 70, child: Image.asset(AppAssets.iconHeartbeat, width: 56, height: 38)),
            Positioned(top: 233, right: 80, child: Image.asset(AppAssets.iconFirstAid, width: 60, height: 44)),
            Positioned(right: 45, bottom: 24, child: _loginLogo()),
          ],
        ),
      ),
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

class FigmaWelcomeCard extends StatelessWidget {
  final String name;
  final String email;
  final VoidCallback? onTap;

  const FigmaWelcomeCard({super.key, required this.name, required this.email, this.onTap});

  @override
  Widget build(BuildContext context) {
    return NeumorphicActivityCard(
      height: AppTheme.welcomeCardHeight,
      onTap: onTap,
      child: Padding(
        padding: AppTheme.welcomeCardPadding,
        child: Row(
          children: [
            Container(
              width: 82,
              height: 82,
              decoration: BoxDecoration(
                color: AppTheme.background,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.person_outline, size: 32, color: AppTheme.primaryBlue),
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
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(AppTheme.quickActionCardRadius),
        boxShadow: AppTheme.neumorphicRaised,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppTheme.quickActionCardRadius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.quickActionCardRadius),
          splashFactory: NoSplash.splashFactory,
          highlightColor: Colors.transparent,
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
    return NeumorphicActivityCard(
      onTap: onTap,
      child: Padding(
        padding: AppTheme.activityCardPadding,
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppTheme.background,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 22, color: AppTheme.primaryBlue),
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
