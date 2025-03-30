import 'package:chataloka/builders/build_rounded_image.dart';
import 'package:chataloka/constants/route.dart';
import 'package:chataloka/constants/user.dart';
import 'package:chataloka/providers/authentication_provider.dart';
import 'package:chataloka/utilities/global_methods.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class PeopleScreen extends StatefulWidget {
  const PeopleScreen({super.key});

  @override
  State<PeopleScreen> createState() => _PeopleScreenState();
}

class _PeopleScreenState extends State<PeopleScreen> {
  late final Stream<QuerySnapshot>? _userStream;

  @override
  void initState() {
    super.initState();

    try {
      final authProvider = context.read<AuthenticationProvider>();
      _userStream = authProvider.getAllUsersStream(
        userId: authProvider.userModel!.uid,
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

                          return ListView(
                            children:
                                snapshot.data!.docs.map((
                                  DocumentSnapshot document,
                                ) {
                                  Map<String, dynamic> user =
                                      document.data() as Map<String, dynamic>;
                                  return ListTile(
                                    leading: buildRoundedImage(imageUrl: user[UserConstant.image], side: 50),
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
