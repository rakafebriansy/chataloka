import 'package:cached_network_image/cached_network_image.dart';
import 'package:chataloka/utilities/assets_manager.dart';
import 'package:flutter/material.dart';

Widget buildRoundedImage({required String? imageUrl, required double side}) {
  return ClipOval(
    child: SizedBox(
      width: side,
      height: side,
      child:
          imageUrl != null
              ? CachedNetworkImage(
                imageUrl:  imageUrl,
                placeholder: (context, url) => Center(
                    child: SizedBox(
                      height: side,
                      width: side,
                      child: CircularProgressIndicator(
                        strokeWidth: 4,
                      ),
                    ),
                  ),
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => Icon(Icons.error),
              )
              : Image.asset(AssetsManager.userImage),
    ),
  );
}
