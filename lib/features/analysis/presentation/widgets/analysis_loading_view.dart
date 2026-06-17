import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../shared/widgets/loading_indicator.dart';

class AnalysisLoadingView extends StatelessWidget {
  const AnalysisLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ColoredBox(
        color: AppColors.cameraScrim,
        child: Center(
          child: Padding(
            padding: AppSpacing.screen,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320),
              child: const LoadingIndicator(
                message: '상품을 분석하고 있어요',
                caption: '사진과 질문을 함께 확인하는 중입니다.',
              ),
            ),
          ),
        ),
      ),
    );
  }
}
