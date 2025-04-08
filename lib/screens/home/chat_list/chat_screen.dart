import 'package:chataloka/constants/message_constants.dart';
import 'package:chataloka/models/message_model.dart';
import 'package:chataloka/providers/message_provider.dart';
import 'package:chataloka/providers/user_provider.dart';
import 'package:chataloka/utilities/global_methods.dart';
import 'package:chataloka/widgets/bottom_chat_field.dart';
import 'package:chataloka/widgets/chat_app_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:grouped_list/grouped_list.dart';

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
        setState(() {
          args = chatArguments;
          uid = userUID;
        });
        if (userUID == null || args == null) {
          Navigator.of(context).pop();
          throw Exception('User or contact is not found');
        }
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
                                'Start a conversation.',
                                style: GoogleFonts.openSans(),
                              ),
                            );
                          }
                          List<MessageModel> messagesList =
                              snapshot.data!.docs.map((DocumentSnapshot doc) {
                                return MessageModel.fromMap(
                                  doc.data() as Map<String, dynamic>,
                                );
                              }).toList();

                          return GroupedListView<dynamic, DateTime>(
                            elements: messagesList,
                            groupBy: (dynamic element) {
                              return DateTime(
                                (element as MessageModel).sentAt.year,
                                element.sentAt.month,
                                element.sentAt.day,
                              );
                            },
                            groupHeaderBuilder:
                                (dynamic groupedByValue) => Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 5,
                                      horizontal: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: Colors.grey[500],
                                    ),
                                    child: Text(
                                      formatChatHeaderDate(
                                        groupedByValue.sentAt,
                                      ),
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.openSans(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                            itemBuilder: (context, dynamic element) {
                              final bool isMe = element.senderUID == uid;
                              final Color color =
                                  isMe
                                      ? Theme.of(context).primaryColor
                                      : Theme.of(context).cardColor;
                              final Color textColor =
                                  isMe ? Colors.white : Colors.black;
                              bool isShort =
                                  (element.message as String).length < 30;

                              return Column(
                                crossAxisAlignment:
                                    isMe
                                        ? CrossAxisAlignment.end
                                        : CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    constraints: BoxConstraints(
                                      maxWidth:
                                          MediaQuery.of(context).size.width *
                                          0.8,
                                    ),
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 5,
                                      horizontal: 10,
                                    ),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: color,
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withAlpha(
                                            (0.2 * 255).round(),
                                          ),
                                          blurRadius: 4,
                                          spreadRadius: 0,
                                          offset: Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child:
                                        isShort
                                            ? Row(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Text(
                                                  (element.message as String),
                                                  style: GoogleFonts.openSans(
                                                    color: textColor,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  DateFormat.Hm().format(
                                                    element.sentAt,
                                                  ),
                                                  style: GoogleFonts.openSans(
                                                    color: textColor,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            )
                                            : Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Text(
                                                  (element.message as String),
                                                  style: GoogleFonts.openSans(
                                                    color: textColor,
                                                  ),
                                                ),
                                                const SizedBox(height: 5),
                                                Text(
                                                  DateFormat.Hm().format(
                                                    element.sentAt,
                                                  ),
                                                  style: GoogleFonts.openSans(
                                                    color: textColor,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                  ),
                                ],
                              );
                            },
                            useStickyGroupSeparators: true,
                            floatingHeader: true,
                            order: GroupedListOrder.ASC,
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
