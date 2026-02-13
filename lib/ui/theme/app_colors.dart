import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color white = Colors.white;
  static const Color white70 = Colors.white70;
  static const Color black87 = Colors.black87;
  static const Color blackTrans70 = Color(0xDD000000);

  // --- Warm Pink ---
  static const Color warmPinkPrimary = Color(0xFFF97A8D);
  static const List<Color> warmPinkGradients = [
    Color(0xFFFDE8EC),
    Color(0xFFFDF0F2),
    Color(0xFFFFF6F7),
    Color(0xFFFFFBFB),
  ];
  static const Color warmPinkActive = Color(0xFFC2185B);
  static const Color warmPinkText = Color(0xFF880E4F);
  static const Color warmPinkCard = Color(0xCCFFFFFF); // 80% 화이트
  static const Color warmPinkShadow = Color(0x20880E4F);

  static const Color warmPinkPrimaryDark = Color(0xFFEC407A);
  static const List<Color> warmPinkGradientsDark = [
    Color(0xFF1A090C),
    Color(0xFF2C0E14),
    Color(0xFF3D1421),
    Color(0xFF4A192C),
  ];
  static const Color warmPinkActiveDark = Color(0xFFF06292);
  static const Color warmPinkTextDark = Color(0xFFFFFFFF);
  static const Color warmPinkCardDark = Color(0x33FFFFFF); // 20% 화이트
  static const Color warmPinkShadowDark = Color(0x60000000);

  // --- Soft Lemon ---
  static const Color softLemonPrimary = Color(0xFFFFF59D);
  static const List<Color> softLemonGradients = [
    Color(0xFFFFFDE7),
    Color(0xFFFFF9C4),
    Color(0xFFFFF59D),
    Color(0xFFFFF176),
  ];
  static const Color softLemonActive = Color(0xFF4E342E);
  static const Color softLemonText = Color(0xDD000000);
  static const Color softLemonCard = Color(0xE6FFFDE7); // 90% 레몬
  static const Color softLemonShadow = Color(0x154E342E);

  static const Color softLemonPrimaryDark = Color(0xFFFFD54F);
  static const List<Color> softLemonGradientsDark = [
    Color(0xFF1F1412),
    Color(0xFF2D1D1A),
    Color(0xFF3E2723),
    Color(0xFF5D4037),
  ];
  static const Color softLemonActiveDark = Color(0xFFFFE082);
  static const Color softLemonTextDark = Color(0xFFFFFFFF);
  static const Color softLemonCardDark = Color(0x26FFFFFF); // 15% 화이트
  static const Color softLemonShadowDark = Color(0x50000000);

  // --- Sky Blue ---
  static const Color skyBluePrimary = Color(0xFF64B5F6);
  static const List<Color> skyBlueGradients = [
    Color(0xFFE3F2FD),
    Color(0xFFBBDEFB),
    Color(0xFF90CAF9),
    Color(0xFF64B5F6),
  ];
  static const Color skyBlueActive = Color(0xFF1565C0);
  static const Color skyBlueText = Color(0xFF0D47A1);
  static const Color skyBlueCard = Color(0xE6E3F2FD); // 90% 블루
  static const Color skyBlueShadow = Color(0x150D47A1);

  static const Color skyBluePrimaryDark = Color(0xFF64B5F6);
  static const List<Color> skyBlueGradientsDark = [
    Color(0xFF051F42),
    Color(0xFF0D2D5E),
    Color(0xFF0D47A1),
    Color(0xFF1976D2),
  ];
  static const Color skyBlueActiveDark = Color(0xFF90CAF9);
  static const Color skyBlueTextDark = Color(0xFFFFFFFF);
  static const Color skyBlueCardDark = Color(0x26FFFFFF); // 15% 화이트
  static const Color skyBlueShadowDark = Color(0x50000000);

  // --- Mint Green ---
  static const Color mintGreenPrimary = Color(0xFF81C784);
  static const List<Color> mintGreenGradients = [
    Color(0xFFE8F5E9),
    Color(0xFFC8E6C9),
    Color(0xFFA5D6A7),
    Color(0xFF81C784),
  ];
  static const Color mintGreenActive = Color(0xFF2E7D32);
  static const Color mintGreenText = Color(0xFF1B5E20);
  static const Color mintGreenCard = Color(0xE6E8F5E9); // 90% 민트
  static const Color mintGreenShadow = Color(0x151B5E20);

  static const Color mintGreenPrimaryDark = Color(0xFFA5D6A7);
  static const List<Color> mintGreenGradientsDark = [
    Color(0xFF0A240C),
    Color(0xFF123116),
    Color(0xFF1B5E20),
    Color(0xFF388E3C),
  ];
  static const Color mintGreenActiveDark = Color(0xFFC8E6C9);
  static const Color mintGreenTextDark = Color(0xFFFFFFFF);
  static const Color mintGreenCardDark = Color(0x26FFFFFF); // 15% 화이트
  static const Color mintGreenShadowDark = Color(0x50000000);

  // --- Lavender ---
  static const Color lavenderPrimary = Color(0xFFBA68C8);
  static const List<Color> lavenderGradients = [
    Color(0xFFF3E5F5),
    Color(0xFFE1BEE7),
    Color(0xFFCE93D8),
    Color(0xFFBA68C8),
  ];
  static const Color lavenderActive = Color(0xFF7B1FA2);
  static const Color lavenderText = Color(0xFF4A148C);
  static const Color lavenderCard = Color(0xE6F3E5F5); // 90% 퍼플
  static const Color lavenderShadow = Color(0x204A148C);

  static const Color lavenderPrimaryDark = Color(0xFFCE93D8);
  static const List<Color> lavenderGradientsDark = [
    Color(0xFF140B3D),
    Color(0xFF211261),
    Color(0xFF311B92),
    Color(0xFF512DA8),
  ];
  static const Color lavenderActiveDark = Color(0xFFE1BEE7);
  static const Color lavenderTextDark = Color.fromARGB(255, 8, 6, 6);
  static const Color lavenderCardDark = Color(0x26FFFFFF); // 15% 화이트
  static const Color lavenderShadowDark = Color(0x55000000);

  // --- Creamy White ---
  static const Color creamyWhitePrimary = Color(0xFFE0E0E0);
  static const List<Color> creamyWhiteGradients = [
    Color(0xFFFAFAFA),
    Color(0xFFF5F5F5),
    Color(0xFFEEEEEE),
    Color(0xFFE0E0E0),
  ];
  static const Color creamyWhiteActive = Color(0xFF212121);
  static const Color creamyWhiteText = Color(0xDD000000);
  static const Color creamyWhiteCard = Color(0xFFFFFFFF); // 100% 화이트
  static const Color creamyWhiteShadow = Color(0x15000000);

  static const Color creamyWhitePrimaryDark = Color(0xFFBDBDBD);
  static const List<Color> creamyWhiteGradientsDark = [
    Color(0xFF000000),
    Color(0xFF121212),
    Color(0xFF1E1E1E),
    Color(0xFF212121),
  ];
  static const Color creamyWhiteActiveDark = Color(0xFFE0E0E0);
  static const Color creamyWhiteTextDark = Color(0xFFFFFFFF);
  static const Color creamyWhiteCardDark = Color(0x33FFFFFF); // 20% 화이트
  static const Color creamyWhiteShadowDark = Color(0x60000000);
}
