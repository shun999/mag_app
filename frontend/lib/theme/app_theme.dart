import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF1D9E75);

  // OK (正常)
  static const okBadgeBg = Color(0xFFEAF3DE);
  static const okBadgeText = Color(0xFF27500A);
  static const okBar = Color(0xFF639922);

  // NG (異常)
  static const ngBadgeBg = Color(0xFFFCEBEB);
  static const ngBadgeText = Color(0xFF791F1F);
  static const ngBar = Color(0xFFE24B4A);

  // カメラUI
  static const cameraBg = Color(0xFF111111);
  static const cameraBody = Color(0xFF1A1A1A);
  static const viewfinderBg = Color(0xFF0D0D0D);
}

ThemeData buildAppTheme() {
  return ThemeData(
    colorSchemeSeed: AppColors.primary,
    brightness: Brightness.light,
    useMaterial3: true,
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
    ),
  );
}
