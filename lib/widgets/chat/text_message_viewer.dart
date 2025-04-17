import 'package:chataloka/models/message_model.dart';
import 'package:chataloka/widgets/chat/sent_mark.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TextMessageViewer extends StatelessWidget {
  const TextMessageViewer({
    super.key,
    required this.messageModel,
    required this.textColor,
    required this.isMe,
  });

  final MessageModel messageModel;
  final Color textColor;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return messageModel.message.length < 30
        ? Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              messageModel.message,
              style: GoogleFonts.openSans(color: textColor),
            ),
            const SizedBox(width: 8),
            if (isMe) SentMark(model: messageModel, textColor: textColor),
          ],
        )
        : Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              messageModel.message,
              style: GoogleFonts.openSans(color: textColor),
            ),
            const SizedBox(height: 5),
            if (isMe) SentMark(model: messageModel, textColor: textColor),
          ],
        );
  }
}
