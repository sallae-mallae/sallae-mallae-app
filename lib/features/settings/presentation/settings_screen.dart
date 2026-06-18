import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/assets/app_assets.dart';
import '../../../app/router/route_paths.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../shared/widgets/primary_action_button.dart';
import '../../voice_output/data/models/tts_voice.dart';
import '../../voice_output/domain/voice_output_provider.dart';
import '../application/app_settings_provider.dart';
import '../domain/app_settings.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  static const _inputModes = ['텍스트', '음성'];

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(voiceOutputProvider.notifier).initialize());
  }

  void _onDone() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(RoutePaths.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final voiceState = ref.watch(voiceOutputProvider);
    final settings = ref.watch(appSettingsProvider);
    final settingsNotifier = ref.read(appSettingsProvider.notifier);

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          color: AppColors.screenBase,
          gradient: AppColors.appBackgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                  children: [
                    Center(
                      child: Image.asset(
                        AppAssets.settings,
                        width: 44,
                        height: 44,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Center(
                      child: Text(
                        '설정',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    _SettingsCard(
                      children: [
                        _SettingsRow(
                          label: '기본 입력 방식',
                          trailing: _InputModeDropdown(
                            value:
                                settings.defaultInputMode == AppInputMode.voice
                                ? '음성'
                                : '텍스트',
                            values: _inputModes,
                            onChanged: (value) =>
                                settingsNotifier.setDefaultInputMode(
                                  value == '음성'
                                      ? AppInputMode.voice
                                      : AppInputMode.text,
                                ),
                          ),
                        ),
                        const _RowDivider(),
                        _SettingsRow(
                          label: '음성 자동 전송',
                          trailing: Switch.adaptive(
                            value: settings.voiceAutoSend,
                            activeColor: AppColors.primary,
                            onChanged: settingsNotifier.setVoiceAutoSend,
                          ),
                        ),
                        const _RowDivider(),
                        _SettingsRow(
                          label: '사진 서버 저장',
                          trailing: Switch.adaptive(
                            value: settings.photoServerSave,
                            activeColor: AppColors.primary,
                            onChanged: settingsNotifier.setPhotoServerSave,
                          ),
                        ),
                        const _RowDivider(),
                        _SettingsRow(
                          label: 'Pro Mode',
                          trailing: Switch.adaptive(
                            value: settings.proMode,
                            activeColor: AppColors.primary,
                            onChanged: settingsNotifier.setProMode,
                          ),
                        ),
                        const _RowDivider(),
                        _SettingsRow(
                          label: 'TTS 음성',
                          trailing: _VoiceDropdown(
                            voices: voiceState.availableVoices,
                            selected: voiceState.selectedVoice,
                            onChanged: (voice) => ref
                                .read(voiceOutputProvider.notifier)
                                .selectVoice(voice),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _SettingsCard(
                      children: [
                        const _SettingsRow(
                          label: 'AI 모델',
                          trailing: _ValueText('빠른 판단'),
                        ),
                        const _RowDivider(),
                        _SettingsRow(
                          label: '사진/개인정보 안내',
                          trailing: const _ValueText('보기'),
                          onTap: () {},
                        ),
                        const _RowDivider(),
                        const _SettingsRow(
                          label: '앱 버전',
                          trailing: _ValueText('0.1 firstui'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
                child: PrimaryActionButton(label: '완료', onPressed: _onDone),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({required this.label, required this.trailing, this.onTap});

  final String label;
  final Widget trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          trailing,
        ],
      ),
    );

    if (onTap == null) {
      return content;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: content,
    );
  }
}

class _RowDivider extends StatelessWidget {
  const _RowDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      thickness: 1,
      indent: 18,
      endIndent: 18,
      color: AppColors.border,
    );
  }
}

class _ValueText extends StatelessWidget {
  const _ValueText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 15,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _VoiceDropdown extends StatelessWidget {
  const _VoiceDropdown({
    required this.voices,
    required this.selected,
    required this.onChanged,
  });

  final List<TtsVoice> voices;
  final TtsVoice? selected;
  final ValueChanged<TtsVoice> onChanged;

  @override
  Widget build(BuildContext context) {
    if (voices.isEmpty) {
      return const _ValueText('기본');
    }

    final value = selected != null && voices.contains(selected)
        ? selected
        : null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.inputSurface,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<TtsVoice>(
          value: value,
          isDense: true,
          borderRadius: BorderRadius.circular(AppRadius.md),
          hint: const Text('기본'),
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.primary,
          ),
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
          items: [
            for (final voice in voices)
              DropdownMenuItem(
                value: voice,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 150),
                  child: Text(
                    voice.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
          ],
          onChanged: (selected) {
            if (selected != null) {
              onChanged(selected);
            }
          },
        ),
      ),
    );
  }
}

class _InputModeDropdown extends StatelessWidget {
  const _InputModeDropdown({
    required this.value,
    required this.values,
    required this.onChanged,
  });

  final String value;
  final List<String> values;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.inputSurface,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isDense: true,
          borderRadius: BorderRadius.circular(AppRadius.md),
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.primary,
          ),
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
          items: [
            for (final mode in values)
              DropdownMenuItem(value: mode, child: Text(mode)),
          ],
          onChanged: (selected) {
            if (selected != null) {
              onChanged(selected);
            }
          },
        ),
      ),
    );
  }
}
