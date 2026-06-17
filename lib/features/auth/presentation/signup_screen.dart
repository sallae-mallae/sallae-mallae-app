import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/route_paths.dart';
import '../../../app/theme/app_colors.dart';
import '../../../shared/widgets/auth_text_field.dart';
import '../../../shared/widgets/primary_action_button.dart';

/// Simple sign-up page.
///
/// Presentation-only shell: submitting does not create an account yet. The
/// real sign-up flow is wired up in a later step.
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _nickname = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _passwordConfirm = TextEditingController();

  @override
  void dispose() {
    _nickname.dispose();
    _email.dispose();
    _password.dispose();
    _passwordConfirm.dispose();
    super.dispose();
  }

  void _onBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(RoutePaths.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          color: AppColors.screenBase,
          gradient: AppColors.appBackgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 20, 8),
                child: Row(
                  children: [
                    IconButton(
                      tooltip: '뒤로 가기',
                      onPressed: _onBack,
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: AppColors.textPrimary,
                        size: 20,
                      ),
                    ),
                    const Text(
                      '회원가입',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.fromLTRB(24, 12, 24, 24 + bottomInset),
                  children: [
                    const Text(
                      '간단한 정보만 입력하면 가입이 완료돼요.',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 15,
                        height: 1.35,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 24),
                    AuthTextField(
                      controller: _nickname,
                      label: '닉네임',
                      hintText: '사용할 닉네임을 입력해 주세요.',
                    ),
                    const SizedBox(height: 16),
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
                      hintText: '8자 이상 입력해 주세요.',
                      obscureText: true,
                    ),
                    const SizedBox(height: 16),
                    AuthTextField(
                      controller: _passwordConfirm,
                      label: '비밀번호 확인',
                      hintText: '비밀번호를 다시 입력해 주세요.',
                      obscureText: true,
                    ),
                    const SizedBox(height: 28),
                    PrimaryActionButton(label: '가입하기', onPressed: _onBack),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
