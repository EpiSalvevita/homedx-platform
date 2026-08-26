import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../utils/app_assets.dart';

/// Circular face crop of a no-neck doctor illustration (or a real photo URL).
class DoctorPortraitAvatar extends StatelessWidget {
  final String doctorId;
  final String? doctorName;
  final String? imageUrl;
  final double size;

  const DoctorPortraitAvatar({
    super.key,
    required this.doctorId,
    this.doctorName,
    this.imageUrl,
    this.size = 64,
  });

  @override
  Widget build(BuildContext context) {
    final networkUrl = imageUrl?.trim();
    final hasNetwork = networkUrl != null && networkUrl.isNotEmpty;
    final asset = AppAssets.doctorPortraitFor(doctorId, doctorName: doctorName);

    return Semantics(
      label: 'Arztbild',
      image: true,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppTheme.primaryLight,
          border: Border.all(
            color: AppTheme.accentBlue.withValues(alpha: 0.4),
            width: 1.5,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: EdgeInsets.all(size * 0.06),
          child: hasNetwork
              ? Image.network(
                  networkUrl,
                  fit: BoxFit.contain,
                  alignment: Alignment.center,
                  errorBuilder: (_, __, ___) => _IllustrationFace(asset: asset),
                )
              : _IllustrationFace(asset: asset),
        ),
      ),
    );
  }
}

class _IllustrationFace extends StatelessWidget {
  final String asset;

  const _IllustrationFace({required this.asset});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      asset,
      fit: BoxFit.contain,
      alignment: Alignment.center,
      filterQuality: FilterQuality.medium,
    );
  }
}
