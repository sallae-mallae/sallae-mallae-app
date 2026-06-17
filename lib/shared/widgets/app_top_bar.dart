import 'package:flutter/material.dart';

import '../../app/assets/app_assets.dart';
import '../../app/theme/app_spacing.dart';
import 'icon_circle_button.dart';

class AppTopBar extends StatelessWidget {
  const AppTopBar({this.onMenuPressed, super.key});

  final VoidCallback? onMenuPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
      child: SizedBox(
        height: AppSpacing.topBarHeight,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconCircleButton(
              assetPath: AppAssets.menu,
              tooltip: '메뉴 열기',
              onPressed: onMenuPressed,
            ),
            const Spacer(),
            Image.asset(
              AppAssets.logoWord,
              width: 143,
              height: 48,
              fit: BoxFit.contain,
            ),
          ],
        ),
      ),
    );
  }
}
