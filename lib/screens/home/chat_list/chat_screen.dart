import 'package:chataloka/constants/user_constants.dart';
import 'package:chataloka/widgets/bottom_chat_field.dart';
import 'package:chataloka/widgets/chat_app_bar.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  Map<String, String>? arguments;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        arguments =
            ModalRoute.of(context)?.settings.arguments as Map<String, String>;
        if (arguments?[UserConstant.friendUID] == null) {
          Navigator.of(context).pop();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final String? friendUID = arguments?[UserConstant.friendUID];
    final String? friendName = arguments?[UserConstant.friendName];
    final String? friendImage = arguments?[UserConstant.friendImage];
    final String? friendGroupUID = arguments?[UserConstant.friendGroupUID];
    final bool? isGroupChat = friendGroupUID != null && friendGroupUID.isNotEmpty;

    if (friendUID == null ||
        friendName == null ||
        friendImage == null ||
        friendGroupUID == null) {
      return SizedBox.shrink();
    }

    return Scaffold(
      appBar: AppBar(title: ChatAppBar(friendUID: friendUID)),
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
              friendUID: friendUID,
              friendName: friendName,
              friendImage: friendImage,
              friendGroupUID: friendGroupUID,
            ),
          ],
        ),
      ),
    );
  }
}
