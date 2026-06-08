import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'route_paths.dart';

final appRouter = GoRouter(
  initialLocation: RoutePaths.splash,
  routes: [
    GoRoute(
      path: RoutePaths.splash,
      builder: (context, state) => const PlaceholderScreen(title: 'Splash'),
    ),
    GoRoute(
      path: RoutePaths.permissionsGuide,
      builder: (context, state) =>
          const PlaceholderScreen(title: 'Permission Guide'),
    ),
    GoRoute(
      path: RoutePaths.home,
      builder: (context, state) => const PlaceholderScreen(title: 'Home'),
    ),
    GoRoute(
      path: RoutePaths.history,
      builder: (context, state) => const PlaceholderScreen(title: 'History'),
    ),
    GoRoute(
      path: RoutePaths.settings,
      builder: (context, state) => const PlaceholderScreen(title: 'Settings'),
    ),
  ],
);

class PlaceholderScreen extends StatelessWidget {
  final String title;

  const PlaceholderScreen({required this.title, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text(title)));
  }
}
