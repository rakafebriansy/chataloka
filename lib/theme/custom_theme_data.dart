import 'package:chataloka/theme/custom_theme_color.dart';
import 'package:flutter/material.dart';
import 'package:chataloka/theme/custom_theme.dart';

class CustomThemeData {
  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    extensions: [
      CustomTheme(
        primaryCard: PairCustomThemeColor(
          light: Colors.deepPurple[500]!,
          dark: Colors.deepPurple[600]!,
        ),
        secondaryCard: PairCustomThemeColor(
          light: Colors.blue[300]!,
          dark: Colors.blue[400]!,
        ),
        primaryBorder: PairCustomThemeColor(
          light: Colors.deepPurple[600]!,
          dark: Colors.deepPurple[700]!,
        ),
        secondaryBorder: PairCustomThemeColor(
          light: Colors.blue[400]!,
          dark: Colors.blue[500]!,
        ),
        text: PairCustomThemeColor(light: Colors.black, dark: Colors.white),
        primaryChatText: Colors.white,
        secondaryChatText: Colors.white,
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
        primaryBorder: PairCustomThemeColor(
          light: Colors.deepPurple[600]!,
          dark: Colors.deepPurple[700]!,
        ),
        secondaryBorder: PairCustomThemeColor(
          light: Colors.blue[300]!,
          dark: Colors.blue[400]!,
        ),
        text: PairCustomThemeColor(
          light: Colors.white,
          dark: Colors.black,
        ),
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
