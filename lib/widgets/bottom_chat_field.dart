import 'dart:io';

import 'package:chataloka/constants/message_constants.dart';
import 'package:chataloka/models/user_model.dart';
import 'package:chataloka/providers/message_provider.dart';
import 'package:chataloka/providers/user_provider.dart';
import 'package:chataloka/utilities/global_methods.dart';
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

      CroppedFile croppedFile = await cropImage(file!.path);
      setState(() {
        file = File(croppedFile.path);
      });
      await sendFileMessage(MessageEnum.image);
      Navigator.of(context).pop();
    } catch (error) {
      showErrorSnackbar(context, error);
    }
  }

  Future<void> sendFileMessage(MessageEnum messageType) async {
    try {
      final UserModel? currentUser = context.read<UserProvider>().userModel;

      if (currentUser == null) {
        throw Exception('User not found. Please re-login!');
      }

      await messageProvider.sendMessageToFirebase(
        sender: currentUser,
        contactUID: widget.contactUID,
        contactName: widget.contactName,
        contactImage: widget.contactImage,
        message: messageType.name.toUpperCase(),
        messageType: MessageEnum.image,
        groupUID: widget.groupUID,
        file: file,
      );
    } catch (error) {
      showErrorSnackbar(context, error);
    }
  }

  Future<void> sendTextMessage() async {
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

      await messageProvider.sendMessageToFirebase(
        sender: currentUser,
        contactUID: widget.contactUID,
        contactName: widget.contactName,
        contactImage: widget.contactImage,
        message: _textEditingController.text,
        messageType: MessageEnum.text,
        groupUID: widget.groupUID,
      );

      _textEditingController.clear();
      _focusNode?.requestFocus();
      setState(() {});
    } catch (error) {
      showErrorSnackbar(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  children: [
                    messageReply != null
                        ? Container(
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
                                          color: Colors.black,
                                          fontWeight: FontWeight.w600,
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
                                Text(
                                  // textAlign: TextAlign.right,
                                  messageReply.message,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.openSans(
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        : SizedBox.shrink(),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              builder: (context) {
                                return SizedBox(
                                  height: 200,
                                  child: Column(
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
                                        leading: const Icon(
                                          Icons.video_library,
                                        ),
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
                                  ),
                                );
                              },
                            );
                          },
                          icon: const Icon(Icons.attachment),
                        ),
                        Expanded(
                          child: TextFormField(
                            onChanged: (_) {
                              setState(() {});
                            },
                            focusNode: _focusNode,
                            controller: _textEditingController,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Type a message',
                            ),
                          ),
                        ),
                        AnimatedSwitcher(
                          duration: Duration(milliseconds: 200),
                          transitionBuilder: (child, animation) {
                            return ScaleTransition(
                              scale: animation,
                              child: child,
                            );
                          },
                          child:
                              _textEditingController != null &&
                                      _textEditingController.text.isNotEmpty
                                  ? Padding(
                                    padding: const EdgeInsets.all(4),
                                    child:
                                        messageProvider.isLoading
                                            ? Transform.scale(
                                              scale: 0.5,
                                              child:
                                                  CircularProgressIndicator(),
                                            )
                                            : GestureDetector(
                                              onTap: () async {
                                                await sendTextMessage();
                                              },
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color:
                                                      Theme.of(
                                                        context,
                                                      ).primaryColor,
                                                  borderRadius:
                                                      BorderRadius.circular(30),
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                    12,
                                                  ),
                                                  child: const Icon(
                                                    Icons.send,
                                                    color: Colors.white,
                                                    size: 16,
                                                  ),
                                                ),
                                              ),
                                            ),
                                  )
                                  : SizedBox(width: 44),
                        ),
                      ],
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
