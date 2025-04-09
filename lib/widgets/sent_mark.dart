import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class SentMark extends StatelessWidget {
  const SentMark({super.key, required this.element, required this.textColor});

  final Color textColor;
  final dynamic element;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          DateFormat.Hm().format(element.sentAt),
          style: GoogleFonts.openSans(color: textColor, fontSize: 10),
        ),
        const SizedBox(width: 4),
        const Icon(Icons.done_all, size: 14, color: Colors.white),
      ],
    );
  }
}