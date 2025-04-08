import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:swipe_to/swipe_to.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.element,
    required this.isMe,
    this.onRightSwipe,
    this.onLeftSwipe,
  });

  final dynamic element;
  final bool isMe;
  final GestureDragUpdateCallback? onRightSwipe;
  final GestureDragUpdateCallback? onLeftSwipe;

  @override
  Widget build(BuildContext context) {
    final Color textColor = isMe ? Colors.white : Colors.black;
    return SwipeTo(
      onRightSwipe: !isMe ? onRightSwipe : null,
      onLeftSwipe: isMe ? onLeftSwipe : null,
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.8,
          ),
          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isMe ? Theme.of(context).primaryColor : Colors.grey[300]!,
            borderRadius:
                isMe
                    ? BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                      bottomLeft: Radius.circular(10),
                    )
                    : BorderRadius.only(
                      topRight: Radius.circular(10),
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                    ),
          ),
          child:
              (element.message as String).length < 30
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
      ),
    );
  }
}
