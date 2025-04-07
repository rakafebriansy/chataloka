import 'package:chataloka/constants/message_constants.dart';
import 'package:chataloka/constants/user_constants.dart';
import 'package:chataloka/utilities/global_methods.dart';
import 'package:chataloka/widgets/bottom_chat_field.dart';
import 'package:chataloka/widgets/chat_app_bar.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  ChatScreenArguments? args;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        setState(() {
          args =
              ModalRoute.of(context)?.settings.arguments as ChatScreenArguments;
        });
      } catch (error) {
        Navigator.of(context).pop();
        showErrorSnackbar(context, error);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (args == null) {
      return CircularProgressIndicator();
    }

    final bool isGroupChat = args!.groupUID != null && args!.groupUID!.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: ChatAppBar(contactUID: args!.contactUID)),
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
            BottomChatField(
              contactUID: args!.contactUID,
              contactName: args!.contactName,
              contactImage: args!.contactImage,
              groupUID: args!.groupUID,
            ),
          ],
        ),
      ),
    );
  }
}
