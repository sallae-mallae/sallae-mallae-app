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
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconCircleButton(
              icon: Icons.menu_rounded,
              tooltip: '메뉴 열기',
              onPressed: onMenuPressed,
              shape: IconCircleButtonShape.circle,
            ),
            const Spacer(),
            const _GlassLogo(),
          ],
        ),
      ),
    );
  }
}

class _GlassLogo extends StatelessWidget {
  const _GlassLogo();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.48),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Image.asset(
              AppAssets.logoWord,
              width: 96,
              height: 26,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
