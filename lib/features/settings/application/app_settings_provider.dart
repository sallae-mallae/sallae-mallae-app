import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/app_settings.dart';

final appSettingsProvider = NotifierProvider<AppSettingsNotifier, AppSettings>(
  AppSettingsNotifier.new,
);

class AppSettingsNotifier extends Notifier<AppSettings> {
  static const _inputModeKey = 'settings_input_mode';
  static const _voiceAutoSendKey = 'settings_voice_auto_send';
  static const _photoServerSaveKey = 'settings_photo_server_save';
  static const _proModeKey = 'settings_pro_mode';
  static const _aiModelKey = 'settings_ai_model';

  @override
  AppSettings build() {
    _load();
    return const AppSettings.defaults();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = AppSettings(
      defaultInputMode: prefs.getString(_inputModeKey) == 'voice'
          ? AppInputMode.voice
          : AppInputMode.text,
      voiceAutoSend: prefs.getBool(_voiceAutoSendKey) ?? true,
      photoServerSave: prefs.getBool(_photoServerSaveKey) ?? false,
      proMode: prefs.getBool(_proModeKey) ?? false,
      aiModel: prefs.getString(_aiModelKey) ?? '',
    );
  }

  Future<void> setDefaultInputMode(AppInputMode mode) async {
    state = state.copyWith(defaultInputMode: mode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_inputModeKey, mode.name);
  }

  Future<void> setVoiceAutoSend(bool value) async {
    state = state.copyWith(voiceAutoSend: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_voiceAutoSendKey, value);
  }

  Future<void> setPhotoServerSave(bool value) async {
    state = state.copyWith(photoServerSave: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_photoServerSaveKey, value);
  }

  Future<void> setProMode(bool value) async {
    state = state.copyWith(proMode: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_proModeKey, value);
  }

  Future<void> setAiModel(String value) async {
    state = state.copyWith(aiModel: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_aiModelKey, value);
  }
}
