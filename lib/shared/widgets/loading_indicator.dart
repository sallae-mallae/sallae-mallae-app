import 'package:flutter/material.dart';

import '../../app/assets/app_assets.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({required this.message, this.caption, super.key});

  final String message;
  final String? caption;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      label: message,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.cardWhite,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.border),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox.square(
                dimension: 44,
                child: Image(
                  image: AssetImage(AppAssets.logoShape),
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              const SizedBox(
                width: 28,
                child: LinearProgressIndicator(minHeight: 3),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (caption != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  caption!,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
