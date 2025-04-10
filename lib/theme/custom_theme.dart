import 'package:chataloka/theme/custom_theme_color.dart';
import 'package:flutter/material.dart';

@immutable
class CustomTheme extends ThemeExtension<CustomTheme> {
  final PairCustomThemeColor primaryCard;
  final PairCustomThemeColor secondaryCard;
  final Color text;
  final Color primaryChatText;
  final Color secondaryChatText;
  final PairCustomThemeColor button;

  const CustomTheme({
    required this.primaryCard,
    required this.secondaryCard,
    required this.text,
    required this.primaryChatText,
    required this.secondaryChatText,
    required this.button,
  });

  @override
  CustomTheme copyWith({
    PairCustomThemeColor? primaryCard,
    PairCustomThemeColor? secondaryCard,
    Color? text,
    Color? primaryChatText,
    Color? secondaryChatText,
    PairCustomThemeColor? button,
  }) {
    return CustomTheme(
      text: text ?? this.text,
      primaryCard: primaryCard ?? this.primaryCard,
      secondaryCard: secondaryCard ?? this.secondaryCard,
      primaryChatText: primaryChatText ?? this.primaryChatText,
      secondaryChatText: secondaryChatText ?? this.secondaryChatText,
      button: button ?? this.button,
    );
  }

  @override
  CustomTheme lerp(ThemeExtension<CustomTheme>? other, double t) {
    if (other is! CustomTheme) return this;

    return CustomTheme(
      primaryCard: PairCustomThemeColor(
        light: Color.lerp(primaryCard.light, other.primaryCard.light, t)!,
        dark: Color.lerp(primaryCard.dark, other.primaryCard.dark, t)!,
      ),
      secondaryCard: PairCustomThemeColor(
        light: Color.lerp(secondaryCard.light, other.secondaryCard.light, t)!,
        dark: Color.lerp(secondaryCard.dark, other.secondaryCard.dark, t)!,
      ),
      text: Color.lerp(text, other.text, t)!,
      primaryChatText: Color.lerp(primaryChatText, other.primaryChatText, t)!,
      secondaryChatText:
          Color.lerp(secondaryChatText, other.primaryChatText, t)!,
      button: PairCustomThemeColor(
        light: Color.lerp(button.light, other.button.light, t)!,
        dark: Color.lerp(button.dark, other.button.dark, t)!,
      ),
    );
  }
}
