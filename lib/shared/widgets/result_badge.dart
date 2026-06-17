import 'package:flutter/material.dart';

import '../../app/assets/app_assets.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';
import '../../features/analysis/domain/entities/buy_decision.dart';

class ResultBadge extends StatelessWidget {
  const ResultBadge({required this.decision, this.label, super.key});

  final BuyDecision decision;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final data = _ResultBadgeData.fromDecision(decision, label);

    return Semantics(
      label: data.text,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: data.color.withValues(alpha: 0.12),
          borderRadius: AppRadius.pillShape,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(data.assetPath, width: 24, height: 24),
              const SizedBox(width: AppSpacing.xs),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 160),
                child: Text(
                  data.text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: data.color,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
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

class _ResultBadgeData {
  const _ResultBadgeData({
    required this.text,
    required this.color,
    required this.assetPath,
  });

  final String text;
  final Color color;
  final String assetPath;

  static _ResultBadgeData fromDecision(BuyDecision decision, String? label) {
    return switch (decision) {
      BuyDecision.buy => _ResultBadgeData(
        text: label ?? '사도 좋아요',
        color: AppColors.buy,
        assetPath: AppAssets.sallae,
      ),
      BuyDecision.hold => _ResultBadgeData(
        text: label ?? '조금 더 고민',
        color: AppColors.consider,
        assetPath: AppAssets.gomin,
      ),
      BuyDecision.avoid => _ResultBadgeData(
        text: label ?? '사지 마세요',
        color: AppColors.pass,
        assetPath: AppAssets.mallae,
      ),
      BuyDecision.unknown => _ResultBadgeData(
        text: label ?? '판단 보류',
        color: AppColors.unknown,
        assetPath: AppAssets.gomin,
      ),
    };
  }
}
