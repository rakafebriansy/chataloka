import 'dart:io';

import 'package:chataloka/constants/route_constants.dart';
import 'package:chataloka/models/user_model.dart';
import 'package:chataloka/providers/user_provider.dart';
import 'package:chataloka/theme/custom_theme.dart';
import 'package:chataloka/utilities/global_methods.dart';
import 'package:chataloka/widgets/app_bar/app_bar_back_button.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';
import 'package:chataloka/utilities/assets_manager.dart';

class UserInformationScreen extends StatefulWidget {
  const UserInformationScreen({super.key});

  @override
  State<UserInformationScreen> createState() => _UserInformationScreenState();
}

class _UserInformationScreenState extends State<UserInformationScreen> {
  final RoundedLoadingButtonController _btnController =
      RoundedLoadingButtonController();
  final _nameController = TextEditingController();

  File? imageFile;

  @override
  void dispose() {
    _btnController.stop();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> selectImage(bool fromCamera) async {
    try {
      imageFile = await pickImage(fromCamera: fromCamera);

      if (imageFile == null) {
        throw Exception('No image selected');
      }

      CroppedFile croppedFile = await cropImage(imageFile!.path);
      setState(() {
        imageFile = File(croppedFile.path);
      });
      Navigator.of(context).pop();
    } catch (error) {
      showErrorSnackbar(context, error);
    }
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
      } else if (imageFile == null) {
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
        lastSeen: DateTime.now(),
        createdAt: DateTime.now(),
        isOnline: true,
        friendsUIDs: [],
        friendRequestsUIDs: [],
        sentFriendRequestUIDs: [],
      );

      await userProvider.saveUserDataToFirestore(
        userModel: userModel,
        imageFile: imageFile,
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
    final customTheme = Theme.of(context).extension<CustomTheme>()!;

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
              imageFile == null
                  ? Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundImage: const AssetImage(
                          AssetsManager.userImage,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: InkWell(
                          onTap: () {
                            showImagePicker();
                          },
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor:
                                customTheme.button.light,
                            child: Icon(
                              Icons.camera_alt,
                              color: customTheme.text.dark,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                  : Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundImage: FileImage(File(imageFile!.path)),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: InkWell(
                          onTap: () {
                            showImagePicker();
                          },
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor:
                                customTheme.button.light,
                            child: Icon(
                              Icons.camera_alt,
                              color: customTheme.text.dark,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
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
                  color: customTheme.button.light,
                  borderRadius: 10,
                  width: screenWidth - 40,
                  child: Text(
                    'Continue',
                    style: TextStyle(
                      color: customTheme.text.dark,
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
