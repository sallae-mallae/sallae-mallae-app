import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';

class CameraOverlayElement extends StatelessWidget {
  const CameraOverlayElement({
    required this.child,
    this.backgroundColor,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppSpacing.sm,
      vertical: AppSpacing.xs,
    ),
    super.key,
  });

  final Widget child;
  final Color? backgroundColor;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.textPrimary.withValues(alpha: 0.78),
        borderRadius: AppRadius.pillShape,
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}
