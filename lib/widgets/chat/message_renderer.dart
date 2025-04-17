import 'package:cached_network_image/cached_network_image.dart';
import 'package:chataloka/constants/message_constants.dart';
import 'package:chataloka/models/message_model.dart';
import 'package:chataloka/utilities/assets_manager.dart';
import 'package:chataloka/widgets/chat/audio_message_player.dart';
import 'package:chataloka/widgets/chat/fullscreen_image_message_viewer.dart';
import 'package:chataloka/widgets/chat/text_message_viewer.dart';
import 'package:flutter/material.dart';

class MessageRenderer extends StatelessWidget {
  MessageRenderer({
    super.key,
    required this.messageModel,
    required this.textColor,
    required this.isMe,
    this.maxLines,
    this.overflow,
  });

  final MessageModel messageModel;
  final int? maxLines;
  final TextOverflow? overflow;
  final Color textColor;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    switch (messageModel.messageType) {
      case (MessageEnum.image):
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.7,
                    maxHeight: 250,
                  ),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => FullscreenImageMessageViewer(
                                message: messageModel.message,
                                imageUrl: messageModel.fileUrl!,
                              ),
                        ),
                      );
                    },
                    child: Hero(
                      tag: messageModel.fileUrl!,
                      child: CachedNetworkImage(
                        fit: BoxFit.cover,
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
              ),
            ),
            TextMessageViewer(
              messageModel: messageModel,
              textColor: textColor,
              isMe: isMe,
            ),
          ],
        );
      case MessageEnum.audio:
        return messageModel.fileUrl == null
            ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error, color: Colors.red),
                SizedBox(width: 8),
                Text('Audio message error.'),
              ],
            )
            : AudioMessagePlayer(audioUrl: messageModel.fileUrl!);
      case MessageEnum.video:
      case MessageEnum.text:
        return TextMessageViewer(
          messageModel: messageModel,
          textColor: textColor,
          isMe: isMe,
        );
    }
  }
}
