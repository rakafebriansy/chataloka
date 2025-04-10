import 'dart:io';

import 'package:chataloka/utilities/assets_manager.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:firebase_storage/firebase_storage.dart';

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

Future<CroppedFile> cropImage(String filePath) async {
  final CroppedFile? croppedFile = await ImageCropper().cropImage(
    sourcePath: filePath,
    maxHeight: 800,
    maxWidth: 800,
    compressQuality: 90,
  );

  if (croppedFile == null) {
    throw Exception('Failed to crop image');
  }

  return croppedFile;
}

String generateFileName({required String fileName, String? extension}) {
  String timestamp = DateTime.now().toIso8601String().replaceAll(":", "-");
  return "${timestamp}_$fileName.${extension ?? ''}";
}

String formatChatListDate(DateTime sentAt) {
  final now = DateTime.now();
  final sentDate = DateTime(sentAt.year, sentAt.month, sentAt.day);
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(Duration(days: 1));

  if (sentDate == today) {
    return DateFormat.Hm().format(sentAt);
  } else if (sentDate == yesterday) {
    return "Yesterday";
  } else {
    return DateFormat('dd/MM/yyyy').format(sentAt);
  }
}

String formatChatHeaderDate(DateTime sentAt) {
  final now = DateTime.now();
  final sentDate = DateTime(sentAt.year, sentAt.month, sentAt.day);
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(Duration(days: 1));

  if (sentDate == today) {
    return "Today";
  } else if (sentDate == yesterday) {
    return "Yesterday";
  } else {
    return DateFormat('MMM d, y').format(sentAt);
  }
}

Future<String> storeFileToFirebaseStorage({
  required File file,
  required String reference,
}) async {
  UploadTask uploadTask = FirebaseStorage.instance
      .ref()
      .child(reference)
      .putFile(file);
  TaskSnapshot taskSnapshot = await uploadTask;
  String fileUrl = await taskSnapshot.ref.getDownloadURL();
  return fileUrl;
}
