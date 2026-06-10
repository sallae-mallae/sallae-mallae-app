import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';

class PermissionGuideScreen extends StatelessWidget {
  const PermissionGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(
            child: Text(
              'Permission Guide',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
