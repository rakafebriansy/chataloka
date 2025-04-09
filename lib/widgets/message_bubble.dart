import 'package:chataloka/models/message_model.dart';
import 'package:chataloka/widgets/sent_mark.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:swipe_to/swipe_to.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.element,
    required this.isMe,
    this.onRightSwipe,
    this.onLeftSwipe,
  });

  final MessageModel element;
  final bool isMe;
  final GestureDragUpdateCallback? onRightSwipe;
  final GestureDragUpdateCallback? onLeftSwipe;

  @override
  Widget build(BuildContext context) {
    final Color textColor = isMe ? Colors.white : Colors.black;
    final bool isReplying = element.repliedTo.isNotEmpty;

    print(element.message);
    print(element.repliedTo);
    print(element.senderName);
    print(isMe);
    print('====');

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
          padding: EdgeInsets.all(isReplying ? 8 : 12),
          decoration: BoxDecoration(
            color: isMe ? Colors.deepPurple[600] : Colors.grey[300]!,
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
          child: IntrinsicWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (isReplying) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isMe ? Colors.deepPurple[800] : Colors.grey[400]!,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (isMe == (element.repliedTo == 'You'))
                              ? 'You'
                              : isMe
                              ? element.repliedTo
                              : element.senderName,
                          style: GoogleFonts.openSans(
                            color: textColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          element.repliedMessage,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.openSans(
                            color: textColor,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 8),
                ],
                element.message.length < 30
                    ? Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          element.message,
                          style: GoogleFonts.openSans(color: textColor),
                        ),
                        const SizedBox(width: 8),
                        SentMark(element: element, textColor: textColor),
                      ],
                    )
                    : Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          element.message,
                          style: GoogleFonts.openSans(color: textColor),
                        ),
                        const SizedBox(height: 5),
                        SentMark(element: element, textColor: textColor),
                      ],
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
