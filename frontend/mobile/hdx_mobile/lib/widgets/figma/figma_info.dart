part of '../figma_ui.dart';

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
