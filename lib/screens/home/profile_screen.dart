import 'package:chataloka/builders/build_elevated_button.dart';
import 'package:chataloka/constants/route.dart';
import 'package:chataloka/models/user.dart';
import 'package:chataloka/providers/user_provider.dart';
import 'package:chataloka/utilities/global_methods.dart';
import 'package:chataloka/widgets/app_bar_back_button.dart';
import 'package:chataloka/widgets/user_image_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? uid;
  late final Stream<DocumentSnapshot>? _userStream;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = context.read<UserProvider>();
      final args = ModalRoute.of(context)?.settings.arguments;

      if (args is String) {
        setState(() {
          uid = args;
          _userStream = userProvider.getUserStream(userId: args);
        });
      } else {
        showErrorSnackbar(context, Exception("Invalid arguments"));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.read<UserProvider>();
    final screenWidth = MediaQuery.of(context).size.width;

    if (uid == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        leading: AppBarBackButton(
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        title: const Text('Profile'),
        actions: [
          userProvider.userModel?.uid == uid
              ? IconButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    RouteConstant.settingsScreen,
                    arguments: uid,
                  );
                },
                icon: const Icon(Icons.settings),
              )
              : SizedBox.shrink(),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _userStream,
        builder: (
          BuildContext context,
          AsyncSnapshot<DocumentSnapshot> snapshot,
        ) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final UserModel userModel = UserModel.fromMap(
            snapshot.data?.data() as Map<String, dynamic>,
          );

          final UserModel? currentUser = userProvider.userModel;

          if (currentUser == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            child: Column(
              children: [
                Center(
                  child: UserImageButton(
                    side: 120,
                    onTap: () {},
                    imageUrl: userModel.image,
                  ),
                ),
                Column(
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      userModel.name,
                      style: GoogleFonts.openSans(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 30),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (currentUser.uid == userModel.uid)
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (userModel.friendRequestsUIDs.isNotEmpty)
                                buildElevatedButton(
                                  context: context,
                                  width: screenWidth * 0.7,
                                  fontSize: 12,
                                  onPressed: () {},
                                  label: 'View Friend Requests',
                                ),
                              SizedBox(width: 20),
                              if (userModel.friendsUIDs.isNotEmpty)
                                buildElevatedButton(
                                  fontSize: 12,
                                  context: context,
                                  width: screenWidth * 0.7,
                                  onPressed: () {},
                                  label: 'View Friends',
                                ),
                            ],
                          ),
                        if (currentUser.uid != userModel.uid)
                          userModel.friendsUIDs.contains(currentUser.uid)
                              ? SizedBox(
                                width: screenWidth * 0.8,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    buildElevatedButton(
                                      context: context,
                                      width: screenWidth * 0.38,
                                      fontSize: 12,
                                      backgroundColor: Colors.red,
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
                                              await userProvider.removeFriend(
                                                friendId: userModel.uid,
                                              );
                                              Navigator.of(context).pop();
                                              showChatalokaDialog(
                                                context: context,
                                                content: Text(
                                                  'You are no longer friend with ${userModel.name}.',
                                                  style: GoogleFonts.openSans(),
                                                ),
                                                cancelLabel: 'Close',
                                                onCancel: () {
                                                  Navigator.of(context).pop();
                                                },
                                              );
                                            },
                                            onCancel: () {
                                              Navigator.of(context).pop();
                                            },
                                          );
                                        } catch (error) {
                                          showErrorSnackbar(context, error);
                                        }
                                      },
                                      label: 'Unfriend',
                                    ),
                                    buildElevatedButton(
                                      context: context,
                                      fontSize: 12,
                                      width: screenWidth * 0.38,
                                      onPressed: () async {
                                        try {
                                          // await userProvider.removeFriend(
                                          //   friendId: userModel.uid,
                                          // );
                                          showChatalokaDialog(
                                            context: context,
                                            content: Text(
                                              'You are no longer friend with ${userModel.name}.',
                                              style: GoogleFonts.openSans(),
                                            ),
                                            cancelLabel: 'Close',
                                            onCancel: () {
                                              Navigator.of(context).pop();
                                            },
                                          );
                                        } catch (error) {
                                          showErrorSnackbar(context, error);
                                        }
                                      },
                                      label: 'Chat',
                                    ),
                                  ],
                                ),
                              )
                              : userModel.friendRequestsUIDs.contains(
                                currentUser.uid,
                              )
                              ? buildElevatedButton(
                                context: context,
                                width: screenWidth * 0.7,
                                backgroundColor: Colors.red,
                                onPressed: () async {
                                  try {
                                    await userProvider.cancelFriendRequest(
                                      friendId: userModel.uid,
                                    );
                                    showChatalokaDialog(
                                      context: context,
                                      content: Text(
                                        'Friend request has been canceled.',
                                        style: GoogleFonts.openSans(),
                                      ),
                                      cancelLabel: 'Close',
                                      onCancel: () {
                                        Navigator.of(context).pop();
                                      },
                                    );
                                  } catch (error) {
                                    showErrorSnackbar(context, error);
                                  }
                                },
                                label: 'Cancel Friend Request',
                              )
                              : userModel.sentFriendRequestUIDs.contains(
                                currentUser.uid,
                              )
                              ? buildElevatedButton(
                                context: context,
                                width: screenWidth * 0.7,
                                onPressed: () async {
                                  try {
                                    await userProvider.acceptFriendRequest(
                                      friendId: userModel.uid,
                                    );
                                    showChatalokaDialog(
                                      context: context,
                                      content: Text(
                                        'You are now friend with ${userModel.name}.',
                                        style: GoogleFonts.openSans(),
                                      ),
                                      cancelLabel: 'Close',
                                      onCancel: () {
                                        Navigator.of(context).pop();
                                      },
                                    );
                                  } catch (error) {
                                    showErrorSnackbar(context, error);
                                  }
                                },
                                label: 'Accept Friend Request',
                              )
                              : buildElevatedButton(
                                context: context,
                                width: screenWidth * 0.7,
                                onPressed: () async {
                                  try {
                                    await userProvider.sendFriendRequest(
                                      friendId: userModel.uid,
                                    );
                                    showChatalokaDialog(
                                      context: context,
                                      content: Text(
                                        'Request sent successfully.',
                                        style: GoogleFonts.openSans(),
                                      ),
                                      cancelLabel: 'Close',
                                      onCancel: () {
                                        Navigator.of(context).pop();
                                      },
                                    );
                                  } catch (error) {
                                    showErrorSnackbar(context, error);
                                  }
                                },
                                label: 'Send Friend Request',
                              ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          height: 40,
                          width: 40,
                          child: Divider(color: Colors.grey, thickness: 1),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'About Me',
                          style: GoogleFonts.openSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const SizedBox(
                          height: 40,
                          width: 40,
                          child: Divider(color: Colors.grey, thickness: 1),
                        ),
                      ],
                    ),
                    Text(
                      userModel.aboutMe,
                      style: GoogleFonts.openSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
