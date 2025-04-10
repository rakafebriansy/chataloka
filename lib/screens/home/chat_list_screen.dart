import 'package:chataloka/builders/build_rounded_image.dart';
import 'package:chataloka/constants/message_constants.dart';
import 'package:chataloka/constants/route_constants.dart';
import 'package:chataloka/models/last_message_model.dart';
import 'package:chataloka/providers/message_provider.dart';
import 'package:chataloka/providers/user_provider.dart';
import 'package:chataloka/theme/custom_theme.dart';
import 'package:chataloka/utilities/global_methods.dart';
import 'package:chataloka/widgets/sent_mark.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  late final String uid;
  late final Stream<QuerySnapshot>? _chatStream;
  late final MessageProvider messageProvider;

  @override
  void initState() {
    super.initState();
    try {
      final userUID = context.read<UserProvider>().userModel?.uid;
      if (userUID == null) {
        throw Exception('User not found. Please re-login');
      }
      uid = userUID;
      messageProvider = context.read<MessageProvider>();
      _chatStream = messageProvider.getChatListStream(userUID: userUID);
    } catch (error) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showErrorSnackbar(context, error);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final CustomTheme theme = Theme.of(context).extension<CustomTheme>()!;

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: CupertinoSearchTextField(
              placeholder: 'Search',
              style: GoogleFonts.openSans(color: Colors.white),
            ),
          ),
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

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
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
                                LastMessageModel lastMessageModel =
                                    LastMessageModel.fromMap(
                                      doc.data() as Map<String, dynamic>,
                                    );
                                final isMe = lastMessageModel.senderUID == uid;

                                return ListTile(
                                  leading: buildRoundedImage(
                                    imageUrl: lastMessageModel.contactImage,
                                    side: 50,
                                  ),
                                  title: Text(
                                    lastMessageModel.contactName,
                                    style: GoogleFonts.openSans(),
                                  ),
                                  subtitle: Text(
                                    isMe
                                        ? 'You: ${lastMessageModel.message}'
                                        : lastMessageModel.message,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.openSans(),
                                  ),
                                  trailing: SentMark(model: lastMessageModel, textColor: isMe ? theme.customContactTextColor : theme.customSenderTextColor),
                                  onTap: () {
                                    Navigator.of(context).pushNamed(
                                      RouteConstant.chatScreen,
                                      arguments: ChatScreenArguments(
                                        contactUID: lastMessageModel.contactUID,
                                        contactName:
                                            lastMessageModel.contactName,
                                        contactImage:
                                            lastMessageModel.contactImage,
                                      ),
                                    );
                                  },
                                );
                              }).toList(),
                        );
                      },
                    )
                    : SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
