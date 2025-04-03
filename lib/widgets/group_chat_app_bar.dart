import 'package:chataloka/models/user.dart';
import 'package:chataloka/providers/user_provider.dart';
import 'package:chataloka/utilities/global_methods.dart';
import 'package:chataloka/widgets/user_image_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class GroupChatAppBar extends StatefulWidget {
  const GroupChatAppBar({super.key, required this.friendGroupUID});

  final String friendGroupUID;

  @override
  State<GroupChatAppBar> createState() => _GroupChatAppBarState();
}

class _GroupChatAppBarState extends State<GroupChatAppBar> {
  late final Stream<DocumentSnapshot>? _userStream;
  late final UserProvider userProvider;

  @override
  void initState() {
    super.initState();
    try {
      userProvider = context.read<UserProvider>();
      _userStream = userProvider.getUserStream(userId: widget.friendGroupUID);
    } catch (error) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showErrorSnackbar(context, error);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: _userStream,
      builder: (
        BuildContext context,
        AsyncSnapshot<DocumentSnapshot> snapshot,
      ) {
        if (snapshot.hasError) {
          return const Center(child: Text('Something went wrong'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: SizedBox.shrink());
        }

        final UserModel groupModel = UserModel.fromMap(
          snapshot.data?.data() as Map<String, dynamic>,
        );

        final UserModel? currentUser = userProvider.userModel;

        if (currentUser == null) {
          return const Center(child: SizedBox.shrink());
        }

        return Row(
          children: [
            UserImageButton(side: 44, onTap: () {}, imageUrl: groupModel.image),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  groupModel.name,
                  style: GoogleFonts.openSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text('Online', style: GoogleFonts.openSans(fontSize: 12)),
              ],
            ),
          ],
        );
      },
    );
  }
}
