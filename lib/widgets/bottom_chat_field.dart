import 'dart:io';

import 'package:chataloka/constants/message_constants.dart';
import 'package:chataloka/models/user_model.dart';
import 'package:chataloka/providers/message_provider.dart';
import 'package:chataloka/providers/user_provider.dart';
import 'package:chataloka/theme/custom_theme.dart';
import 'package:chataloka/utilities/global_methods.dart';
import 'package:chataloka/widgets/chat_input.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:provider/provider.dart';

class BottomChatField extends StatefulWidget {
  const BottomChatField({
    super.key,
    required this.contactUID,
    required this.contactName,
    required this.contactImage,
    this.groupUID,
  });

  final String contactUID;
  final String contactName;
  final String contactImage;
  final String? groupUID;

  @override
  State<BottomChatField> createState() => _BottomChatFieldState();
}

class _BottomChatFieldState extends State<BottomChatField> {
  late final TextEditingController? _textEditingController;
  late final FocusNode? _focusNode;
  File? file;
  late final MessageProvider messageProvider;

  @override
  void initState() {
    super.initState();
    messageProvider = context.read<MessageProvider>();
    _textEditingController = TextEditingController();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _textEditingController?.dispose();
    _focusNode?.dispose();
    super.dispose();
  }

  Future<void> selectImage(bool fromCamera) async {
    try {
      file = await pickImage(fromCamera: fromCamera);

      if (file == null) {
        throw Exception('No image selected');
      }
      Navigator.of(context).pop();

      CroppedFile croppedFile = await cropImage(file!.path);
      setState(() {
        file = File(croppedFile.path);
      });
    } catch (error) {
      showErrorSnackbar(context, error);
    }
  }

  Future<void> sendMessage() async {
    try {
      if (_textEditingController == null ||
          _textEditingController.text.isEmpty) {
        return;
      }
      final UserModel? currentUser = context.read<UserProvider>().userModel;
      final MessageProvider messageProvider = context.read<MessageProvider>();

      if (currentUser == null) {
        throw Exception('User not found. Please re-login!');
      }

      if (file == null) {
        await messageProvider.sendMessageToFirebase(
          sender: currentUser,
          contactUID: widget.contactUID,
          contactName: widget.contactName,
          contactImage: widget.contactImage,
          message: _textEditingController.text,
          messageType: MessageEnum.text,
          groupUID: widget.groupUID,
        );
      } else {
        await messageProvider.sendMessageToFirebase(
          sender: currentUser,
          contactUID: widget.contactUID,
          contactName: widget.contactName,
          contactImage: widget.contactImage,
          message: _textEditingController.text,
          messageType: MessageEnum.image,
          groupUID: widget.groupUID,
          file: file,
        );
      }

      _textEditingController.clear();
      _focusNode?.requestFocus();
      setState(() {
        if (file != null) {
          file = null;
        }
      });
    } catch (error) {
      showErrorSnackbar(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final CustomTheme customTheme = Theme.of(context).extension<CustomTheme>()!;

    return Consumer<MessageProvider>(
      builder: (context, messageProvider, child) {
        final messageReply = messageProvider.messageReplyModel;

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).canvasColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (messageReply != null)
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      messageReply.isMe
                                          ? 'You'
                                          : messageReply.senderName,
                                      style: GoogleFonts.openSans(
                                        color: customTheme.text.light,
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      messageProvider.setMessageReplyModel(
                                        null,
                                      );
                                    },
                                    child: const Icon(Icons.close, size: 14),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              RichText(
                                text: TextSpan(
                                  children: [
                                    if (messageReply. messageType ==
                                        MessageEnum.image)
                                      WidgetSpan(
                                        alignment: PlaceholderAlignment.middle,
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            right: 4,
                                          ),
                                          child: Icon(
                                            Icons.image,
                                            size: 16,
                                            color: customTheme.text.light,
                                          ),
                                        ),
                                      ),
                                    TextSpan(
                                      text: messageReply.message,
                                      style: GoogleFonts.openSans(
                                        color: customTheme.text.light,
                                      ),
                                    ),
                                  ],
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    AnimatedSwitcher(
                      duration: Duration(milliseconds: 100),
                      transitionBuilder: (child, animation) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                      child:
                          file != null
                              ? Stack(
                                children: [
                                  Container(
                                    constraints: BoxConstraints(
                                      maxWidth: double.infinity,
                                      maxHeight: 160,
                                    ),
                                    padding: const EdgeInsets.all(8.0),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.file(
                                        file!,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 12,
                                    right: 12,
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          file = null;
                                        });
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.8),
                                          shape: BoxShape.circle,
                                        ),
                                        padding: const EdgeInsets.all(4),
                                        child: const Icon(
                                          Icons.close,
                                          color: Colors.black,
                                          size: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                              : SizedBox.shrink(),
                    ),
                    ChatInput(
                      messageProvider: messageProvider,
                      focusNode: _focusNode,
                      textEditingController: _textEditingController,
                      onInputChanged: (_) {
                        setState(() {});
                      },
                      onSend: () async {
                        await sendMessage();
                      },
                      onButtonPressed: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (context) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ListTile(
                                  leading: const Icon(Icons.camera_alt),
                                  title: const Text('Camera'),
                                  onTap: () {
                                    selectImage(true);
                                  },
                                ),
                                ListTile(
                                  leading: const Icon(Icons.image),
                                  title: const Text('Images'),
                                  onTap: () {
                                    selectImage(false);
                                  },
                                ),
                                ListTile(
                                  leading: const Icon(Icons.video_library),
                                  title: const Text('Video'),
                                  onTap: () {},
                                ),
                                ListTile(
                                  leading: const Icon(Icons.image),
                                  title: const Text('Gallery'),
                                  onTap: () {
                                    selectImage(false);
                                  },
                                ),
                                ListTile(
                                  leading: const Icon(Icons.audio_file),
                                  title: const Text('Audio'),
                                  onTap: () {},
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
