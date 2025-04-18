import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chataloka/constants/message_constants.dart';
import 'package:chataloka/models/user_model.dart';
import 'package:chataloka/providers/message_provider.dart';
import 'package:chataloka/providers/user_provider.dart';
import 'package:chataloka/theme/custom_theme.dart';
import 'package:chataloka/utilities/assets_manager.dart';
import 'package:chataloka/utilities/global_methods.dart';
import 'package:chataloka/widgets/chat/pulse_recording_icon.dart';
import 'package:chataloka/widgets/chat/send_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound_record/flutter_sound_record.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
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
  late final MessageProvider messageProvider;
  MessageEnum? messageType;

  late final TextEditingController? _textEditingController;
  late final FocusNode? _focusNode;

  File? file;
  String? filePath;

  FlutterSoundRecord? _soundRecord;
  Timer? _recordingTimer;
  Duration _recordingDuration = Duration.zero;

  void startRecordingTimer() {
    _recordingDuration = Duration.zero;
    _recordingTimer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      setState(() {
        _recordingDuration += Duration(milliseconds: 100);
      });
    });
  }

  void stopRecordingTimer() {
    _recordingTimer?.cancel();
    _recordingTimer = null;
    _recordingDuration = Duration.zero;
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
        messageType = MessageEnum.image;
      });
      messageProvider.setIsShowSendButton(true);
    } catch (error) {
      showErrorSnackbar(context, error);
    }
  }

  void removeImage() {
    setState(() {
      file = null;
      messageType = null;
    });
      messageProvider.setIsShowSendButton(false);
  }

  Future<bool> checkMicrophonePermission() async {
    if (await Permission.microphone.isGranted) return true;

    final PermissionStatus status = await Permission.microphone.request();
    return status == PermissionStatus.granted;
  }

  Future<void> startRecording() async {
    try {
      messageProvider.setIsRecording(true);
      final hasPermission = await checkMicrophonePermission();
      if (hasPermission) {
        final Directory tempDir = await getTemporaryDirectory();
        filePath = '${tempDir.path}/flutter_sound.aac';
        if (_soundRecord == null) {
          throw Exception('Sound recorder driver is not found.');
        }
        await _soundRecord!.start(path: filePath);
      }
      startRecordingTimer();
    } catch (error) {
      showErrorSnackbar(context, error);
    }
  }

  Future<void> stopRecording() async {
    try {
      await _soundRecord!.stop();
      setState(() {
        messageType = MessageEnum.audio;
        if (filePath != null) {
          file = File(filePath!);
        }
      });
      messageProvider.setIsShowSendButton(true);
      messageProvider.setIsRecording(false);
      stopRecordingTimer();
      await sendMessage();
    } catch (error) {
      showErrorSnackbar(context, error);
    }
  }

  Future<Duration?> getAudioDuration(String filePath) async {
    final player = AudioPlayer();
    try {
      await player.setSourceDeviceFile(filePath);
      await player.resume();

      await Future.delayed(Duration.zero);

      final duration = await player.getDuration();
      await player.stop();
      return duration;
    } catch (error) {
      showErrorSnackbar(context, error);
      return null;
    } finally {
      await player.dispose();
    }
  }

  Future<void> sendMessage() async {
    try {
      if (_textEditingController == null) {
        return;
      }
      final UserModel? currentUser = context.read<UserProvider>().userModel;
      final MessageProvider messageProvider = context.read<MessageProvider>();

      if (currentUser == null) {
        throw Exception('User not found. Please re-login!');
      }

      Duration? audioDuration =
          messageType == MessageEnum.audio
              ? await getAudioDuration(filePath!)
              : null;

      if (messageType == null && file == null) {
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
          message:
              messageType == MessageEnum.audio
                  ? formatDuration(audioDuration ?? Duration())
                  : _textEditingController.text,
          messageType: messageType!,
          groupUID: widget.groupUID,
          file: file,
        );
      }
    } catch (error) {
      showErrorSnackbar(context, error);
    } finally {
      _textEditingController?.clear();
      _focusNode?.unfocus();
      setState(() {
        if (file != null) file = null;
        if (messageType != null) messageType = null;
        if (filePath != null) filePath = null;
      });
      messageProvider.setIsShowSendButton(false);
    }
  }

  @override
  void initState() {
    super.initState();
    messageProvider = context.read<MessageProvider>();
    _textEditingController = TextEditingController();
    _focusNode = FocusNode();
    _soundRecord = FlutterSoundRecord();
  }

  @override
  void dispose() {
    _textEditingController?.dispose();
    _focusNode?.dispose();
    _soundRecord?.dispose();
    super.dispose();
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
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Stack(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          messageReply.isMe
                                              ? 'You'
                                              : messageReply.senderName,
                                          style: GoogleFonts.openSans(
                                            color: customTheme.text.light,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        RichText(
                                          text: TextSpan(
                                            children: [
                                              WidgetSpan(
                                                alignment:
                                                    PlaceholderAlignment.middle,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        right: 4,
                                                      ),
                                                  child: Icon(
                                                    messageReply.messageType ==
                                                            MessageEnum.audio
                                                        ? Icons.mic
                                                        : messageReply
                                                                .messageType ==
                                                            MessageEnum.image
                                                        ? Icons.image
                                                        : null,
                                                    size: 16,
                                                    color:
                                                        customTheme.text.light,
                                                  ),
                                                ),
                                              ),
                                              TextSpan(
                                                text:
                                                    messageReply.messageType ==
                                                            MessageEnum.audio
                                                        ? 'Audio message (${messageReply.message})'
                                                        : messageReply.message,
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
                                  if (messageReply.fileUrl != null &&
                                      messageReply.fileUrl!.isNotEmpty) ...[
                                    SizedBox(width: 18),
                                    if (messageReply.messageType ==
                                        MessageEnum.image)
                                      Container(
                                        constraints: BoxConstraints(
                                          maxWidth: 60,
                                          maxHeight: 60,
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.only(
                                            bottomRight: Radius.circular(10),
                                            topRight: Radius.circular(10),
                                          ),
                                          child: CachedNetworkImage(
                                            fit: BoxFit.cover,
                                            imageUrl: messageReply.fileUrl!,
                                            placeholder:
                                                (context, url) => Center(
                                                  child:
                                                      CircularProgressIndicator(),
                                                ),
                                            errorWidget:
                                                (context, url, error) =>
                                                    Image.asset(
                                                      AssetsManager.imageError,
                                                    ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ],
                              ),
                              Positioned(
                                top: 2,
                                right: 2,
                                child: GestureDetector(
                                  onTap: () {
                                    messageProvider.setMessageReplyModel(null);
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white70,
                                      borderRadius: BorderRadius.circular(40),
                                    ),
                                    child: const Icon(Icons.close, size: 14),
                                  ),
                                ),
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
                          file != null && messageType != MessageEnum.audio
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
                                        removeImage();
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

                    Row(
                      children: [
                        messageProvider.isRecording
                            ? Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: PulseRecordingIcon(),
                            )
                            : IconButton(
                              onPressed: () {
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
                                    );
                                  },
                                );
                              },
                              icon: const Icon(Icons.attachment),
                            ),
                        Expanded(
                          child:
                              messageProvider.isRecording
                                  ? Text(
                                    '${formatDuration(_recordingDuration)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                  : TextFormField(
                                    onChanged: (_) {
                                      if (_textEditingController != null) {
                                        setState(() {
                                          messageProvider.setIsShowSendButton(
                                            _textEditingController
                                                .text
                                                .isNotEmpty,
                                          );
                                        });
                                      }
                                    },
                                    focusNode: _focusNode,
                                    controller: _textEditingController,
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      hintText: 'Type a message',
                                    ),
                                  ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(4),
                          child:
                              messageProvider.isLoading
                                  ? Transform.scale(
                                    scale: 0.5,
                                    child: CircularProgressIndicator(),
                                  )
                                  : SendButton(
                                    sendMessage: sendMessage,
                                    startRecording: startRecording,
                                    stopRecording: stopRecording,
                                  ),
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
