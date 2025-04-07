import 'package:chataloka/models/user_model.dart';
import 'package:chataloka/providers/user_provider.dart';
import 'package:chataloka/utilities/global_methods.dart';
import 'package:chataloka/widgets/user_image_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ChatAppBar extends StatefulWidget {
  const ChatAppBar({super.key, required this.contactUID});

  final String contactUID;

  @override
  State<ChatAppBar> createState() => _ChatAppBarState();
}

class _ChatAppBarState extends State<ChatAppBar> {
  late final Stream<DocumentSnapshot>? _userStream;
  late final UserProvider userProvider;

  @override
  void initState() {
    super.initState();
    try {
      userProvider = context.read<UserProvider>();
      _userStream = userProvider.getUserStream(userId: widget.contactUID);
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

        final UserModel userModel = UserModel.fromMap(
          snapshot.data?.data() as Map<String, dynamic>,
        );

        final UserModel? currentUser = userProvider.userModel;

        if (currentUser == null) {
          return const Center(child: SizedBox.shrink());
        }

        return Row(
          children: [
            UserImageButton(side: 44, onTap: () {}, imageUrl: userModel.image),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(userModel.name, style: GoogleFonts.openSans(fontSize: 18, fontWeight: FontWeight.w600)),
                Text('Online', style: GoogleFonts.openSans(fontSize: 12)),
              ],
            ),
          ],
        );
      },
    );
  }
}
