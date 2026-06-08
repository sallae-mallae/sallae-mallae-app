import 'package:flutter/material.dart';

import 'router/app_router.dart';

class SallaeMallaeApp extends StatelessWidget {
  const SallaeMallaeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Sallae Mallae',
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
    );
  }
}
