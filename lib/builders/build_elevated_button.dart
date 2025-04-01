import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget buildElevatedButton({
  required BuildContext context,
  required VoidCallback onPressed,
  required String label,
  Color? backgroundColor,
  Color? foregroundColor,
}) {
  final colorScheme = Theme.of(context).colorScheme;

  return SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? colorScheme.primary,
      ),
      onPressed: onPressed,
      child: Text(
        label.toUpperCase(),
        style: GoogleFonts.openSans(
          fontWeight: FontWeight.bold,
          color: foregroundColor ?? Colors.white,
        ),
      ),
    ),
  );
}
