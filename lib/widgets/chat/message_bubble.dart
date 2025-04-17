import 'package:cached_network_image/cached_network_image.dart';
import 'package:chataloka/constants/message_constants.dart';
import 'package:chataloka/models/message_model.dart';
import 'package:chataloka/theme/custom_theme.dart';
import 'package:chataloka/utilities/assets_manager.dart';
import 'package:chataloka/widgets/chat/message_renderer.dart';
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
    final CustomTheme customTheme = Theme.of(context).extension<CustomTheme>()!;

    final Color textColor =
        isMe ? customTheme.primaryChatText : customTheme.secondaryChatText;
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
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color:
                isMe
                    ? customTheme.primaryCard.light
                    : customTheme.secondaryCard.light,
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isReplying) ...[
                  Container(
                    clipBehavior: Clip.hardEdge,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 1,
                        color:
                            isMe
                                ? customTheme.primaryBorder.dark
                                : customTheme.secondaryBorder.dark,
                      ),
                      color:
                          isMe
                              ? customTheme.primaryCard.dark
                              : customTheme.secondaryCard.dark,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Row(
                      children: [
                        Container(
                          height: 20,
                          width: 4,
                          color: isMe ? Colors.blue : Colors.deepPurple,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
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
                                RichText(
                                  text: TextSpan(
                                    children: [
                                      if (messageModel.repliedMessageType ==
                                          MessageEnum.image)
                                        WidgetSpan(
                                          alignment:
                                              PlaceholderAlignment.middle,
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                              right: 4,
                                            ),
                                            child: Icon(
                                              Icons.image,
                                              size: 16,
                                              color: textColor,
                                            ),
                                          ),
                                        ),
                                      TextSpan(
                                        text: messageModel.repliedMessage,
                                        style: GoogleFonts.openSans(
                                          color: textColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (messageModel.repliedFileUrl != null &&
                            messageModel.repliedFileUrl!.isNotEmpty) ...[
                          SizedBox(width: 18),
                          Container(
                            constraints: BoxConstraints(
                              maxWidth: 54,
                              maxHeight: 54,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.only(
                                bottomRight: Radius.circular(3),
                                topRight: Radius.circular(3),
                              ),
                              child: CachedNetworkImage(
                                fit: BoxFit.cover,
                                imageUrl: messageModel.repliedFileUrl!,
                                placeholder:
                                    (context, url) => Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                errorWidget:
                                    (context, url, error) =>
                                        Image.asset(AssetsManager.imageError),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(height: 8),
                ],
                MessageRenderer(messageModel: messageModel, textColor: textColor, isMe: isMe)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
