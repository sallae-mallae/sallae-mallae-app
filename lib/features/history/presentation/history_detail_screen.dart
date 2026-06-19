import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/route_paths.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../analysis/domain/entities/buy_decision.dart';
import '../domain/entities/history_item.dart';
import 'widgets/history_decision_style.dart';

/// Shows the full saved detail for a single history item.
class HistoryDetailScreen extends StatelessWidget {
  const HistoryDetailScreen({super.key, required this.item});

  final HistoryItem item;

  void _onBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(RoutePaths.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = HistoryDecisionStyle.of(item.decision);
    final imagePath = item.imagePath;
    final hasImage = imagePath != null && File(imagePath).existsSync();

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          color: AppColors.screenBase,
          gradient: AppColors.appBackgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 20, 8),
                child: Row(
                  children: [
                    IconButton(
                      tooltip: '뒤로 가기',
                      onPressed: () => _onBack(context),
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: AppColors.textPrimary,
                        size: 20,
                      ),
                    ),
                    const Text(
                      '분석 기록',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: AppSpacing.screen.add(
                    const EdgeInsets.only(bottom: AppSpacing.xl),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (hasImage) ...[
                        ClipRRect(
                          borderRadius: AppRadius.card,
                          child: Image.file(
                            File(imagePath),
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                      ],
                      _Header(item: item, color: style.color),
                      const SizedBox(height: AppSpacing.md),
                      if (item.question.trim().isNotEmpty)
                        _DetailCard(title: '질문', body: item.question),
                      if (item.productInfo.trim().isNotEmpty)
                        _DetailCard(title: '상품 정보', body: item.productInfo),
                      if (item.reason.trim().isNotEmpty)
                        _DetailCard(title: '이렇게 봤어요', body: item.reason),
                      if (item.pros.trim().isNotEmpty)
                        _DetailCard(title: '장점', body: item.pros),
                      if (item.cons.trim().isNotEmpty)
                        _DetailCard(title: '단점', body: item.cons),
                      if (item.caution.trim().isNotEmpty)
                        _DetailCard(title: '주의할 점', body: item.caution),
                      if (item.recommendation.trim().isNotEmpty)
                        _DetailCard(title: '추천', body: item.recommendation),
                      if (item.ocrCandidates.isNotEmpty)
                        _DetailCard(
                          title: '인식된 텍스트',
                          body: item.ocrCandidates.join(', '),
                        ),
                      _DetailCard(
                        title: '품질 점수',
                        body: item.qualityScore.toStringAsFixed(2),
                      ),
                      if (item.ragUsed)
                        const _DetailCard(
                          title: '참고 정보',
                          body: '참고 정보를 활용했어요.',
                        ),
                    ],
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

class _Header extends StatelessWidget {
  const _Header({required this.item, required this.color});

  final HistoryItem item;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final label =
        item.decision.forcedLabel ??
        (item.verdictLabel.trim().isEmpty
            ? HistoryDecisionStyle.of(item.decision).fallbackLabel
            : item.verdictLabel);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: AppRadius.card,
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Padding(
        padding: AppSpacing.card,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 19,
                fontWeight: FontWeight.w900,
                height: 1.25,
              ),
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              _formatDate(item.createdAt),
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: DecoratedBox(
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
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
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
      ),
    );
  }
}

String _formatDate(DateTime date) {
  final local = date.toLocal();
  String two(int value) => value.toString().padLeft(2, '0');
  return '${local.year}.${two(local.month)}.${two(local.day)} '
      '${two(local.hour)}:${two(local.minute)}';
}
