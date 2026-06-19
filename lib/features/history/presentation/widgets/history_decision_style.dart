import 'package:flutter/material.dart';

import '../../../../app/assets/app_assets.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../analysis/domain/entities/buy_decision.dart';

/// Color, icon and fallback label used to present a [BuyDecision] in history.
class HistoryDecisionStyle {
  const HistoryDecisionStyle({
    required this.color,
    required this.assetPath,
    required this.fallbackIcon,
    required this.fallbackLabel,
  });

  final Color color;
  final String? assetPath;
  final IconData fallbackIcon;
  final String fallbackLabel;

  static HistoryDecisionStyle of(BuyDecision decision) {
    return switch (decision) {
      BuyDecision.buy => const HistoryDecisionStyle(
        color: AppColors.buy,
        assetPath: AppAssets.sallae,
        fallbackIcon: Icons.check_circle_rounded,
        fallbackLabel: '사도 좋아요',
      ),
      BuyDecision.hold => const HistoryDecisionStyle(
        color: AppColors.consider,
        assetPath: AppAssets.gomin,
        fallbackIcon: Icons.help_rounded,
        fallbackLabel: '애매하긴해',
      ),
      BuyDecision.avoid => const HistoryDecisionStyle(
        color: AppColors.pass,
        assetPath: AppAssets.mallae,
        fallbackIcon: Icons.do_not_disturb_on_rounded,
        fallbackLabel: '이번엔 참아봐요',
      ),
      BuyDecision.unknown => const HistoryDecisionStyle(
        color: AppColors.unknown,
        assetPath: null,
        fallbackIcon: Icons.search_rounded,
        fallbackLabel: '조금 더 살펴봐야 해요',
      ),
    };
  }
}
