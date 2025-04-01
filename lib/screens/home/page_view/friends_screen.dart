import 'package:chataloka/builders/build_rounded_image.dart';
import 'package:chataloka/constants/route.dart';
import 'package:chataloka/constants/user.dart';
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
                      TextButton.icon(
                        label: Text('Friend Requests'),
                        onPressed: () {
                          Navigator.of(
                            context,
                          ).pushNamed(RouteConstant.friendRequestsScreen);
                        },
                        icon: Icon(Icons.notification_add),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: CupertinoSearchTextField(placeholder: 'Search'),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: InkWell(
                          onTap: () {
                            Navigator.of(
                              context,
                            ).pushNamed(RouteConstant.addFriendScreen);
                          },
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
                                  Map<String, dynamic> user =
                                      document.data() as Map<String, dynamic>;
                                  return ListTile(
                                    leading: buildRoundedImage(
                                      imageUrl: user[UserConstant.image],
                                      side: 50,
                                    ),
                                    title: Text(
                                      user[UserConstant.name],
                                      style: GoogleFonts.openSans(),
                                    ),
                                    subtitle: Text(
                                      user[UserConstant.aboutMe],
                                      style: GoogleFonts.openSans(),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    onTap: () {
                                      Navigator.of(context).pushNamed(
                                        RouteConstant.profileScreen,
                                        arguments: user['uid'],
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
      ),
    );
  }
}
