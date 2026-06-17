import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/assets/app_assets.dart';
import '../../../app/router/route_paths.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          color: AppColors.screenBase,
          gradient: AppColors.appBackgroundGradient,
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            children: [
              Row(
                children: [
                  IconButton(
                    tooltip: '뒤로 가기',
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                        return;
                      }

                      context.go(RoutePaths.home);
                    },
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Image.asset(
                    AppAssets.logoShape,
                    width: 32,
                    height: 32,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      '설정',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              const _SettingsSection(
                title: '촬영',
                children: [
                  _SettingsTile(
                    icon: Icons.camera_alt_outlined,
                    title: '카메라 권한',
                    subtitle: '상품을 화면에 맞춰 판단할 수 있게 사용합니다.',
                  ),
                  _SettingsTile(
                    icon: Icons.center_focus_strong_rounded,
                    assetPath: AppAssets.pin,
                    title: '촬영 가이드',
                    subtitle: '밝기와 흔들림 안내는 화면 상태에 따라 표시됩니다.',
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              const _SettingsSection(
                title: '음성',
                children: [
                  _SettingsTile(
                    icon: Icons.mic_none_rounded,
                    title: '음성 질문',
                    subtitle: '텍스트 입력 대신 질문을 말할 수 있습니다.',
                  ),
                  _SettingsTile(
                    icon: Icons.volume_up_outlined,
                    title: '음성 안내',
                    subtitle: '판단 결과를 음성으로 안내할 준비 영역입니다.',
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              const _SettingsSection(
                title: '앱 정보',
                children: [
                  _SettingsTile(
                    icon: Icons.info_outline_rounded,
                    assetPath: AppAssets.settings,
                    title: '살래말래',
                    subtitle: '구매 판단을 돕는 참고용 화면입니다.',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: AppSpacing.xs),
          child: Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.cardWhite,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.assetPath,
  });

  final IconData icon;
  final String? assetPath;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: SizedBox.square(
              dimension: 40,
              child: Center(
                child: assetPath == null
                    ? Icon(icon, color: AppColors.primary)
                    : Image.asset(assetPath!, width: 24, height: 24),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
