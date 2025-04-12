import 'package:cached_network_image/cached_network_image.dart';
import 'package:chataloka/models/message_model.dart';
import 'package:chataloka/theme/custom_theme.dart';
import 'package:chataloka/utilities/assets_manager.dart';
import 'package:chataloka/widgets/display_message_type.dart';
import 'package:chataloka/widgets/sent_mark.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:swipe_to/swipe_to.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.messageModel,
    required this.isMe,
    this.onRightSwipe,
    this.onLeftSwipe,
  });

  final MessageModel messageModel;
  final bool isMe;
  final GestureDragUpdateCallback? onRightSwipe;
  final GestureDragUpdateCallback? onLeftSwipe;

  @override
  Widget build(BuildContext context) {
    final CustomTheme theme = Theme.of(context).extension<CustomTheme>()!;

    final Color textColor =
        isMe ? theme.primaryChatText : theme.secondaryChatText;
    final bool isReplying = messageModel.repliedTo.isNotEmpty;

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
            color: isMe ? theme.primaryCard.light : theme.secondaryCard.light,
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
                      color:
                          isMe
                              ? theme.primaryCard.dark
                              : theme.secondaryCard.dark,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (isMe == (messageModel.repliedTo == 'You'))
                              ? 'You'
                              : isMe
                              ? messageModel.repliedTo
                              : messageModel.senderName,
                          style: GoogleFonts.openSans(
                            color: textColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          messageModel.repliedMessage,
                          style: GoogleFonts.openSans(color: textColor),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 8),
                ],
                if (messageModel.fileUrl != null &&
                    messageModel.fileUrl!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.6,
                          maxHeight: 250,
                        ),
                        child: CachedNetworkImage(
                          imageUrl: messageModel.fileUrl!,
                          placeholder:
                              (context, url) =>
                                  Center(child: CircularProgressIndicator()),
                          errorWidget:
                              (context, url, error) =>
                                  Image.asset(AssetsManager.imageError),
                        ),
                      ),
                    ),
                  ),
                messageModel.message.length < 30
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
                        if (isMe)
                          SentMark(model: messageModel, textColor: textColor),
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
                        if (isMe)
                          SentMark(model: messageModel, textColor: textColor),
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
