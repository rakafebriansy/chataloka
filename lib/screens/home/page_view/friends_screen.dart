import 'package:chataloka/builders/build_rounded_image.dart';
import 'package:chataloka/builders/build_text_button_icon.dart';
import 'package:chataloka/constants/route.dart';
import 'package:chataloka/models/user.dart';
import 'package:chataloka/providers/user_provider.dart';
import 'package:chataloka/utilities/global_methods.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  late final Stream<QuerySnapshot>? _friendsStream;

  @override
  void initState() {
    super.initState();

    try {
      final userProvider = context.read<UserProvider>();
      _friendsStream = userProvider.getAllFriendsStream(
        userId: userProvider.userModel!.uid,
      );
    } catch (error) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showErrorSnackbar(context, error);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.read<UserProvider>();
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      buildTextButtonIcon(
                        context: context,
                        label: 'Friend Requests',
                        onPressed: () {
                          Navigator.of(
                            context,
                          ).pushNamed(RouteConstant.friendRequestsScreen);
                        },
                        icon: Icons.notification_add,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: CupertinoSearchTextField(placeholder: 'Search'),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.of(
                            context,
                          ).pushNamed(RouteConstant.addFriendScreen);
                        },
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(10, 10, 0, 10),
                          child: Icon(
                            Icons.person_add,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child:
                  _friendsStream != null
                      ? StreamBuilder<QuerySnapshot>(
                        stream: _friendsStream,
                        builder: (
                          BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot,
                        ) {
                          if (snapshot.hasError) {
                            print(snapshot.error.toString());
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
                                'No friends yet.',
                                style: GoogleFonts.openSans(),
                              ),
                            );
                          }

                          return ListView(
                            children:
                                snapshot.data!.docs.map((
                                  DocumentSnapshot document,
                                ) {
                                  UserModel userModel = UserModel.fromMap(
                                    document.data() as Map<String, dynamic>,
                                  );
                                  return ListTile(
                                    leading: buildRoundedImage(
                                      imageUrl: userModel.image,
                                      side: 50,
                                    ),
                                    title: Text(
                                      userModel.name,
                                      style: GoogleFonts.openSans(),
                                    ),
                                    subtitle: Text(
                                      userModel.aboutMe,
                                      style: GoogleFonts.openSans(),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    onTap: () {
                                      Navigator.of(context).pushNamed(
                                        RouteConstant.profileScreen,
                                        arguments: userModel.uid,
                                      );
                                    },
                                    trailing: SizedBox(
                                      width: screenWidth * 0.4,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          IconButton(
                                            iconSize: 16,
                                            icon: Icon(
                                              Icons.chat_bubble_outline,
                                            ),
                                            onPressed: () async {
                                              try {
                                                //
                                              } catch (error) {
                                                showErrorSnackbar(
                                                  context,
                                                  error,
                                                );
                                              }
                                            },
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.delete),
                                            color: Colors.red,
                                            iconSize: 16,
                                            onPressed: () async {
                                              try {
                                                showChatalokaDialog(
                                                  context: context,
                                                  content: Text(
                                                    'Are you sure want to remove ${userModel.name} from friend?',
                                                  ),
                                                  confirmColor: Colors.red,
                                                  confirmLabel: 'Remove',
                                                  cancelLabel: 'Cancel',
                                                  onConfirm: () async {
                                                    await userProvider
                                                        .removeFriend(
                                                          friendId:
                                                              userModel.uid,
                                                        );
                                                    Navigator.of(context).pop();
                                                    showChatalokaDialog(
                                                      context: context,
                                                      content: Text(
                                                        'You are no longer friend with ${userModel.name}.',
                                                        style:
                                                            GoogleFonts.openSans(),
                                                      ),
                                                      cancelLabel: 'Close',
                                                      onCancel: () {
                                                        Navigator.of(
                                                          context,
                                                        ).pop();
                                                      },
                                                    );
                                                  },
                                                  onCancel: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                );
                                              } catch (error) {
                                                showErrorSnackbar(
                                                  context,
                                                  error,
                                                );
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                          );
                        },
                      )
                      : SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
