import 'package:chataloka/builders/build_elevate_button.dart';
import 'package:chataloka/constants/route.dart';
import 'package:chataloka/models/user.dart';
import 'package:chataloka/providers/authentication_provider.dart';
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
  late final String? uid;
  late final Stream<DocumentSnapshot>? userStream;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthenticationProvider>();
      setState(() {
        uid = ModalRoute.of(context)?.settings.arguments as String?;
      });
      if (uid != null) {
        userStream = authProvider.getUserStream(userId: uid!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthenticationProvider>();

    if (uid == null) {
      Navigator.of(context).pop();
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
          authProvider.userModel?.uid == uid
              ? IconButton(
                onPressed: () async {
                  showDialog(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          title: const Text('Log Out'),
                          content: const Text('Are you sure want to logput?'),
                          actions: [
                            TextButton(
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.red,
                                textStyle: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              onPressed: () async {
                                try {
                                  await authProvider.logout();
                                  Navigator.pushNamedAndRemoveUntil(
                                    context,
                                    RouteConstant.loginScreen,
                                    (route) => false,
                                  );
                                } catch (error) {
                                  showErrorSnackbar(
                                    context,
                                    error as Exception,
                                  );
                                }
                              },
                              child: const Text('Log Out'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('Cancel'),
                            ),
                          ],
                        ),
                  );
                },
                icon: const Icon(Icons.logout),
              )
              : SizedBox.shrink(),
        ],
      ),
      body:
          uid != null
              ? StreamBuilder<DocumentSnapshot>(
                stream: userStream,
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

                  final currentUser = authProvider.userModel;

                  final List<Widget> buttons = [
                    if (currentUser != null)
                      if (currentUser.uid == userModel.uid &&
                          userModel.friendRequestsUIDs.isNotEmpty)
                        buildElevatedButton(
                          onPressed: () {},
                          label: 'View Friend Requests',
                        )
                      else if (currentUser.uid == userModel.uid &&
                          userModel.friendsUIDs.isNotEmpty)
                        buildElevatedButton(
                          onPressed: () {},
                          label: 'View Friends',
                        )
                      else if (currentUser.uid != userModel.uid)
                        buildElevatedButton(
                          onPressed: () {},
                          label: 'Send Friend Request',
                        ),
                  ];

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 30,
                    ),
                    child: Column(
                      children: [
                        Center(
                          child: UserImageButton(
                            radius: 60,
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
                            if(buttons.isNotEmpty) SizedBox(height: 10),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.7,
                              child: Column(children: buttons),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  height: 40,
                                  width: 40,
                                  child: Divider(
                                    color: Colors.grey,
                                    thickness: 1,
                                  ),
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
                                  child: Divider(
                                    color: Colors.grey,
                                    thickness: 1,
                                  ),
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
              )
              : SizedBox(),
    );
  }
}
