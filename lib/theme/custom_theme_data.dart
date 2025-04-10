import 'package:flutter/material.dart';
import 'package:chataloka/theme/custom_theme.dart';

class CustomThemeData {
  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    extensions: [
      CustomTheme(
        customSenderCardColor: Colors.deepPurple[400]!,
        customDarkSenderCardColor: Colors.deepPurple[500]!,
        customSenderTextColor: Colors.white,
        customContactCardColor: Colors.grey[300]!,
        customDarkContactCardColor: Colors.grey[400]!,
        customContactTextColor: Colors.black,
        customButtonColor: Colors.deepPurple[500]!,
      ),
    ],
  );

  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    extensions: [
      CustomTheme(
        customSenderCardColor: Colors.deepPurple[800]!,
        customDarkSenderCardColor: Colors.deepPurple[900]!,
        customSenderTextColor: Colors.white,
        customContactCardColor: Color(0xFF4D4D4D),
        customDarkContactCardColor: Color(0xFF3C3C3C),
        customContactTextColor: Colors.white70,
        customButtonColor: Colors.deepPurple[500]!,
      ),
    ],
  );
}
