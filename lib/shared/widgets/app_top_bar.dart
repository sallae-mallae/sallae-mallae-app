import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
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
          const Positioned(right: 52, top: 2, child: _OutlinedLogoText()),
          Positioned(
            right: 14,
            top: 8,
            child: _ProfileButton(onPressed: () {}),
          ),
        ],
      ),
    );
  }
}

class _OutlinedLogoText extends StatelessWidget {
  const _OutlinedLogoText();

  @override
  Widget build(BuildContext context) {
    const text = '살래말래?';
    const style = TextStyle(
      fontSize: 23,
      fontWeight: FontWeight.w900,
      letterSpacing: 0,
    );

    return Stack(
      children: [
        Text(
          text,
          maxLines: 1,
          style: style.copyWith(
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 3.6
              ..color = AppColors.cardWhite.withValues(alpha: 0.92),
          ),
        ),
        Text(
          text,
          maxLines: 1,
          style: style.copyWith(color: AppColors.primary),
        ),
      ],
    );
  }
}

class _ProfileButton extends StatelessWidget {
  const _ProfileButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: '프로필',
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.cardWhite.withValues(alpha: 0.72),
            border: Border.all(
              color: AppColors.cardWhite.withValues(alpha: 0.58),
            ),
          ),
          alignment: Alignment.center,
          child: const Text(
            '나',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}
