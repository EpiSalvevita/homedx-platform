import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../figma_ui.dart';
import 'web_page_header.dart';

/// Mobile: [FigmaScreen] + blue/back header. Web: flat page title (sidebar handles nav).
class AdaptiveScreen extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? bottomBar;
  final VoidCallback? onBack;
  final bool blueTopBar;
  final bool showBackOnMobile;
  final bool showWebHeader;

  const AdaptiveScreen({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.bottomBar,
    this.onBack,
    this.blueTopBar = false,
    this.showBackOnMobile = true,
    this.showWebHeader = true,
  });

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return Scaffold(
        backgroundColor: AppTheme.background,
        bottomNavigationBar: bottomBar,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (showWebHeader)
              WebPageHeader(
                title: title,
                actions: actions,
              ),
            Expanded(child: body),
          ],
        ),
      );
    }

    return FigmaScreen(
      header: FigmaBackHeader(
        title: title,
        actions: actions,
        onBack: onBack,
        blueTopBar: blueTopBar,
        showBack: showBackOnMobile && onBack != null,
      ),
      body: body,
      bottomBar: bottomBar,
    );
  }
}
