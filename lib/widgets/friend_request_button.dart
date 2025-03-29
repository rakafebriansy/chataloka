import 'package:chataloka/models/user.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FriendRequestButton extends StatelessWidget {
  const FriendRequestButton({
    super.key,
    required this.currentUser,
    required this.userModel,
  });

  final UserModel currentUser;
  final UserModel userModel;

  @override
  Widget build(BuildContext context) {
    if (currentUser.uid == userModel.uid &&
        userModel.friendRequestsUIDs.isNotEmpty) {
      return ElevatedButton(
        onPressed: () {},
        child: Text(
          'View Friend Requests'.toUpperCase(),
          style: GoogleFonts.openSans(fontWeight: FontWeight.bold),
        ),
      );
    }
    return SizedBox.shrink();
  }
}
