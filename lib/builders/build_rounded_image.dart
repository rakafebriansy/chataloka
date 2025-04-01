import 'package:chataloka/utilities/assets_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget buildRoundedImage({required String? imageUrl, required double side}) {
  return ClipOval(
    child: SizedBox(
      width: side,
      height: side,
      child:
          imageUrl != null
              ? Image.network(
                imageUrl,
                loadingBuilder: (
                  BuildContext context,
                  Widget child,
                  ImageChunkEvent? loadingProgress,
                ) {
                  if (loadingProgress == null) {
                    return child;
                  }
                  return Center(
                    child: SizedBox(
                      height: side,
                      width: side,
                      child: CircularProgressIndicator(
                        value:
                            loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    (loadingProgress.expectedTotalBytes ?? 1)
                                : null,
                        strokeWidth: 4,
                      ),
                    ),
                  );
                },
                fit: BoxFit.cover,
              )
              : Image.asset(AssetsManager.userImage),
    ),
  );
}
