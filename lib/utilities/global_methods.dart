import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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

Future<File?> pickImage({required bool fromCamera}) async {
  final XFile? pickedFile = await ImagePicker().pickImage(source: fromCamera ? ImageSource.camera : ImageSource.gallery);
  if (pickedFile == null) {
    throw Exception('No image selected.');
  }
  return File(pickedFile.path);
}
