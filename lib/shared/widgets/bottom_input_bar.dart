import 'package:flutter/material.dart';

import '../../app/assets/app_assets.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';
import '../../features/analysis/application/analysis_state.dart';
import '../../features/speech_input/data/models/speech_input_state.dart';
import 'icon_circle_button.dart';
import 'segmented_input_mode.dart';

class BottomInputBar extends StatelessWidget {
  const BottomInputBar({
    required this.controller,
    required this.speechState,
    required this.analysisState,
    required this.selectedMode,
    required this.onModeSelected,
    required this.onToggleListening,
    required this.onSubmit,
    super.key,
  });

  final TextEditingController controller;
  final SpeechInputState speechState;
  final AnalysisState analysisState;
  final InputMode selectedMode;
  final ValueChanged<InputMode> onModeSelected;
  final VoidCallback onToggleListening;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.paddingOf(context).bottom;
    final hintText = _hintText;

    return DecoratedBox(
      decoration: const BoxDecoration(color: AppColors.cardWhite),
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 22, 16, 16 + bottomPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 40,
              child: SegmentedInputMode(
                selectedMode: selectedMode,
                onModeSelected: onModeSelected,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: TextField(
                      controller: controller,
                      minLines: 1,
                      maxLines: 1,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => onSubmit(),
                      enabled: !analysisState.isLoading,
                      textAlignVertical: TextAlignVertical.center,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                      decoration: InputDecoration(
                        hintText: selectedMode == InputMode.voice
                            ? hintText
                            : '질문을 입력해 주세요.',
                        prefixIcon: selectedMode == InputMode.voice
                            ? Icon(
                                speechState.isListening
                                    ? Icons.graphic_eq_rounded
                                    : Icons.mic_rounded,
                                color: speechState.isListening
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                                size: 18,
                              )
                            : null,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 18,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.input),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.input),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.input),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                if (selectedMode == InputMode.voice &&
                    controller.text.trim().isEmpty)
                  IconCircleButton(
                    icon: speechState.isListening
                        ? Icons.stop_rounded
                        : Icons.mic_rounded,
                    tooltip: speechState.isListening ? '음성 듣기 중지' : '음성 듣기 시작',
                    onPressed: analysisState.isLoading
                        ? null
                        : onToggleListening,
                    isPrimary: true,
                  )
                else
                  IconCircleButton(
                    icon: analysisState.isLoading
                        ? Icons.hourglass_top_rounded
                        : null,
                    assetPath: analysisState.isLoading ? null : AppAssets.send,
                    tooltip: '질문 보내기',
                    onPressed: analysisState.isLoading ? null : onSubmit,
                    isPrimary: true,
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            _InputStatusText(
              speechState: speechState,
              analysisState: analysisState,
            ),
          ],
        ),
      ),
    );
  }

  String get _inputDisplayText {
    if (controller.text.trim().isNotEmpty) {
      return controller.text;
    }

    if (speechState.lastRecognizedWords.trim().isNotEmpty) {
      return speechState.lastRecognizedWords;
    }

    return '';
  }

  String get _hintText {
    if (speechState.isListening) {
      return '듣고 있습니다. 말씀해 주세요.';
    }

    if (_inputDisplayText.isNotEmpty) {
      return _inputDisplayText;
    }

    return '질문을 말해주세요.';
  }
}

class _InputStatusText extends StatelessWidget {
  const _InputStatusText({
    required this.speechState,
    required this.analysisState,
  });

  final SpeechInputState speechState;
  final AnalysisState analysisState;

  @override
  Widget build(BuildContext context) {
    final message = _statusMessage;
    final color = speechState.errorMessage != null
        ? AppColors.pass
        : AppColors.textSecondary;

    return Semantics(
      liveRegion:
          speechState.isListening ||
          analysisState.status != AnalysisStatus.idle,
      child: Text(
        message,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: color,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String get _statusMessage {
    if (analysisState.status == AnalysisStatus.loading) {
      return '이미지를 분석하고 있습니다.';
    }

    if (analysisState.status == AnalysisStatus.failure &&
        analysisState.errorMessage != null) {
      return '분석 결과를 가져오지 못했어요. 잠시 후 다시 시도해주세요.';
    }

    if (analysisState.status == AnalysisStatus.success) {
      return '분석 결과를 준비했습니다.';
    }

    if (speechState.errorMessage != null) {
      return speechState.errorMessage!;
    }

    if (speechState.isInitializing) {
      return '음성 입력을 준비하고 있습니다.';
    }

    if (!speechState.isAvailable) {
      return '음성 입력을 사용할 수 없으면 텍스트로 입력할 수 있습니다.';
    }

    if (speechState.isListening) {
      return '듣고 있습니다. 질문을 말해주세요.';
    }

    if (speechState.lastRecognizedWords.isNotEmpty &&
        speechState.isFinalResult) {
      return '음성 인식 결과가 질문에 반영되었습니다.';
    }

    return '마이크 버튼으로 말하거나 텍스트로 입력할 수 있습니다.';
  }
}
