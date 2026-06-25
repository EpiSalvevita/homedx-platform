import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Scales auth forms down to fit the viewport without scrolling (scale capped at 1.0).
class AuthFormScaler extends StatelessWidget {
  final Widget child;
  final double maxContentWidth;
  final EdgeInsets padding;

  const AuthFormScaler({
    super.key,
    required this.child,
    this.maxContentWidth = 440,
    this.padding = const EdgeInsets.all(24),
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final media = MediaQuery.of(context);
        final viewHeight = media.size.height - media.padding.top - media.padding.bottom;
        final boxHeight = viewHeight - padding.vertical;
        final contentMaxWidth = math.min(
          maxContentWidth,
          constraints.maxWidth - padding.horizontal,
        );

        return Padding(
          padding: padding,
          child: SizedBox(
            height: boxHeight,
            width: constraints.maxWidth,
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.center,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: contentMaxWidth),
                  child: child,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
