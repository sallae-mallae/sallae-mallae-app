import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../app/assets/app_assets.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../domain/entities/analysis_result.dart';
import '../../domain/entities/buy_decision.dart';

/// Displays a completed analysis result: the verdict headline, the supporting
/// reason/caution/recommendation, the detailed caption and whether reference
/// information was used.
class AnalysisResultView extends StatelessWidget {
  const AnalysisResultView({
    super.key,
    required this.result,
    required this.onClose,
    this.imagePath,
    this.topPadding = AppSpacing.topBarHeight + AppSpacing.xs,
    this.closeLabel = '다시 촬영하기',
  });

  final AnalysisResult result;
  final VoidCallback onClose;

  /// Path of the captured photo, shown as a small thumbnail when available.
  final String? imagePath;

  /// Space reserved above the content. Defaults to leaving room for the camera
  /// top bar when shown as a full overlay; pass a small value in a sheet.
  final double topPadding;
  final String closeLabel;

  @override
  Widget build(BuildContext context) {
    final style = _DecisionStyle.of(result.decision);

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.screenBase,
        gradient: AppColors.appBackgroundGradient,
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.only(top: topPadding),
          child: SingleChildScrollView(
            padding: AppSpacing.screen.add(
              const EdgeInsets.only(bottom: AppSpacing.xl),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _VerdictHeader(style: style, result: result),
                const SizedBox(height: AppSpacing.md),
                if (imagePath != null && File(imagePath!).existsSync()) ...[
                  ClipRRect(
                    borderRadius: AppRadius.card,
                    child: Image.file(
                      File(imagePath!),
                      width: double.infinity,
                      height: 180,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
                if (result.productInfo.trim().isNotEmpty) ...[
                  _ResultCard(
                    icon: Icons.shopping_bag_outlined,
                    accent: AppColors.textSecondary,
                    title: '상품 정보',
                    body: result.productInfo,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
                if (result.reason.trim().isNotEmpty)
                  _ResultCard(
                    icon: Icons.lightbulb_outline_rounded,
                    accent: style.color,
                    title: '이렇게 봤어요',
                    body: result.reason,
                  ),
                if (result.pros.trim().isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.sm),
                  _ResultCard(
                    icon: Icons.thumb_up_outlined,
                    accent: AppColors.buy,
                    title: '장점',
                    body: result.pros,
                  ),
                ],
                if (result.cons.trim().isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.sm),
                  _ResultCard(
                    icon: Icons.thumb_down_outlined,
                    accent: AppColors.pass,
                    title: '단점',
                    body: result.cons,
                  ),
                ],
                if (result.caution.trim().isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.sm),
                  _ResultCard(
                    icon: Icons.error_outline_rounded,
                    accent: AppColors.consider,
                    title: '주의할 점',
                    body: result.caution,
                  ),
                ],
                if (result.recommendation.trim().isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.sm),
                  _ResultCard(
                    icon: Icons.recommend_outlined,
                    accent: AppColors.primary,
                    title: '추천',
                    body: result.recommendation,
                  ),
                ],
                if (result.ragUsed) ...[
                  const SizedBox(height: AppSpacing.md),
                  const _RagBadge(),
                ],
                const SizedBox(height: AppSpacing.lg),
                _CloseButton(onClose: onClose, label: closeLabel),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _VerdictHeader extends StatelessWidget {
  const _VerdictHeader({required this.style, required this.result});

  final _DecisionStyle style;
  final AnalysisResult result;

  @override
  Widget build(BuildContext context) {
    final label = result.verdictLabel.trim().isEmpty
        ? style.fallbackLabel
        : result.verdictLabel;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: AppRadius.card,
        border: Border.all(color: style.color.withValues(alpha: 0.4)),
      ),
      child: Padding(
        padding: AppSpacing.card,
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: style.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              alignment: Alignment.center,
              child: style.assetPath == null
                  ? Icon(style.fallbackIcon, color: style.color, size: 30)
                  : Image.asset(
                      style.assetPath!,
                      width: 36,
                      height: 36,
                      fit: BoxFit.contain,
                    ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                label,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: style.color,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  height: 1.25,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({
    required this.icon,
    required this.accent,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final Color accent;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: AppRadius.card,
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: AppSpacing.card,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: accent, size: 20),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  title,
                  style: TextStyle(
                    color: accent,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              body,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
                height: 1.45,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RagBadge extends StatelessWidget {
  const _RagBadge();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.lavender,
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: const Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xxs,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.menu_book_rounded, size: 16, color: AppColors.primary),
              SizedBox(width: AppSpacing.xxs),
              Text(
                '참고 정보를 활용했어요',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 13,
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

class _CloseButton extends StatelessWidget {
  const _CloseButton({required this.onClose, required this.label});

  final VoidCallback onClose;
  final String label;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onClose,
      style: TextButton.styleFrom(
        backgroundColor: AppColors.cardWhite,
        foregroundColor: AppColors.textPrimary,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.card,
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _DecisionStyle {
  const _DecisionStyle({
    required this.color,
    required this.assetPath,
    required this.fallbackIcon,
    required this.fallbackLabel,
  });

  final Color color;
  final String? assetPath;
  final IconData fallbackIcon;
  final String fallbackLabel;

  static _DecisionStyle of(BuyDecision decision) {
    return switch (decision) {
      BuyDecision.buy => const _DecisionStyle(
        color: AppColors.buy,
        assetPath: AppAssets.sallae,
        fallbackIcon: Icons.check_circle_rounded,
        fallbackLabel: '사도 좋아요',
      ),
      BuyDecision.hold => const _DecisionStyle(
        color: AppColors.consider,
        assetPath: AppAssets.gomin,
        fallbackIcon: Icons.help_rounded,
        fallbackLabel: '조금 더 고민해봐요',
      ),
      BuyDecision.avoid => const _DecisionStyle(
        color: AppColors.pass,
        assetPath: AppAssets.mallae,
        fallbackIcon: Icons.do_not_disturb_on_rounded,
        fallbackLabel: '이번엔 참아봐요',
      ),
      BuyDecision.unknown => const _DecisionStyle(
        color: AppColors.unknown,
        assetPath: null,
        fallbackIcon: Icons.search_rounded,
        fallbackLabel: '조금 더 살펴봐야 해요',
      ),
    };
  }
}
