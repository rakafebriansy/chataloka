import 'package:flutter/material.dart';

@immutable
class CustomTheme extends ThemeExtension<CustomTheme> {
  final Color customSenderCardColor;
  final Color customDarkSenderCardColor;
  final Color customContactCardColor;
  final Color customDarkContactCardColor;
  final Color customSenderTextColor;
  final Color customContactTextColor;
  final Color customButtonColor;

  const CustomTheme({
    required this.customSenderCardColor,
    required this.customDarkSenderCardColor,
    required this.customContactCardColor,
    required this.customDarkContactCardColor,
    required this.customContactTextColor,
    required this.customSenderTextColor,
    required this.customButtonColor,
  });

  @override
  CustomTheme copyWith({
    Color? customSenderCardColor,
    Color? customDarkSenderCardColor,
    Color? customContactCardColor,
    Color? customDarkContactCardColor,
    Color? customSenderTextColor,
    Color? customContactTextColor,
    Color? customButtonColor,
  }) {
    return CustomTheme(
      customSenderCardColor: customSenderCardColor ?? this.customSenderCardColor,
      customDarkSenderCardColor: customDarkSenderCardColor ?? this.customDarkSenderCardColor,
      customContactCardColor: customContactCardColor ?? this.customContactCardColor,
      customDarkContactCardColor: customDarkContactCardColor ?? this.customDarkContactCardColor,
      customSenderTextColor: customSenderTextColor ?? this.customSenderTextColor,
      customContactTextColor: customContactTextColor ?? this.customContactTextColor,
      customButtonColor: customButtonColor ?? this.customButtonColor,
    );
  }

  @override
  CustomTheme lerp(ThemeExtension<CustomTheme>? other, double t) {
    if (other is! CustomTheme) return this;

    return CustomTheme(
      customSenderCardColor: Color.lerp(customSenderCardColor, other.customSenderCardColor, t)!,
      customDarkSenderCardColor: Color.lerp(customDarkSenderCardColor, other.customDarkSenderCardColor, t)!,
      customContactCardColor: Color.lerp(customContactCardColor, other.customContactCardColor, t)!,
      customDarkContactCardColor: Color.lerp(customDarkContactCardColor, other.customDarkContactCardColor, t)!,
      customSenderTextColor: Color.lerp(customSenderTextColor, other.customSenderTextColor, t)!,
      customContactTextColor: Color.lerp(customContactTextColor, other.customContactTextColor, t)!,
      customButtonColor: Color.lerp(customButtonColor, other.customButtonColor, t)!,
    );
  }
}
