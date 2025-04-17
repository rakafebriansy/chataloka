import 'package:chataloka/models/last_message_model.dart';
import 'package:chataloka/models/message_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class SentMark extends StatelessWidget {
  const SentMark({super.key, required this.model, required this.textColor});

  final Color textColor;
  final dynamic model;

  @override
  Widget build(BuildContext context) {
    assert(
      model is MessageModel || model is LastMessageModel,
      'Model must be an instance of MessageModel or LastMessageModel',
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          DateFormat.Hm().format(model.sentAt),
          style: GoogleFonts.openSans(color: textColor, fontSize: 10),
        ),
        const SizedBox(width: 4),
        Icon(
          model.isSeen ? Icons.done_all : Icons.done,
          size: 14,
          color: textColor,
        ),
      ],
    );
  }
}
