import 'dart:io';

import 'package:flutter/material.dart';

class AppBarBackButton extends StatelessWidget {
  final VoidCallback onPressed;

  const AppBarBackButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back),
    );
  }
}
