import 'package:go_router/go_router.dart';
import 'package:sallae_mallae_app/features/camera/presentation/home_camera_screen.dart';
import 'package:sallae_mallae_app/features/auth/presentation/my_page_screen.dart';
import 'package:sallae_mallae_app/features/history/domain/entities/history_item.dart';
import 'package:sallae_mallae_app/features/history/presentation/history_detail_screen.dart';
import 'package:sallae_mallae_app/features/history/presentation/history_screen.dart';
import 'package:sallae_mallae_app/features/permission/presentation/permission_guide_screen.dart';
import 'package:sallae_mallae_app/features/settings/presentation/settings_screen.dart';
import 'package:sallae_mallae_app/features/splash/presentation/splash_screen.dart';

import 'route_paths.dart';

final appRouter = GoRouter(
  initialLocation: RoutePaths.splash,
  routes: [
    GoRoute(
      path: RoutePaths.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: RoutePaths.permissionsGuide,
      builder: (context, state) => const PermissionGuideScreen(),
    ),
    GoRoute(
      path: RoutePaths.home,
      builder: (context, state) => const HomeCameraScreen(),
    ),
    GoRoute(
      path: RoutePaths.history,
      builder: (context, state) => const HistoryScreen(),
    ),
    GoRoute(
      path: RoutePaths.historyDetail,
      builder: (context, state) =>
          HistoryDetailScreen(item: state.extra as HistoryItem),
    ),
    GoRoute(
      path: RoutePaths.settings,
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: RoutePaths.myPage,
      builder: (context, state) => const MyPageScreen(),
    ),
  ],
);
