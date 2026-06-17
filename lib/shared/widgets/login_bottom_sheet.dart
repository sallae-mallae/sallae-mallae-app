import 'package:flutter/material.dart';

import '../../app/assets/app_assets.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';

/// Presents the login bottom sheet.
///
/// This is a presentation-only shell: the action buttons are placeholders and
/// do not perform any authentication yet. The real sign-in flow is wired up in
/// a later step.
Future<void> showLoginBottomSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _LoginBottomSheet(),
  );
}

class _LoginBottomSheet extends StatelessWidget {
  const _LoginBottomSheet();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: AppRadius.sheet,
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
              ),
              const SizedBox(height: 24),
              Image.asset(AppAssets.logoAll, width: 64, fit: BoxFit.contain),
              const SizedBox(height: 16),
              const Text(
                '로그인하고 시작하기',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '분석 기록을 저장하고 어디서나 이어볼 수 있어요.',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 15,
                  height: 1.35,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),
              _LoginButton(
                label: '카카오로 시작하기',
                icon: Icons.chat_bubble_rounded,
                background: const Color(0xFFFEE500),
                foreground: const Color(0xFF1B1D2A),
                onTap: () => Navigator.of(context).pop(),
              ),
              const SizedBox(height: 12),
              _LoginButton(
                label: 'Apple로 시작하기',
                icon: Icons.apple,
                background: const Color(0xFF1B1D2A),
                foreground: AppColors.textInverse,
                onTap: () => Navigator.of(context).pop(),
              ),
              const SizedBox(height: 12),
              _LoginButton(
                label: 'Google로 시작하기',
                icon: Icons.g_mobiledata,
                background: AppColors.cardWhite,
                foreground: AppColors.textPrimary,
                border: const BorderSide(color: AppColors.border),
                onTap: () => Navigator.of(context).pop(),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  '나중에 하기',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoginButton extends StatelessWidget {
  const _LoginButton({
    required this.label,
    required this.icon,
    required this.background,
    required this.foreground,
    required this.onTap,
    this.border,
  });

  final String label;
  final IconData icon;
  final Color background;
  final Color foreground;
  final VoidCallback onTap;
  final BorderSide? border;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(14);

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: Material(
        color: background,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: border ?? BorderSide.none,
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 22, color: foreground),
              const SizedBox(width: 8),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: foreground,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
