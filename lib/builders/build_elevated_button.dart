import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget buildElevatedButton({
  required BuildContext context,
  required VoidCallback onPressed,
  required String label,
  Color? backgroundColor,
  Color? foregroundColor,
  double? width,
  double? fontSize
}) {
  final colorScheme = Theme.of(context).colorScheme;

  return SizedBox(
    width: width ?? double.infinity,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? colorScheme.primary,
      ),
      onPressed: onPressed,
      child: Text(
        label.toUpperCase(),
        textAlign: TextAlign.center,
        style: GoogleFonts.openSans(
          fontWeight: FontWeight.bold,
          fontSize: fontSize ?? 14,
          color: foregroundColor ?? Colors.white,
        ),
      ),
    ),
  );
}
