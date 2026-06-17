import 'package:flutter/material.dart';

import '../../app/assets/app_assets.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';

enum AppDrawerSection { camera, history }

class AppDrawer extends StatelessWidget {
  const AppDrawer({
    required this.width,
    this.selectedSection = AppDrawerSection.camera,
    this.onSectionSelected,
    this.onOpenSettings,
    this.onOpenProfile,
    super.key,
  });

  final double width;
  final AppDrawerSection selectedSection;
  final ValueChanged<AppDrawerSection>? onSectionSelected;
  final VoidCallback? onOpenSettings;
  final VoidCallback? onOpenProfile;

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
          child: Material(
            color: AppColors.cardWhite,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 0, 18, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: AppSpacing.topBarHeight + 10,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            AppAssets.logoAll,
                            width: 52,
                            fit: BoxFit.contain,
                          ),
                          const Spacer(),
                          _ProfileCircleButton(onTap: onOpenProfile),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _DrawerTile(
                    icon: Icons.camera_alt_outlined,
                    label: '카메라',
                    selected: selectedSection == AppDrawerSection.camera,
                    onTap: () =>
                        onSectionSelected?.call(AppDrawerSection.camera),
                  ),
                  _DrawerTile(
                    icon: Icons.history_rounded,
                    label: '최근 판단',
                    selected: selectedSection == AppDrawerSection.history,
                    onTap: () =>
                        onSectionSelected?.call(AppDrawerSection.history),
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
                        onTap: onOpenSettings,
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
    this.selected = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: ListTile(
        onTap: onTap,
        selected: selected,
        selectedTileColor: AppColors.primary.withValues(alpha: 0.10),
        selectedColor: AppColors.primary,
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
  const _ProfileCircleButton({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: '프로필',
      child: InkWell(
        onTap: onTap,
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
