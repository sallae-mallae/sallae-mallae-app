import 'dart:ui';

import 'package:flutter/material.dart';

import '../../app/assets/app_assets.dart';
import '../../app/theme/app_spacing.dart';
import 'icon_circle_button.dart';

class AppTopBar extends StatelessWidget {
  const AppTopBar({this.onMenuPressed, super.key});

  final VoidCallback? onMenuPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSpacing.topBarHeight + 10,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 16,
            top: 8,
            child: IconCircleButton(
              icon: Icons.menu_rounded,
              tooltip: '메뉴 열기',
              onPressed: onMenuPressed,
              shape: IconCircleButtonShape.circle,
            ),
          ),
          const Positioned(right: 18, top: 4, child: _GlassLogo()),
        ],
      ),
    );
  }
}

class _GlassLogo extends StatelessWidget {
  const _GlassLogo();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.48),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white.withValues(alpha: 0.52)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Image.asset(
              AppAssets.logoWord,
              width: 118,
              height: 32,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
