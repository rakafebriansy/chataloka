import 'package:chataloka/builders/build_rounded_image.dart';
import 'package:flutter/material.dart';

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
      child: buildRoundedImage(imageUrl: imageUrl, side: side)
    );
  }
}
