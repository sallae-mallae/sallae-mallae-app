import 'dart:ui';

import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';

class IconCircleButton extends StatelessWidget {
  const IconCircleButton({
    required this.tooltip,
    required this.onPressed,
    this.icon,
    this.assetPath,
    this.isPrimary = false,
    super.key,
  }) : assert(icon != null || assetPath != null);

  final IconData? icon;
  final String? assetPath;
  final String tooltip;
  final VoidCallback? onPressed;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    final button = IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: assetPath == null
          ? Icon(icon, size: 22)
          : Image.asset(assetPath!, width: 24, height: 24),
      color: isPrimary ? AppColors.textInverse : AppColors.primary,
      style: IconButton.styleFrom(
        minimumSize: const Size.square(40),
        fixedSize: const Size.square(40),
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
    );

    if (!isPrimary) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.cardWhite.withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: AppColors.cardWhite.withValues(alpha: 0.62),
              ),
            ),
            child: button,
          ),
        ),
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: const [
          BoxShadow(
            color: Color(0x389571FA),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: button,
    );
  }
}
