import 'package:cached_network_image/cached_network_image.dart';
import 'package:chataloka/constants/message_constants.dart';
import 'package:chataloka/utilities/assets_manager.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DisplayMessageType extends StatelessWidget {
  DisplayMessageType({
    super.key,
    required this.message,
    required this.messageType,
    required this.color,
    this.fileUrl,
    this.maxLines,
    this.overflow,
  });

  final String message;
  final MessageEnum messageType;
  final String? fileUrl;
  final int? maxLines;
  final TextOverflow? overflow;
  final Color color;

  @override
  Widget build(BuildContext context) {
    switch (messageType) {
      case (MessageEnum.image):
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.6,
                  maxHeight: 250,
                ),
                child:
                    fileUrl == null
                        ? Image.asset(AssetsManager.imageError)
                        : CachedNetworkImage(
                          imageUrl: fileUrl!,
                          placeholder:
                              (context, url) =>
                                  Center(child: CircularProgressIndicator()),
                          errorWidget:
                              (context, url, error) =>
                                  Image.asset(AssetsManager.imageError),
                        ),
              ),
            ),
            SizedBox(height: 10,),
            Text(
              message,
              style: GoogleFonts.openSans(color: color),
              maxLines: maxLines,
              overflow: overflow,
            ),
          ],
        );
      case MessageEnum.video:
      case MessageEnum.audio:
      case MessageEnum.text:
        return Text(
          message,
          style: GoogleFonts.openSans(color: color),
          maxLines: maxLines,
          overflow: overflow,
        );
    }
  }
}
