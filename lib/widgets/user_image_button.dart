import 'package:flutter/material.dart';
import 'package:chataloka/utilities/assets_manager.dart';

class UserImageButton extends StatelessWidget {
  final String? imageUrl;
  final double radius;
  final VoidCallback onTap;

  const UserImageButton({
    super.key,
    this.imageUrl,
    required this.radius,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: 20,
        backgroundImage:
            imageUrl != null
                ? NetworkImage(imageUrl!)
                : const AssetImage(AssetsManager.userImage),
      ),
    );
  }
}
