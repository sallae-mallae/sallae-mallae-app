import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';
import '../../features/auth/application/auth_provider.dart';
import '../../features/auth/domain/entities/auth_session.dart';

/// Shows the signed-in account (name, email) and sign-out in a bottom sheet.
Future<void> showAccountBottomSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => const _AccountBottomSheet(),
  );
}

class _AccountBottomSheet extends ConsumerWidget {
  const _AccountBottomSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session =
        ref.watch(authProvider).asData?.value ?? const AuthSession.guest();
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return DecoratedBox(
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
              const SizedBox(height: 22),
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.lavender,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.person_rounded,
                      color: AppColors.primary,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          session.displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        if (session.email.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            session.email,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () {
                  ref.read(authProvider.notifier).signOut();
                  Navigator.of(context).pop();
                },
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.cardWhite,
                  foregroundColor: AppColors.pass,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.card,
                    side: const BorderSide(color: AppColors.border),
                  ),
                ),
                child: const Text(
                  '로그아웃',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
