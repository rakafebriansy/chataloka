import 'package:chataloka/builders/build_rounded_image.dart';
import 'package:chataloka/constants/message_constants.dart';
import 'package:chataloka/constants/route_constants.dart';
import 'package:chataloka/models/user_model.dart';
import 'package:chataloka/providers/user_provider.dart';
import 'package:chataloka/theme/custom_theme.dart';
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
  late final UserProvider userProvider;

  @override
  void initState() {
    super.initState();

    try {
      userProvider = context.read<UserProvider>();
      if (userProvider.isFriendsStreamClosed()) {
        userProvider.createFriendsStream();
      }
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
  void dispose() {
    userProvider.disposeFriendsStream();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customTheme = Theme.of(context).extension<CustomTheme>()!;

    return Scaffold(
      body: SafeArea(
        child: Column(
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
                  _friendsStream != null
                      ? StreamBuilder<QuerySnapshot>(
                        stream: _friendsStream,
                        builder: (
                          BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot,
                        ) {
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
                                    trailing: FittedBox(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          IconButton(
                                            iconSize: 18,
                                            icon: Icon(
                                              Icons.chat_bubble_outline,
                                            ),
                                            onPressed: () async {
                                              try {
                                                Navigator.pushNamed(
                                                  context,
                                                  RouteConstant.chatScreen,
                                                  arguments: ChatScreenArguments(contactUID: userModel.uid, contactName: userModel.name, contactImage: userModel.image),
                                                );
                                              } catch (error) {
                                                showErrorSnackbar(
                                                  context,
                                                  error,
                                                );
                                              }
                                            },
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.favorite),
                                            color: Colors.red,
                                            iconSize: 18,
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed(RouteConstant.addFriendScreen);
        },
        child: Icon(
          Icons.person_add,
          color: customTheme.button.light,
        ),
      ),
    );
  }
}
