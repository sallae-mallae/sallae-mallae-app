import 'package:flutter/material.dart';
import 'package:sallae_mallae_app/app/theme/app_theme.dart';

import 'router/app_router.dart';

class SallaeMallaeApp extends StatelessWidget {
  const SallaeMallaeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Sallae Mallae',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
    );
  }
}
