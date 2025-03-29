import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget buildElevatedButton({
  required VoidCallback onPressed,
  required String label,
}) {
  return SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      onPressed: onPressed,
      child: Text(
        label.toUpperCase(),
        style: GoogleFonts.openSans(fontWeight: FontWeight.bold),
      ),
    ),
  );
}
