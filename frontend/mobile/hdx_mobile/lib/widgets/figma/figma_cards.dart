part of '../figma_ui.dart';

/// Raised home surface: #F5F5F5 + dual drop shadow (quick-action tiles, welcome card).
///
/// Tappable instances are keyboard-focusable and show a visible focus/hover
/// ring (web accessibility). The ring is painted as a foreground decoration, so
/// it never changes the card's size or shifts surrounding layout.
class FigmaRaisedTapCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double borderRadius;
  final double? height;
  final bool expandHeight;
  /// Accessibility label announced by screen readers when [onTap] is set.
  final String? semanticLabel;

  const FigmaRaisedTapCard({
    super.key,
    required this.child,
    this.onTap,
    this.borderRadius = AppTheme.quickActionCardRadius,
    this.height,
    this.expandHeight = false,
    this.semanticLabel,
  });

  @override
  State<FigmaRaisedTapCard> createState() => _FigmaRaisedTapCardState();
}

class _FigmaRaisedTapCardState extends State<FigmaRaisedTapCard> {
  bool _hovered = false;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(widget.borderRadius);
    final showRing = _focused || _hovered;

    final card = Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: radius,
        boxShadow: AppTheme.neumorphicRaised,
      ),
      foregroundDecoration: showRing
          ? BoxDecoration(
              borderRadius: radius,
              border: Border.all(
                color: _focused
                    ? AppTheme.focusRing
                    : AppTheme.focusRing.withValues(alpha: 0.45),
                width: AppTheme.focusRingWidth,
              ),
            )
          : null,
      child: Material(
        color: Colors.transparent,
        borderRadius: radius,
        child: widget.expandHeight
            ? SizedBox(width: double.infinity, height: double.infinity, child: widget.child)
            : SizedBox(height: widget.height, width: double.infinity, child: widget.child),
      ),
    );

    if (widget.onTap == null) return card;

    return Semantics(
      button: true,
      label: widget.semanticLabel,
      child: FocusableActionDetector(
        mouseCursor: SystemMouseCursors.click,
        onShowHoverHighlight: (v) => setState(() => _hovered = v),
        onShowFocusHighlight: (v) => setState(() => _focused = v),
        actions: <Type, Action<Intent>>{
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              widget.onTap!();
              return null;
            },
          ),
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          child: card,
        ),
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
                    style: FigmaUi.rubik(fontSize: 22, fontWeight: FontWeight.w600, color: AppTheme.textColor, height: 1.2),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: FigmaUi.rubik(fontSize: 15, fontWeight: FontWeight.w400, color: AppTheme.textColorSecondary),
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
  /// When null, the card hugs [child] height (e.g. single-row list tiles).
  final double? height;
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
          child: height != null
              ? SizedBox(
                  height: height,
                  width: double.infinity,
                  child: Padding(padding: padding, child: child),
                )
              : SizedBox(
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
      semanticLabel: label,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 20, 12, 16),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: assetPath != null
                    ? Image.asset(assetPath!, height: iconHeight, fit: BoxFit.contain)
                    : Icon(icon!, size: 44, color: AppTheme.primaryBlue),
              ),
            ),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: FigmaUi.rubik(fontSize: 16, fontWeight: FontWeight.w500, color: AppTheme.textColor),
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
      semanticLabel: '$title. $subtitle',
      child: Padding(
        padding: AppTheme.activityCardPadding,
        child: Row(
          children: [
            SizedBox(
              width: 40,
              height: 40,
              child: Center(child: Icon(icon, size: 24, color: AppTheme.primaryBlue)),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(title, maxLines: 2, overflow: TextOverflow.ellipsis, style: FigmaUi.rubik(fontSize: 17, fontWeight: FontWeight.w500, color: AppTheme.textColor)),
                  const SizedBox(height: 4),
                  Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis, style: FigmaUi.bodyLight(fontSize: 15, color: AppTheme.textColorSecondary)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: AppTheme.textColorSecondary),
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
