part of '../figma_ui.dart';

class LoginHeroBanner extends StatelessWidget {
  final bool isDoctor;

  const LoginHeroBanner({super.key, this.isDoctor = false});

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
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 64),
                      child: Image.asset(
                        isDoctor
                            ? AppAssets.loginDoctor
                            : AppAssets.patientWomanPhone,
                        fit: BoxFit.contain,
                      ),
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
