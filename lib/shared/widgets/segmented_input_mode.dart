import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_shadows.dart';

enum InputMode { text, voice }

class SegmentedInputMode extends StatelessWidget {
  const SegmentedInputMode({
    required this.selectedMode,
    required this.onModeSelected,
    super.key,
  });

  final InputMode selectedMode;
  final ValueChanged<InputMode> onModeSelected;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '입력 방식 선택',
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.lightBlueSurface.withValues(alpha: 0.86),
          borderRadius: AppRadius.pillShape,
        ),
        child: Padding(
          padding: const EdgeInsets.all(3),
          child: Stack(
            children: [
              AnimatedAlign(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                alignment: selectedMode == InputMode.text
                    ? Alignment.centerLeft
                    : Alignment.centerRight,
                child: FractionallySizedBox(
                  widthFactor: 0.5,
                  heightFactor: 1,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      boxShadow: AppShadows.floating,
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: _InputModeSegment(
                      label: '텍스트',
                      isSelected: selectedMode == InputMode.text,
                      onTap: () => onModeSelected(InputMode.text),
                    ),
                  ),
                  Expanded(
                    child: _InputModeSegment(
                      label: '음성',
                      isSelected: selectedMode == InputMode.voice,
                      onTap: () => onModeSelected(InputMode.voice),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InputModeSegment extends StatelessWidget {
  const _InputModeSegment({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          height: 34,
          child: Center(
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 160),
              curve: Curves.easeOutCubic,
              style: TextStyle(
                color: isSelected
                    ? AppColors.textInverse
                    : AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
              child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          ),
        ),
      ),
    );
  }
}
