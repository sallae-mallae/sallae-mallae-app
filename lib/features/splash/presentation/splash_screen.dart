import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/route_paths.dart';
import '../../../app/theme/app_colors.dart';
import '../../permission/domain/permission_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();

    unawaited(_routeAfterPermissionCheck());
  }

  Future<void> _routeAfterPermissionCheck() async {
    await Future<void>.delayed(const Duration(milliseconds: 800));

    await ref.read(permissionProvider.notifier).checkRequiredPermissions();

    if (!mounted) {
      return;
    }

    final permissionState = ref.read(permissionProvider);
    final nextRoute = permissionState.allGranted
        ? RoutePaths.home
        : RoutePaths.permissionsGuide;

    context.go(nextRoute);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          '살래말래?',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 28,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
