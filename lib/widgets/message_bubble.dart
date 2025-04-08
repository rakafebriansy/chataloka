import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.element,
    required this.color,
    required this.textColor,
    required this.alignment
  });

  final dynamic element;
  final Color color;
  final Color textColor;
  final CrossAxisAlignment alignment;

  @override
  Widget build(BuildContext context) {
    bool isShort = (element.message as String).length < 30;
    return Column(
      crossAxisAlignment: alignment,
      children: [
        Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.8,
          ),
          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha((0.2 * 255).round()),
                blurRadius: 4,
                spreadRadius: 0,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child:
              isShort
                  ? Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        (element.message as String),
                        style: GoogleFonts.openSans(color: textColor),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat.Hm().format(element.sentAt),
                        style: GoogleFonts.openSans(
                          color: textColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  )
                  : Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        (element.message as String),
                        style: GoogleFonts.openSans(color: textColor),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        DateFormat.Hm().format(element.sentAt),
                        style: GoogleFonts.openSans(
                          color: textColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
        ),
      ],
    );
  }
}
