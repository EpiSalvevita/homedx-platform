import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../config/app_theme.dart';
import '../widgets/figma_ui.dart';
import '../widgets/neumorphic.dart';
import '../l10n/l10n_ext.dart';

/// Placeholder for Cube/Bluetooth flows on Flutter web until Web Bluetooth is implemented.
class CubeWebStubScreen extends StatelessWidget {
  final String title;
  final String? message;

  const CubeWebStubScreen({
    super.key,
    required this.title,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    final body = message ?? context.l10n.cubeWebStubMessage;

    return FigmaScreen(
      header: FigmaBackHeader(title: title),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.screenHorizontalPadding),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.phone_android_outlined,
                  size: 64,
                  color: AppTheme.primaryBlue,
                ),
                const SizedBox(height: 24),
                Text(
                  body,
                  textAlign: TextAlign.center,
                  style: FigmaUi.rubik(
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.textColor,
                  ),
                ),
                const SizedBox(height: 32),
                NeumorphicButton(
                  isPrimary: true,
                  onPressed: () => context.go('/home'),
                  child: Text(
                    context.l10n.btGoToHome,
                    style: FigmaUi.rubik(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                NeumorphicButton(
                  onPressed: () => context.pop(),
                  child: Text(
                    context.l10n.btBack,
                    style: FigmaUi.rubik(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
