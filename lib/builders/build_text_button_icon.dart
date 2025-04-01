import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget buildTextButtonIcon({
  required BuildContext context,
  required VoidCallback onPressed,
  required IconData icon,
  required String label,
  double? size,
  Color? color,
  double? fontSize,
}) {
  return TextButton.icon(
    label: Text(label, style: GoogleFonts.openSans(
      fontSize: fontSize,
      color: color ?? Theme.of(context).colorScheme.primary
    ),),
    onPressed: onPressed,
    icon: Icon(icon, color: color, size: size,),
  );
}
