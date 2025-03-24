import 'dart:io';

import 'package:chataloka/utilities/assets_manager.dart';
import 'package:chataloka/utilities/global_methods.dart';
import 'package:chataloka/widgets/app_bar_back_button.dart';
import 'package:chataloka/widgets/display_user_image.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';

class UserInformationScreen extends StatefulWidget {
  const UserInformationScreen({super.key});

  @override
  State<UserInformationScreen> createState() => _UserInformationScreenState();
}

class _UserInformationScreenState extends State<UserInformationScreen> {
  final RoundedLoadingButtonController _btnController =
      RoundedLoadingButtonController();
  final _nameController = TextEditingController();

  File? finalFileImage;
  String? userImage;

  @override
  void dispose() {
    _btnController.stop();
    _nameController.dispose();
    super.dispose();
  }

  void selectImage(bool fromCamera) async {
    try {
      finalFileImage = await pickImage(fromCamera: fromCamera);

      if (finalFileImage == null) {
        throw Exception('No image selected');
      }
      cropImage(finalFileImage!.path);
    } catch (error) {
      showErrorSnackbar(context, error as Exception);
    }
  }

  void cropImage(String filePath) async {
    final CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: filePath,
      maxHeight: 800,
      maxWidth: 800,
      compressQuality: 90,
    );

    if (croppedFile == null) {
      throw Exception('Failed to crop image');
    }
    setState(() {
      finalFileImage = File(croppedFile.path);
    });
  }

  void showImagePicker() {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => SizedBox(
            height: MediaQuery.of(context).size.height / 7,
            child: Column(
              children: [
                ListTile(
                  onTap: () {
                    selectImage(true);
                    Navigator.of(context).pop();
                  },
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Camera'),
                ),
                ListTile(
                  onTap: () {
                    selectImage(false);
                    Navigator.of(context).pop();
                  },
                  leading: const Icon(Icons.image),
                  title: const Text('Gallery'),
                ),
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        leading: AppBarBackButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        centerTitle: true,
        title: const Text('User Information'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              DisplayUserImage(
                finalFileImage: finalFileImage,
                radius: 60,
                onPressed: () {
                  showImagePicker();
                },
              ),
              const SizedBox(height: 30),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'Enter your name',
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: RoundedLoadingButton(
                  controller: _btnController,
                  onPressed: () {
                    
                    _btnController.success();
                  },
                  successIcon: Icons.check,
                  successColor: Colors.green,
                  errorColor: Colors.red,
                  color: Theme.of(context).primaryColor,
                  borderRadius: 10,
                  width: screenWidth - 40,
                  child: const Text(
                    'Continue',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
