import 'dart:io';

import 'package:chataloka/utilities/assets_manager.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

void showChatalokaDialog({
  required BuildContext context,
  required Widget content,
  String? confirmLabel,
  String? cancelLabel,
  VoidCallback? onConfirm,
  VoidCallback? onCancel,
  Color? confirmColor,
}) {
  showDialog(
    context: context,
    builder:
        (context) => AlertDialog(
          title: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(AssetsManager.chataloka, height: 30),
              SizedBox(width: 10),
              Text(
                'Chataloka',
                style: GoogleFonts.openSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: content,
          actions: [
            if (confirmLabel != null)
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: confirmColor ?? Colors.black,
                  textStyle: TextStyle(fontWeight: FontWeight.bold),
                ),
                onPressed: onConfirm,
                child: Text(confirmLabel, style: GoogleFonts.openSans()),
              ),
            if (cancelLabel != null)
              TextButton(
                onPressed: onCancel ?? () {},
                child: Text(cancelLabel, style: GoogleFonts.openSans()),
              ),
          ],
        ),
  );
}

void showErrorSnackbar(BuildContext context, dynamic error) {
  final String errorString = error.toString();
  print(error);
  showSnackBar(
    context: context,
    message: errorString.length < 50 ? errorString : 'Something went wrong.',
  );
}

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
  final XFile? pickedFile = await ImagePicker().pickImage(
    source: fromCamera ? ImageSource.camera : ImageSource.gallery,
  );
  if (pickedFile == null) {
    throw Exception('No image selected.');
  }
  return File(pickedFile.path);
}

String generateFileName({required String fileName, String? extension}) {
  String timestamp = DateTime.now().toIso8601String().replaceAll(":", "-");
  return "${timestamp}_$fileName.${extension ?? ''}";
}
