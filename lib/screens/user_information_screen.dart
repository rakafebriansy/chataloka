import 'dart:io';

import 'package:chataloka/constants/route_constants.dart';
import 'package:chataloka/models/user_model.dart';
import 'package:chataloka/providers/user_provider.dart';
import 'package:chataloka/utilities/global_methods.dart';
import 'package:chataloka/widgets/app_bar_back_button.dart';
import 'package:chataloka/widgets/display_user_image.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:provider/provider.dart';
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

  Future<void> selectImage(bool fromCamera) async {
    try {
      finalFileImage = await pickImage(fromCamera: fromCamera);

      if (finalFileImage == null) {
        throw Exception('No image selected');
      }

      await cropImage(finalFileImage!.path);
      Navigator.of(context).pop();
    } catch (error) {
      showErrorSnackbar(context, error);
    }
  }

  Future<void> cropImage(String filePath) async {
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
                  onTap: () async {
                    await selectImage(true);
                  },
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Camera'),
                ),
                ListTile(
                  onTap: () async {
                    await selectImage(false);
                  },
                  leading: const Icon(Icons.image),
                  title: const Text('Gallery'),
                ),
              ],
            ),
          ),
    );
  }

  Future<void> submitUserInformation() async {
    try {
      if (_nameController.text.isEmpty) {
        throw Exception('Name is required');
      } else if (_nameController.text.length < 3) {
        throw Exception('Name must be at least 3 characters');
      } else if (finalFileImage == null) {
        throw Exception('No image selected');
      }
      final userProvider = context.read<UserProvider>();
      UserModel userModel = UserModel(
        uid: userProvider.uid!,
        name: _nameController.text.trim(),
        phoneNumber: userProvider.phoneNumber!,
        image: '',
        token: '',
        aboutMe: 'Hey there, I\'m using Chataloka',
        lastSeen: '',
        createdAt: '',
        isOnline: true,
        friendsUIDs: [],
        friendRequestsUIDs: [],
        sentFriendRequestUIDs: [],
      );

      await userProvider.saveUserDataToFirestore(
        userModel: userModel,
        imageFile: finalFileImage,
      );

      _btnController.success();

      await userProvider.saveUserDataToSharedPreferences();

      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(RouteConstant.homeScreen, (route) => false);
    } catch (error) {
      showErrorSnackbar(context, error);
      _btnController.error();
    } finally {
      await Future.delayed(const Duration(seconds: 1));
      _btnController.reset();
    }
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
                context:context,
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
                  onPressed: () async {
                    submitUserInformation();
                  },
                  successIcon: Icons.check,
                  successColor: Colors.green,
                  errorColor: Colors.red,
                  color: Theme.of(context).colorScheme.primary,
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
