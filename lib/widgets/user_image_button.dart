import 'package:flutter/material.dart';
import 'package:chataloka/utilities/assets_manager.dart';

class UserImageButton extends StatelessWidget {
  final String? imageUrl;
  final double side;
  final VoidCallback onTap;

  const UserImageButton({
    super.key,
    this.imageUrl,
    required this.side,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipOval(
        child: SizedBox(
          width: side,
          height: side,
          child:
              imageUrl != null
                  ? Image.network(
                    imageUrl!,
                    loadingBuilder: (
                      BuildContext context,
                      Widget child,
                      ImageChunkEvent? loadingProgress,
                    ) {
                      if (loadingProgress == null) {
                        return child;
                      }
                      return Center(
                        child: CircularProgressIndicator(
                          value:
                              loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      (loadingProgress.expectedTotalBytes ?? 1)
                                  : null,
                          strokeWidth: 2,
                        ),
                      );
                    },
                    fit: BoxFit.cover,
                  )
                  : Image.asset(AssetsManager.userImage),
        ),
      ),
    );
  }
}
