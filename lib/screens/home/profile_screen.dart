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
    final currentUser = context.read<UserProvider>().userModel;

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
          currentUser?.uid == uid
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

          final List<Widget> buttons = [
            if (currentUser?.uid == userModel.uid &&
                userModel.friendRequestsUIDs.isNotEmpty)
              buildElevatedButton(
                onPressed: () {},
                label: 'View Friend Requests',
              )
            else if (currentUser?.uid == userModel.uid &&
                userModel.friendsUIDs.isNotEmpty)
              buildElevatedButton(onPressed: () {}, label: 'View Friends')
            else if (currentUser?.uid != userModel.uid)
              buildElevatedButton(
                onPressed: () {},
                label: 'Send Friend Request',
              ),
          ];

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
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
                    if (buttons.isNotEmpty) SizedBox(height: 10),
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
