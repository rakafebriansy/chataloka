import 'package:chataloka/constants/message_constants.dart';
import 'package:chataloka/models/user_model.dart';
import 'package:chataloka/providers/chat_provider.dart';
import 'package:chataloka/providers/user_provider.dart';
import 'package:chataloka/utilities/global_methods.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BottomChatField extends StatefulWidget {
  const BottomChatField({
    super.key,
    required this.friendUID,
    required this.friendName,
    required this.friendImage,
    required this.friendGroupUID,
  });

  final String friendUID;
  final String friendName;
  final String friendImage;
  final String friendGroupUID;

  @override
  State<BottomChatField> createState() => _BottomChatFieldState();
}

class _BottomChatFieldState extends State<BottomChatField> {
  late final TextEditingController? _textEditingController;
  late final FocusNode? _focusNode;

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _textEditingController?.dispose();
    _focusNode?.dispose();
    super.dispose();
  }

  Future<void> sendTextMessage() async {
    try {
      if (_textEditingController == null ||
          _textEditingController.text.isEmpty) {
        return;
      }
      final UserModel? currentUser = context.read<UserProvider>().userModel;
      final chatProvider = context.read<ChatProvider>();

      if (currentUser == null) {
        throw Exception('User not found. Please re-login!');
      }

      await chatProvider.sendTextMessageToFirestore(
        sender: currentUser,
        receiverUID: widget.friendUID,
        receiverName: widget.friendName,
        receiverImage: widget.friendImage,
        message: _textEditingController.text,
        messageType: MessageEnum.text,
        groupUID: widget.friendGroupUID,
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
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).canvasColor,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Theme.of(context).primaryColor),
        ),
        child: Row(
          children: [
            IconButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return SizedBox(
                      height: 200,
                      child: const Center(child: Text('Attachment')),
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
                return ScaleTransition(scale: animation, child: child);
              },
              child:
                  _textEditingController != null &&
                          _textEditingController.text.isNotEmpty
                      ? Padding(
                        padding: const EdgeInsets.all(4),
                        child: GestureDetector(
                          onTap: () async {
                            await sendTextMessage();
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
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
      ),
    );
  }
}
