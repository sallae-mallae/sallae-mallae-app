import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/assets/app_assets.dart';
import '../../app/router/route_paths.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({required this.width, this.onItemSelected, super.key});

  final double width;
  final VoidCallback? onItemSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: SafeArea(
        bottom: false,
        child: ClipRRect(
          borderRadius: const BorderRadius.horizontal(
            right: Radius.circular(36),
          ),
          child: DecoratedBox(
            decoration: const BoxDecoration(color: AppColors.cardWhite),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 24, 18, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        AppAssets.logoAll,
                        width: 56,
                        fit: BoxFit.contain,
                      ),
                      const Spacer(),
                      _ProfileCircleButton(),
                    ],
                  ),
                  const SizedBox(height: 32),
                  _DrawerTile(
                    icon: Icons.camera_alt_outlined,
                    label: '카메라',
                    onTap: () {
                      onItemSelected?.call();
                      context.go(RoutePaths.home);
                    },
                  ),
                  _DrawerTile(
                    icon: Icons.history_rounded,
                    label: '최근 판단',
                    onTap: () {
                      onItemSelected?.call();
                      context.go(RoutePaths.history);
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    '최근 항목',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.textSecondary.withValues(alpha: 0.72),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const _RecentText('분석 기록은 이후 단계에서 표시됩니다.'),
                  const Spacer(),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Tooltip(
                      message: '설정',
                      child: InkWell(
                        onTap: () {
                          onItemSelected?.call();
                          context.go(RoutePaths.settings);
                        },
                        customBorder: const CircleBorder(),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Image.asset(
                            AppAssets.settings,
                            width: 34,
                            height: 34,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DrawerTile extends StatelessWidget {
  const _DrawerTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: ListTile(
        onTap: onTap,
        minLeadingWidth: 24,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        leading: Icon(icon, color: AppColors.primary),
        title: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _RecentText extends StatelessWidget {
  const _RecentText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: AppColors.textSecondary,
        fontSize: 15,
        height: 1.35,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class _ProfileCircleButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: '프로필',
      child: InkWell(
        onTap: () {},
        customBorder: const CircleBorder(),
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary.withValues(alpha: 0.12),
          ),
          child: const Icon(
            Icons.person_rounded,
            size: 22,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}
