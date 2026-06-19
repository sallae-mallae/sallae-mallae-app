import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../analysis/domain/entities/buy_decision.dart';
import '../../application/server_history_provider.dart';
import '../../data/models/server_history_item.dart';
import '../server_history_detail_screen.dart';
import 'history_decision_style.dart';

const _verdictFilters = <({String label, String? value})>[
  (label: '전체', value: null),
  (label: '살래', value: 'buy'),
  (label: '애매', value: 'maybe'),
  (label: '말래', value: 'no'),
];

/// Server-backed history list with verdict filters, paging and swipe-to-delete.
class ServerHistoryView extends ConsumerWidget {
  const ServerHistoryView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(serverHistoryProvider);
    final notifier = ref.read(serverHistoryProvider.notifier);

    return Column(
      children: [
        _FilterBar(selected: state.verdict, onSelected: notifier.setVerdict),
        Expanded(
          child: _Body(state: state, notifier: notifier),
        ),
      ],
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.state, required this.notifier});

  final ServerHistoryState state;
  final ServerHistoryNotifier notifier;

  @override
  Widget build(BuildContext context) {
    if (state.isLoading && state.items.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (state.hasError && state.items.isEmpty) {
      return const _HistoryMessage(message: '기록을 불러오지 못했어요.');
    }

    if (state.items.isEmpty) {
      return const _HistoryMessage(message: '아직 저장된 판단 기록이 없어요.');
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: notifier.refresh,
      child: ListView.separated(
        padding: AppSpacing.screen.add(
          const EdgeInsets.symmetric(vertical: AppSpacing.md),
        ),
        itemCount: state.items.length + (state.hasMore ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (context, index) {
          if (index >= state.items.length) {
            return _LoadMoreButton(
              isLoading: state.isLoadingMore,
              onPressed: notifier.loadMore,
            );
          }

          final item = state.items[index];
          return Dismissible(
            key: ValueKey(item.id),
            direction: DismissDirection.endToStart,
            background: const _DeleteBackground(),
            onDismissed: (_) => notifier.delete(item.id),
            child: _ServerHistoryCard(item: item),
          );
        },
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.selected, required this.onSelected});

  final String? selected;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.screen.add(const EdgeInsets.only(top: AppSpacing.sm)),
      child: Row(
        children: [
          for (final filter in _verdictFilters)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.xs),
              child: _FilterChip(
                label: filter.label,
                selected: selected == filter.value,
                onTap: () => onSelected(filter.value),
              ),
            ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.cardWhite,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? AppColors.textInverse : AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _ServerHistoryCard extends StatelessWidget {
  const _ServerHistoryCard({required this.item});

  final ServerHistoryItem item;

  @override
  Widget build(BuildContext context) {
    final style = HistoryDecisionStyle.of(item.decision);
    final label =
        item.decision.forcedLabel ??
        (item.verdictLabel.trim().isEmpty
            ? style.fallbackLabel
            : item.verdictLabel);

    return Material(
      color: AppColors.cardWhite,
      borderRadius: AppRadius.card,
      child: InkWell(
        borderRadius: AppRadius.card,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => ServerHistoryDetailScreen(item: item),
          ),
        ),
        child: Padding(
          padding: AppSpacing.card,
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: style.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                alignment: Alignment.center,
                child: style.assetPath == null
                    ? Icon(style.fallbackIcon, color: style.color, size: 24)
                    : Image.asset(
                        style.assetPath!,
                        width: 28,
                        height: 28,
                        fit: BoxFit.contain,
                      ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: style.color,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (item.question.trim().isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        item.question,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                    const SizedBox(height: 2),
                    Text(
                      _formatDate(item.createdAt),
                      style: const TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadMoreButton extends StatelessWidget {
  const _LoadMoreButton({required this.isLoading, required this.onPressed});

  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              )
            : const Text(
                '더 보기',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
      ),
    );
  }
}

class _DeleteBackground extends StatelessWidget {
  const _DeleteBackground();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.pass,
        borderRadius: AppRadius.card,
      ),
      child: const Align(
        alignment: Alignment.centerRight,
        child: Padding(
          padding: EdgeInsets.only(right: AppSpacing.lg),
          child: Icon(
            Icons.delete_outline_rounded,
            color: AppColors.textInverse,
          ),
        ),
      ),
    );
  }
}

class _HistoryMessage extends StatelessWidget {
  const _HistoryMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.screen,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.history_rounded,
              size: 56,
              color: AppColors.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
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
