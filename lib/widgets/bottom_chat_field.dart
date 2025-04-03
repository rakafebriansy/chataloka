import 'package:flutter/material.dart';

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
  final TextEditingController textController = TextEditingController();

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
            IconButton(onPressed: () {}, icon: const Icon(Icons.attachment)),
            Expanded(
              child: TextFormField(
                onChanged: (_) {
                  setState(() {});
                },
                controller: textController,
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
                  textController.text.isNotEmpty
                      ? Padding(
                        padding: const EdgeInsets.all(4),
                        child: GestureDetector(
                          onTap: () {
                            textController.clear();
                            setState(() {});
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
