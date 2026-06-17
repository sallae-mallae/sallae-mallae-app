import 'package:flutter/material.dart';

import '../../../../app/assets/app_assets.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';

class PurchaseThinkingCard extends StatelessWidget {
  const PurchaseThinkingCard({super.key});

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
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.asset(
                  AppAssets.thinkingCheck,
                  width: 28,
                  height: 28,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    '구매 전에 한번만 생각해볼까요?',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            const _ThinkingStep(
              assetPath: AppAssets.thinkingStep1,
              text: '지금 꼭 필요한 상품인지 확인해요.',
            ),
            const SizedBox(height: AppSpacing.sm),
            const _ThinkingStep(
              assetPath: AppAssets.thinkingStep2,
              text: '이미 비슷한 물건이 있는지 떠올려요.',
            ),
            const SizedBox(height: AppSpacing.sm),
            const _ThinkingStep(
              assetPath: AppAssets.thinkingStep3,
              text: '예산 안에서 괜찮은 선택인지 살펴요.',
            ),
          ],
        ),
      ),
    );
  }
}

class _ThinkingStep extends StatelessWidget {
  const _ThinkingStep({required this.assetPath, required this.text});

  final String assetPath;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Image.asset(assetPath, width: 32, height: 32, fit: BoxFit.contain),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
