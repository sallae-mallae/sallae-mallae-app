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
    final child = IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: assetPath == null
          ? Icon(icon, size: 22)
          : Image.asset(assetPath!, width: 24, height: 24),
      color: isPrimary ? AppColors.textInverse : AppColors.primary,
      style: IconButton.styleFrom(
        minimumSize: const Size.square(40),
        fixedSize: const Size.square(40),
        backgroundColor: isPrimary ? null : AppColors.cardWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
    );

    if (!isPrimary) {
      return child;
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
      child: child,
    );
  }
}
