import 'package:chataloka/builders/build_rounded_image.dart';
import 'package:chataloka/builders/build_text_button_icon.dart';
import 'package:chataloka/models/user_model.dart';
import 'package:chataloka/providers/user_provider.dart';
import 'package:chataloka/utilities/global_methods.dart';
import 'package:chataloka/widgets/app_bar_back_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class AddFriendScreen extends StatefulWidget {
  const AddFriendScreen({super.key});

  @override
  State<AddFriendScreen> createState() => _AddFriendScreenState();
}

class _AddFriendScreenState extends State<AddFriendScreen> {
  late final Stream<QuerySnapshot>? _userStream;
  late final UserProvider userProvider;

  @override
  void initState() {
    super.initState();

    try {
      userProvider = context.read<UserProvider>();
      if (userProvider.isStrangersStreamClosed()) {
        userProvider.createStrangersStream();
      }
      _userStream = userProvider.getAllStrangersStream(
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
    userProvider.disposeStrangersStream();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: AppBarBackButton(
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        title: const Text('Add Friend'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: CupertinoSearchTextField(placeholder: 'Search'),
            ),
            Expanded(
              child:
                  _userStream != null
                      ? StreamBuilder<QuerySnapshot>(
                        stream: _userStream,
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
                                'No users found.',
                                style: GoogleFonts.openSans(),
                              ),
                            );
                          }
                          final UserModel? currentUser = userProvider.userModel;

                          if (currentUser == null) {
                            return const Center(
                              child: CircularProgressIndicator(),
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
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    subtitle: Text(
                                      userModel.aboutMe,
                                      style: GoogleFonts.openSans(),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    trailing:
                                        userModel.friendRequestsUIDs.contains(
                                              currentUser.uid,
                                            )
                                            ? buildTextButtonIcon(
                                              context: context,
                                              fontSize: 12,
                                              size: 12,
                                              onPressed: () async {
                                                try {
                                                  await userProvider
                                                      .cancelFriendRequest(
                                                        friendId: userModel.uid,
                                                      );
                                                  showSnackBar(
                                                    context: context,
                                                    message:
                                                        'Friend request has been canceled.',
                                                  );
                                                } catch (error) {
                                                  showErrorSnackbar(
                                                    context,
                                                    error,
                                                  );
                                                }
                                              },
                                              icon: Icons.close,
                                              label: 'Cancel',
                                              color: Colors.red,
                                            )
                                            : userModel.sentFriendRequestUIDs
                                                .contains(currentUser.uid)
                                            ? buildTextButtonIcon(
                                              context: context,
                                              onPressed: () async {
                                                try {
                                                  await userProvider
                                                      .acceptFriendRequest(
                                                        friendId: userModel.uid,
                                                      );
                                                  showChatalokaDialog(
                                                    context: context,
                                                    content: Text(
                                                      'You are now friend with ${userModel.name}.',
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
                                                } catch (error) {
                                                  showErrorSnackbar(
                                                    context,
                                                    error,
                                                  );
                                                }
                                              },
                                              icon: Icons.check,
                                              label: 'Accept request',
                                            )
                                            : buildTextButtonIcon(
                                              context: context,
                                              fontSize: 12,
                                              size: 12,
                                              onPressed: () async {
                                                try {
                                                  await userProvider
                                                      .sendFriendRequest(
                                                        friendId: userModel.uid,
                                                      );
                                                  showSnackBar(
                                                    context: context,
                                                    message:
                                                        'Request sent successfully',
                                                  );
                                                } catch (error) {
                                                  showErrorSnackbar(
                                                    context,
                                                    error,
                                                  );
                                                }
                                              },
                                              icon: Icons.add,
                                              label: 'Add friend',
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
