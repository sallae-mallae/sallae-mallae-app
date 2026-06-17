import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/assets/app_assets.dart';
import '../../app/router/route_paths.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import 'auth_text_field.dart';
import 'primary_action_button.dart';

/// Presents the email/password login bottom sheet.
///
/// This is a presentation-only shell: submitting does not perform any
/// authentication yet. The real sign-in flow is wired up in a later step.
Future<void> showLoginBottomSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => _LoginBottomSheet(
      onSignup: () {
        Navigator.of(sheetContext).pop();
        context.push(RoutePaths.signup);
      },
    ),
  );
}

class _LoginBottomSheet extends StatefulWidget {
  const _LoginBottomSheet({required this.onSignup});

  final VoidCallback onSignup;

  @override
  State<_LoginBottomSheet> createState() => _LoginBottomSheetState();
}

class _LoginBottomSheetState extends State<_LoginBottomSheet> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

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
                const SizedBox(height: 22),
                PrimaryActionButton(
                  label: '로그인',
                  onPressed: () => Navigator.of(context).pop(),
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
                      onPressed: widget.onSignup,
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
