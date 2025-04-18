import 'package:chataloka/providers/message_provider.dart';
import 'package:chataloka/theme/custom_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SendButton extends StatefulWidget {
  SendButton({
    super.key,
    required this.sendMessage,
    required this.startRecording,
    required this.stopRecording,
  });

  final VoidCallback sendMessage;
  final VoidCallback startRecording;
  final VoidCallback stopRecording;

  @override
  State<SendButton> createState() => _SendButtonState();
}

class _SendButtonState extends State<SendButton>
    with SingleTickerProviderStateMixin {
  late MessageProvider messageProvider;

  @override
  void initState() {
    super.initState();
    messageProvider = context.read<MessageProvider>();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final CustomTheme customTheme = Theme.of(context).extension<CustomTheme>()!;

    return GestureDetector(
      onTap: messageProvider.isShowSendButton ? widget.sendMessage : null,
      onLongPress:
          messageProvider.isShowSendButton ? null : widget.startRecording,
      onLongPressUp: widget.stopRecording,
      child: AnimatedScale(
        duration: Duration(milliseconds: 200),
        scale: messageProvider.isRecording ? 1.8 : 1.0,
        child: Container(
          decoration: BoxDecoration(
            color: customTheme.button.light,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: AnimatedSwitcher(
              duration: Duration(milliseconds: 200),
              transitionBuilder: (child, animation) {
                return ScaleTransition(scale: animation, child: child);
              },
              child:
                  messageProvider.isShowSendButton
                      ? const Icon(Icons.send, color: Colors.white, size: 16)
                      : const Icon(Icons.mic, color: Colors.white, size: 16),
            ),
          ),
        ),
      ),
    );
  }
}
