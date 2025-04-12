import 'package:chataloka/providers/message_provider.dart';
import 'package:flutter/material.dart';

class ChatInput extends StatelessWidget {
  ChatInput({
    super.key,
    required this.onButtonPressed,
    required this.onInputChanged,
    required this.focusNode,
    required this.textEditingController,
    required this.messageProvider,
    required this.onSend,
  });

  final FocusNode? focusNode;
  final TextEditingController? textEditingController;
  final VoidCallback onButtonPressed;
  final VoidCallback onSend;
  final MessageProvider messageProvider;
  final ValueChanged<String?> onInputChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: onButtonPressed,
          icon: const Icon(Icons.attachment),
        ),
        Expanded(
          child: TextFormField(
            onChanged: onInputChanged,
            focusNode: focusNode,
            controller: textEditingController,
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
              textEditingController != null &&
                      textEditingController!.text.isNotEmpty
                  ? Padding(
                    padding: const EdgeInsets.all(4),
                    child:
                        messageProvider.isLoading
                            ? Transform.scale(
                              scale: 0.5,
                              child: CircularProgressIndicator(),
                            )
                            : GestureDetector(
                              onTap: onSend,
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
                  : SizedBox.shrink(),
        ),
      ],
    );
  }
}
