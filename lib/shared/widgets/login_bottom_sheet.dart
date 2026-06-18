import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/assets/app_assets.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../core/errors/app_exception.dart';
import '../../features/auth/application/auth_provider.dart';
import 'auth_text_field.dart';
import 'primary_action_button.dart';
import 'signup_bottom_sheet.dart';

/// Presents the email/password login bottom sheet wired to the real auth API.
Future<void> showLoginBottomSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => const _LoginBottomSheet(),
  );
}

class _LoginBottomSheet extends ConsumerStatefulWidget {
  const _LoginBottomSheet();

  @override
  ConsumerState<_LoginBottomSheet> createState() => _LoginBottomSheetState();
}

class _LoginBottomSheetState extends ConsumerState<_LoginBottomSheet> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  String? _errorMessage;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    FocusScope.of(context).unfocus();
    setState(() => _errorMessage = null);

    await ref
        .read(authProvider.notifier)
        .signIn(email: _email.text.trim(), password: _password.text);

    if (!mounted) {
      return;
    }

    if (ref.read(authProvider).hasError) {
      setState(
        () => _errorMessage = _loginErrorMessage(ref.read(authProvider).error),
      );
      return;
    }

    Navigator.of(context).pop();
  }

  String _loginErrorMessage(Object? error) {
    if (error is AppException) {
      switch (error.type) {
        case AppExceptionType.network:
          return '서버에 연결할 수 없어요. 네트워크를 확인해 주세요.';
        case AppExceptionType.timeout:
          return '요청 시간이 초과됐어요. 다시 시도해 주세요.';
        case AppExceptionType.unauthorized:
        case AppExceptionType.badRequest:
        case AppExceptionType.notFound:
        case AppExceptionType.validation:
          return '이메일 또는 비밀번호가 올바르지 않아요.';
        case AppExceptionType.server:
          return '서버 오류예요. 잠시 후 다시 시도해 주세요.';
        default:
          return '로그인에 실패했어요. 잠시 후 다시 시도해 주세요.';
      }
    }
    return '로그인에 실패했어요. 잠시 후 다시 시도해 주세요.';
  }

  void _onSignup() {
    Navigator.of(context).pop();
    showSignupBottomSheet(context);
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _SheetHandle(),
                const SizedBox(height: 20),
                Center(
                  child: Image.asset(
                    AppAssets.logoAll,
                    width: 60,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 14),
                const Center(
                  child: Text(
                    '로그인하고 시작하기',
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
                  controller: _email,
                  label: '이메일',
                  hintText: 'example@sallae.com',
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 14),
                AuthTextField(
                  controller: _password,
                  label: '비밀번호',
                  hintText: '비밀번호를 입력해 주세요.',
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
                const SizedBox(height: 22),
                PrimaryActionButton(
                  label: isLoading ? '로그인 중...' : '로그인',
                  onPressed: isLoading ? null : _onLogin,
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      '계정이 없으신가요?',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextButton(
                      onPressed: isLoading ? null : _onSignup,
                      child: const Text(
                        '회원가입',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 44,
        height: 5,
        decoration: BoxDecoration(
          color: AppColors.border,
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
      ),
    );
  }
}
