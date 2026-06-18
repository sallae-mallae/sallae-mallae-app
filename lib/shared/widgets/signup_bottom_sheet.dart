import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../features/auth/application/auth_provider.dart';
import 'auth_text_field.dart';
import 'primary_action_button.dart';

/// Presents the sign-up bottom sheet wired to the real auth API.
Future<void> showSignupBottomSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => const _SignupBottomSheet(),
  );
}

class _SignupBottomSheet extends ConsumerStatefulWidget {
  const _SignupBottomSheet();

  @override
  ConsumerState<_SignupBottomSheet> createState() => _SignupBottomSheetState();
}

class _SignupBottomSheetState extends ConsumerState<_SignupBottomSheet> {
  final TextEditingController _nickname = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _passwordConfirm = TextEditingController();
  String? _errorMessage;

  @override
  void dispose() {
    _nickname.dispose();
    _email.dispose();
    _password.dispose();
    _passwordConfirm.dispose();
    super.dispose();
  }

  Future<void> _onSignup() async {
    FocusScope.of(context).unfocus();
    setState(() => _errorMessage = null);

    if (_password.text != _passwordConfirm.text) {
      setState(() => _errorMessage = '비밀번호가 일치하지 않아요.');
      return;
    }

    await ref
        .read(authProvider.notifier)
        .signUp(
          email: _email.text.trim(),
          password: _password.text,
          nickname: _nickname.text.trim(),
        );

    if (!mounted) {
      return;
    }

    if (ref.read(authProvider).hasError) {
      setState(() => _errorMessage = '가입에 실패했어요. 입력 정보를 확인해 주세요.');
      return;
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final isLoading = ref.watch(authProvider).isLoading;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: AppColors.cardWhite,
          borderRadius: AppRadius.sheet,
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(24, 12, 24, 20 + bottomInset),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Center(
                    child: Text(
                      '회원가입',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  AuthTextField(
                    controller: _nickname,
                    label: '닉네임',
                    hintText: '사용할 닉네임을 입력해 주세요.',
                  ),
                  const SizedBox(height: 14),
                  AuthTextField(
                    controller: _email,
                    label: '이메일',
                    hintText: 'example@sallae.com',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 14),
                  AuthTextField(
                    controller: _password,
                    label: '비밀번호',
                    hintText: '8자 이상 입력해 주세요.',
                    obscureText: true,
                  ),
                  const SizedBox(height: 14),
                  AuthTextField(
                    controller: _passwordConfirm,
                    label: '비밀번호 확인',
                    hintText: '비밀번호를 다시 입력해 주세요.',
                    obscureText: true,
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 14),
                    Text(
                      _errorMessage!,
                      style: const TextStyle(
                        color: AppColors.pass,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  PrimaryActionButton(
                    label: isLoading ? '가입 중...' : '가입하기',
                    onPressed: isLoading ? null : _onSignup,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
