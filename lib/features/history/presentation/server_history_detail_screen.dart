import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/route_paths.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../application/server_history_provider.dart';
import '../data/models/server_history_item.dart';
import 'widgets/history_decision_style.dart';

/// Shows a single server history record, fetching the stored image on open.
class ServerHistoryDetailScreen extends ConsumerStatefulWidget {
  const ServerHistoryDetailScreen({super.key, required this.item});

  final ServerHistoryItem item;

  @override
  ConsumerState<ServerHistoryDetailScreen> createState() =>
      _ServerHistoryDetailScreenState();
}

class _ServerHistoryDetailScreenState
    extends ConsumerState<ServerHistoryDetailScreen> {
  late Future<ServerHistoryItem> _detail;

  @override
  void initState() {
    super.initState();
    _detail = ref.read(historyRemoteDatasourceProvider).detail(widget.item.id);
  }

  void _onBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(RoutePaths.home);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                      onPressed: _onBack,
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
                child: FutureBuilder<ServerHistoryItem>(
                  future: _detail,
                  builder: (context, snapshot) {
                    // Fall back to the list item while the detail loads.
                    final item = snapshot.data ?? widget.item;
                    final loading =
                        snapshot.connectionState == ConnectionState.waiting;
                    return _DetailBody(item: item, loadingImage: loading);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({required this.item, required this.loadingImage});

  final ServerHistoryItem item;
  final bool loadingImage;

  @override
  Widget build(BuildContext context) {
    final style = HistoryDecisionStyle.of(item.decision);
    final label = item.verdictLabel.trim().isEmpty
        ? style.fallbackLabel
        : item.verdictLabel;

    return SingleChildScrollView(
      padding: AppSpacing.screen.add(
        const EdgeInsets.only(bottom: AppSpacing.xl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (item.imageBase64 != null && item.imageBase64!.isNotEmpty)
            ClipRRect(
              borderRadius: AppRadius.card,
              child: Image.memory(
                base64Decode(item.imageBase64!),
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            )
          else if (item.hasImage && loadingImage)
            const SizedBox(
              height: 200,
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            ),
          if ((item.imageBase64 != null && item.imageBase64!.isNotEmpty) ||
              (item.hasImage && loadingImage))
            const SizedBox(height: AppSpacing.md),
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.cardWhite,
              borderRadius: AppRadius.card,
              border: Border.all(color: style.color.withValues(alpha: 0.4)),
            ),
            child: Padding(
              padding: AppSpacing.card,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: style.color,
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
          ),
          const SizedBox(height: AppSpacing.md),
          if (item.question.trim().isNotEmpty)
            _DetailCard(title: '질문', body: item.question),
          if (item.category.trim().isNotEmpty)
            _DetailCard(title: '카테고리', body: item.category),
          if (item.price.trim().isNotEmpty)
            _DetailCard(title: '가격', body: item.price),
          if (item.purpose.trim().isNotEmpty)
            _DetailCard(title: '용도', body: item.purpose),
          if (item.criteria.isNotEmpty)
            _DetailCard(title: '판단 기준', body: item.criteria.join(', ')),
          if (item.reason.trim().isNotEmpty)
            _DetailCard(title: '이렇게 봤어요', body: item.reason),
          if (item.caution.trim().isNotEmpty)
            _DetailCard(title: '주의할 점', body: item.caution),
          if (item.recommendation.trim().isNotEmpty)
            _DetailCard(title: '추천', body: item.recommendation),
        ],
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
