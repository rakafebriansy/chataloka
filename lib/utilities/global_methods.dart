import 'package:flutter/material.dart';

void showSnackBar({
  required BuildContext context,
  required String message,
  int? durationInSeconds,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      duration: Duration(seconds: durationInSeconds ?? 2),
    ),
  );
}

