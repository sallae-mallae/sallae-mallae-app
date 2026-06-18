import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/assets/app_assets.dart';
import '../../../app/router/route_paths.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../shared/widgets/auth_text_field.dart';
import '../../../shared/widgets/primary_action_button.dart';
import '../application/auth_provider.dart';

/// Email/password login screen.
///
/// Sign-in currently creates a local session (mock). The real auth API is
/// wired up in a later step. Continuing without logging in is supported so the
/// local history stays accessible.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _continueToHome() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(RoutePaths.home);
    }
  }

  Future<void> _onLogin() async {
    FocusScope.of(context).unfocus();
    await ref
        .read(authProvider.notifier)
        .signIn(email: _email.text.trim(), password: _password.text);

    if (!mounted) {
      return;
    }

    final session = ref.read(authProvider);
    if (session.hasError) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('로그인에 실패했어요. 다시 시도해 주세요.')),
        );
      return;
    }

    _continueToHome();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final isLoading = ref.watch(authProvider).isLoading;

    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: DecoratedBox(
          decoration: const BoxDecoration(
            color: AppColors.screenBase,
            gradient: AppColors.appBackgroundGradient,
          ),
          child: SafeArea(
            child: ListView(
              padding: EdgeInsets.fromLTRB(24, 32, 24, 24 + bottomInset),
              children: [
                Center(
                  child: Image.asset(
                    AppAssets.logoAll,
                    width: 72,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 16),
                const Center(
                  child: Text(
                    '로그인하고 시작하기',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                AuthTextField(
                  controller: _email,
                  label: '이메일',
                  hintText: 'example@sallae.com',
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                AuthTextField(
                  controller: _password,
                  label: '비밀번호',
                  hintText: '비밀번호를 입력해 주세요.',
                  obscureText: true,
                ),
                const SizedBox(height: 28),
                PrimaryActionButton(
                  label: isLoading ? '로그인 중...' : '로그인',
                  onPressed: isLoading ? null : _onLogin,
                ),
                const SizedBox(height: AppSpacing.sm),
                TextButton(
                  onPressed: isLoading ? null : _continueToHome,
                  child: const Text(
                    '로그인 없이 계속 사용',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
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
                      onPressed: () => context.push(RoutePaths.signup),
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
