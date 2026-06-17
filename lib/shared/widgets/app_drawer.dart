import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/assets/app_assets.dart';
import '../../app/router/route_paths.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.cardWhite,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Image.asset(
                    AppAssets.logoShape,
                    width: 44,
                    height: 44,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      '살래말래?',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xxl),
              _DrawerTile(
                icon: Icons.camera_alt_outlined,
                label: '카메라',
                onTap: () {
                  Navigator.of(context).pop();
                  context.go(RoutePaths.home);
                },
              ),
              _DrawerTile(
                icon: Icons.history_rounded,
                label: '최근 판단',
                onTap: () {
                  Navigator.of(context).pop();
                  context.go(RoutePaths.history);
                },
              ),
              _DrawerTile(
                icon: Icons.settings_rounded,
                label: '설정',
                onTap: () {
                  Navigator.of(context).pop();
                  context.go(RoutePaths.settings);
                },
              ),
              const Spacer(),
              Text(
                '분석 기록 저장과 계정 기능은 이후 단계에서 연결됩니다.',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
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
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
