import 'package:chataloka/constants/user.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    final Map<String, String> arguments =
        ModalRoute.of(context)?.settings.arguments as Map<String, String>;
    final String? friendUID = arguments[UserConstant.friendUID];
    final String? groupId = arguments[UserConstant.groupId];
    final bool? isGroupChat = groupId?.isNotEmpty;
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: 20,
                itemBuilder: (context, index) {
                  return ListTile(title: Text('data'));
                },
              ),
            ),
            TextFormField(
              decoration: InputDecoration(
                hintText: 'Type a message',
                suffixIcon: Icon(Icons.send),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
