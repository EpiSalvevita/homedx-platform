part of '../figma_ui.dart';

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
      style: FigmaUi.rubik(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.textColor),
    );
  }
}
