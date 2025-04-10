import 'package:chataloka/theme/custom_theme_color.dart';
import 'package:flutter/material.dart';
import 'package:chataloka/theme/custom_theme.dart';

class CustomThemeData {
  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    extensions: [
      CustomTheme(
        primaryCard: PairCustomThemeColor(
          light: Colors.deepPurple[600]!,
          dark: Colors.deepPurple[700]!,
        ),
        secondaryCard: PairCustomThemeColor(
          light: Colors.grey[300]!,
          dark: Colors.grey[400]!,
        ),
        text: Colors.white,
        primaryChatText: Colors.white70,
        secondaryChatText: Colors.black,
        button: PairCustomThemeColor(
          light: Colors.blue[500]!,
          dark: Colors.blue[700]!,
        ),
      ),
    ],
  );

  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    extensions: [
      CustomTheme(
        primaryCard: PairCustomThemeColor(
          light: Colors.deepPurple[800]!,
          dark: Colors.deepPurple[900]!,
        ),
        secondaryCard: PairCustomThemeColor(
          light: Color(0xFF4D4D4D),
          dark: Color(0xFF3C3C3C),
        ),
        text: Colors.black,
        primaryChatText: Colors.white70,
        secondaryChatText: Colors.white70,
        button: PairCustomThemeColor(
          light: Colors.blue[500]!,
          dark: Colors.blue[700]!,
        ),
      ),
    ],
  );
}
