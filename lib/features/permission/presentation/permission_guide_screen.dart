import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/assets/app_assets.dart';
import '../../../app/router/route_paths.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../data/models/permission_state.dart';
import '../domain/permission_provider.dart';

class PermissionGuideScreen extends ConsumerStatefulWidget {
  const PermissionGuideScreen({super.key});

  @override
  ConsumerState<PermissionGuideScreen> createState() =>
      _PermissionGuideScreenState();
}

class _PermissionGuideScreenState extends ConsumerState<PermissionGuideScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(permissionProvider.notifier).checkRequiredPermissions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final permissionState = ref.watch(permissionProvider);
    final isBusy = permissionState.isChecking || permissionState.isRequesting;

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          color: AppColors.screenBase,
          gradient: AppColors.appBackgroundGradient,
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            children: [
              const SizedBox(height: AppSpacing.sm),
              Center(
                child: Image.asset(
                  AppAssets.logoAll,
                  width: 112,
                  height: 124,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                '앱 권한 설정',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '상품을 촬영하고 음성으로 질문하려면 아래 권한이 필요합니다.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.xl),
              _PermissionTile(
                assetPath: AppAssets.firstUseGuideCamera,
                title: '카메라',
                description: '상품 사진을 촬영해 질문에 사용할 때 필요합니다.',
                state: permissionState.camera,
              ),
              const SizedBox(height: AppSpacing.sm),
              _PermissionTile(
                assetPath: AppAssets.firstUseGuideVoice,
                title: '마이크',
                description: '음성 질문을 입력할 때 필요합니다.',
                state: permissionState.microphone,
              ),
              const SizedBox(height: AppSpacing.sm),
              _PermissionTile(
                assetPath: AppAssets.firstUseGuideDecision,
                title: '음성 인식',
                description: '말한 내용을 질문 텍스트로 변환할 때 필요합니다.',
                state: permissionState.speechRecognition,
              ),
              if (permissionState.errorMessage != null) ...[
                const SizedBox(height: AppSpacing.md),
                Text(
                  permissionState.errorMessage!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.pass,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.xl),
              _GuideAssetButton(
                label: isBusy ? '확인 중...' : '권한 요청하기',
                onTap: isBusy
                    ? null
                    : () => ref
                          .read(permissionProvider.notifier)
                          .requestRequiredPermissions(),
              ),
              if (permissionState.hasBlockedPermission) ...[
                const SizedBox(height: AppSpacing.sm),
                OutlinedButton(
                  onPressed: isBusy
                      ? null
                      : () => ref
                            .read(permissionProvider.notifier)
                            .openSettings(),
                  child: const Text('앱 설정 열기'),
                ),
              ],
              if (permissionState.allGranted) ...[
                const SizedBox(height: AppSpacing.sm),
                TextButton(
                  onPressed: () => context.go(RoutePaths.home),
                  child: const Text('시작하기'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _GuideAssetButton extends StatelessWidget {
  const _GuideAssetButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Semantics(
        button: true,
        enabled: onTap != null,
        label: label,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Image.asset(
              AppAssets.firstUseGuideButton,
              width: double.infinity,
              height: 52,
              fit: BoxFit.fill,
            ),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textInverse,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PermissionTile extends StatelessWidget {
  const _PermissionTile({
    required this.assetPath,
    required this.title,
    required this.description,
    required this.state,
  });

  final String assetPath;
  final String title;
  final String description;
  final PermissionItemState state;

  @override
  Widget build(BuildContext context) {
    final policy = _PermissionUiPolicy.fromStatus(state.status);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(assetPath, width: 44, height: 44, fit: BoxFit.contain),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      Text(
                        policy.label,
                        style: TextStyle(
                          color: policy.color,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  if (policy.message != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      policy.message!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PermissionUiPolicy {
  const _PermissionUiPolicy({
    required this.label,
    required this.color,
    this.message,
  });

  final String label;
  final Color color;
  final String? message;

  factory _PermissionUiPolicy.fromStatus(AppPermissionStatus status) {
    return switch (status) {
      AppPermissionStatus.unknown => const _PermissionUiPolicy(
        label: '확인 전',
        color: AppColors.textSecondary,
      ),
      AppPermissionStatus.granted => const _PermissionUiPolicy(
        label: '허용됨',
        color: AppColors.buy,
      ),
      AppPermissionStatus.denied => const _PermissionUiPolicy(
        label: '거부됨',
        color: AppColors.consider,
        message: '다시 권한을 요청할 수 있습니다.',
      ),
      AppPermissionStatus.permanentlyDenied => const _PermissionUiPolicy(
        label: '차단됨',
        color: AppColors.pass,
        message: '기기 설정에서 직접 권한을 허용해야 합니다.',
      ),
      AppPermissionStatus.restricted => const _PermissionUiPolicy(
        label: '제한됨',
        color: AppColors.pass,
        message: '기기 정책 또는 보호자 설정으로 제한되어 있습니다.',
      ),
      AppPermissionStatus.limited => const _PermissionUiPolicy(
        label: '일부 허용',
        color: AppColors.consider,
        message: '일부 기능만 사용할 수 있어 설정 확인이 필요합니다.',
      ),
    };
  }
}
