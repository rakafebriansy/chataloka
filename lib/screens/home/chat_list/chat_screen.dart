import 'package:chataloka/constants/message_constants.dart';
import 'package:chataloka/constants/user_constants.dart';
import 'package:chataloka/models/message_model.dart';
import 'package:chataloka/providers/message_provider.dart';
import 'package:chataloka/providers/user_provider.dart';
import 'package:chataloka/utilities/global_methods.dart';
import 'package:chataloka/widgets/bottom_chat_field.dart';
import 'package:chataloka/widgets/chat_app_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String? uid;
  ChatScreenArguments? args;
  late final Stream<QuerySnapshot>? _chatStream;
  late final MessageProvider messageProvider;
  late final bool isGroupChat =
      args?.groupUID != null && args!.groupUID!.isNotEmpty;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        final chatArguments =
            ModalRoute.of(context)?.settings.arguments as ChatScreenArguments;
        final userUID = context.read<UserProvider>().userModel?.uid;
        if (userUID == null || args == null) {
          Navigator.of(context).pop();
          throw Exception('User or contact is not found');
        }
        setState(() {
          args = chatArguments;
          uid = userUID;
        });
        messageProvider = context.read<MessageProvider>();
        _chatStream = messageProvider.getMessagesStream(
          userUID: userUID,
          contactUID: chatArguments.contactUID,
        );
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

    return Scaffold(
      appBar: AppBar(title: ChatAppBar(contactUID: args!.contactUID)),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child:
                  _chatStream != null
                      ? StreamBuilder(
                        stream: _chatStream,
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Center(
                              child: Text(
                                'Something went wrong.',
                                style: GoogleFonts.openSans(),
                              ),
                            );
                          }

                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          if (!snapshot.hasData ||
                              snapshot.data!.docs.isEmpty) {
                            return Center(
                              child: Text(
                                'No chats yet.',
                                style: GoogleFonts.openSans(),
                              ),
                            );
                          }

                          return ListView(
                            children:
                                snapshot.data!.docs.map((DocumentSnapshot doc) {
                                  MessageModel messageModel =
                                      MessageModel.fromMap(
                                        doc.data() as Map<String, dynamic>,
                                      );
                                  final isMe = messageModel.senderUID == uid;
                                  final color = isMe ? Theme.of(context).primaryColor : Theme.of(context).cardColor;

                                  return Card(
                                    color: color,
                                    child: ListTile(
                                      title: Text(
                                        messageModel.message,
                                        style: GoogleFonts.openSans(),
                                      ),
                                      subtitle: Text(
                                        formatSentTime(messageModel.sentAt),
                                        style: GoogleFonts.openSans(color: color),
                                      ),
                                      trailing: Text(
                                        formatSentTime(messageModel.sentAt),
                                        style: GoogleFonts.openSans(color: color),
                                      ),
                                    ),
                                  );
                                }).toList(),
                          );
                        },
                      )
                      : SizedBox.shrink(),
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
