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
                  Positioned(
                    left: width * 0.04,
                    bottom: 24,
                    child: Image.asset(
                      isDoctor ? AppAssets.loginDoctor : AppAssets.patientWomanPhone,
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
