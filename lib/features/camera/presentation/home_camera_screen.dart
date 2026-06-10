import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';

class HomeCameraScreen extends StatelessWidget {
  const HomeCameraScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Center(
          child: Text(
            'Home Camera Placeholder',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
