import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../domain/entities/analysis_result.dart';

/// A single message in the camera chat thread.
class ChatMessage {
  const ChatMessage._({
    required this.isUser,
    required this.text,
    this.result,
    this.imagePath,
    this.isError = false,
  });

  const ChatMessage.user(String text) : this._(isUser: true, text: text);

  const ChatMessage.ai(
    String text, {
    AnalysisResult? result,
    String? imagePath,
    bool isError = false,
  }) : this._(
         isUser: false,
         text: text,
         result: result,
         imagePath: imagePath,
         isError: isError,
       );

  final bool isUser;
  final String text;

  /// Present on an AI verdict message so the UI can offer a "자세히" detail view.
  final AnalysisResult? result;

  /// Path of the captured photo for this verdict, shown in the detail view.
  final String? imagePath;

  /// Set on an AI message that reports a failure, so the UI can offer a retry.
  final bool isError;
}

/// Chat-style transcript shown over the camera: the user's questions rise as
/// bubbles, a typing indicator shows while the AI is thinking, and the AI
/// replies with a one-line verdict that can be expanded for detail.
class AnalysisChatView extends StatefulWidget {
  const AnalysisChatView({
    super.key,
    required this.messages,
    required this.isThinking,
    required this.onShowDetail,
    required this.onRetry,
  });

  final List<ChatMessage> messages;
  final bool isThinking;
  final void Function(AnalysisResult result, String? imagePath) onShowDetail;
  final VoidCallback onRetry;

  @override
  State<AnalysisChatView> createState() => _AnalysisChatViewState();
}

class _AnalysisChatViewState extends State<AnalysisChatView> {
  final ScrollController _controller = ScrollController();

  @override
  void didUpdateWidget(covariant AnalysisChatView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.messages.length != oldWidget.messages.length ||
        widget.isThinking != oldWidget.isThinking) {
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_controller.hasClients) {
        return;
      }
      _controller.animateTo(
        _controller.position.maxScrollExtent,
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final itemCount = widget.messages.length + (widget.isThinking ? 1 : 0);

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 250),
      // Dim slightly when idle so the camera stays visible for framing the next
      // shot; keep it solid while the AI is actively responding.
      opacity: widget.isThinking ? 1.0 : 0.9,
      child: ListView.builder(
        controller: _controller,
        padding: AppSpacing.screen.add(
          const EdgeInsets.symmetric(vertical: AppSpacing.md),
        ),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          if (index >= widget.messages.length) {
            return const _BubbleEntrance(
              key: ValueKey('typing'),
              alignment: Alignment.centerLeft,
              child: _TypingBubble(),
            );
          }

          final message = widget.messages[index];
          return _BubbleEntrance(
            key: ValueKey(index),
            alignment: message.isUser
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: _MessageBubble(
              message: message,
              onShowDetail: widget.onShowDetail,
              onRetry: widget.onRetry,
            ),
          );
        },
      ),
    );
  }
}

/// Slides a bubble up with a fade the first time it appears.
class _BubbleEntrance extends StatefulWidget {
  const _BubbleEntrance({
    super.key,
    required this.alignment,
    required this.child,
  });

  final Alignment alignment;
  final Widget child;

  @override
  State<_BubbleEntrance> createState() => _BubbleEntranceState();
}

class _BubbleEntranceState extends State<_BubbleEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 280),
  )..forward();

  late final Animation<double> _fade = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOut,
  );

  late final Animation<Offset> _slide = Tween<Offset>(
    begin: const Offset(0, 0.18),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Align(
        alignment: widget.alignment,
        child: FadeTransition(
          opacity: _fade,
          child: SlideTransition(position: _slide, child: widget.child),
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.message,
    required this.onShowDetail,
    required this.onRetry,
  });

  final ChatMessage message;
  final void Function(AnalysisResult result, String? imagePath) onShowDetail;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final result = message.result;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.sizeOf(context).width * 0.78,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: isUser
              ? AppColors.primary.withValues(alpha: 0.88)
              : AppColors.cardWhite.withValues(alpha: 0.86),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(AppRadius.lg),
            topRight: const Radius.circular(AppRadius.lg),
            bottomLeft: Radius.circular(isUser ? AppRadius.lg : AppRadius.xs),
            bottomRight: Radius.circular(isUser ? AppRadius.xs : AppRadius.lg),
          ),
          border: isUser ? null : Border.all(color: AppColors.border),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isUser && result != null) ...[
                Text(
                  result.verdictLabel.trim().isEmpty
                      ? '판단을 마쳤어요.'
                      : result.verdictLabel.trim(),
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    height: 1.3,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (result.recommendation.trim().isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    result.recommendation.trim(),
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      height: 1.4,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ] else
                Text(
                  message.text,
                  style: TextStyle(
                    color: isUser
                        ? AppColors.textInverse
                        : AppColors.textPrimary,
                    fontSize: 15,
                    height: 1.4,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              if (result != null) ...[
                const SizedBox(height: AppSpacing.xs),
                GestureDetector(
                  onTap: () => onShowDetail(result, message.imagePath),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text(
                        '자세히',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 18,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ],
              if (message.isError) ...[
                const SizedBox(height: AppSpacing.xs),
                GestureDetector(
                  onTap: onRetry,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(
                        Icons.refresh_rounded,
                        size: 18,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: 2),
                      Text(
                        '다시 시도',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// "..." bubble whose dots bob up and down while the AI is generating.
class _TypingBubble extends StatefulWidget {
  const _TypingBubble();

  @override
  State<_TypingBubble> createState() => _TypingBubbleState();
}

class _TypingBubbleState extends State<_TypingBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1000),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.cardWhite.withValues(alpha: 0.86),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppRadius.lg),
          topRight: Radius.circular(AppRadius.lg),
          bottomLeft: Radius.circular(AppRadius.xs),
          bottomRight: Radius.circular(AppRadius.lg),
        ),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm + 2,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            return Padding(
              padding: EdgeInsets.only(right: index == 2 ? 0 : 6),
              child: _TypingDot(controller: _controller, index: index),
            );
          }),
        ),
      ),
    );
  }
}

class _TypingDot extends StatelessWidget {
  const _TypingDot({required this.controller, required this.index});

  final AnimationController controller;
  final int index;

  @override
  Widget build(BuildContext context) {
    final start = index * 0.2;
    final animation =
        TweenSequence<double>([
          TweenSequenceItem(tween: Tween(begin: 0, end: -4), weight: 1),
          TweenSequenceItem(tween: Tween(begin: -4, end: 0), weight: 1),
        ]).animate(
          CurvedAnimation(
            parent: controller,
            curve: Interval(start, start + 0.6, curve: Curves.easeInOut),
          ),
        );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, animation.value),
          child: child,
        );
      },
      child: Container(
        width: 7,
        height: 7,
        decoration: const BoxDecoration(
          color: AppColors.textTertiary,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
