import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/assets/app_assets.dart';
import '../../../app/router/route_paths.dart';
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
    return const Scaffold(body: _SplashContent());
  }
}

class _SplashContent extends StatelessWidget {
  const _SplashContent();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage(AppAssets.splashBackground),
          fit: BoxFit.cover,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              AppAssets.logoAll,
              width: 159,
              height: 174,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 24),
            Image.asset(
              AppAssets.splashWord,
              width: 129,
              height: 16,
              fit: BoxFit.contain,
            ),
          ],
        ),
      ),
    );
  }
}
