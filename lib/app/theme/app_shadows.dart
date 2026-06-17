import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppShadows {
  static const List<BoxShadow> card = [
    BoxShadow(color: AppColors.shadow, blurRadius: 18, offset: Offset(0, 8)),
  ];

  static const List<BoxShadow> bottomSheet = [
    BoxShadow(color: AppColors.shadow, blurRadius: 18, offset: Offset(0, -4)),
  ];

  static const List<BoxShadow> floating = [
    BoxShadow(
      color: AppColors.elevatedShadow,
      blurRadius: 12,
      offset: Offset(0, 10),
    ),
  ];
}
