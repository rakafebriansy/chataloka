import 'package:chataloka/models/user.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FriendsButton extends StatelessWidget {
  const FriendsButton({
    super.key,
    required this.currentUser,
    required this.userModel,
  });

  final UserModel currentUser;
  final UserModel userModel;

  @override
  Widget build(BuildContext context) {
    if (currentUser.uid == userModel.uid &&
        userModel.friendsUIDs.isNotEmpty) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: (){},
          child: Text(
            'View Friends'.toUpperCase(),
            style: GoogleFonts.openSans(fontWeight: FontWeight.bold),
          ),
        ),
      );
    }
    return SizedBox.shrink();
  }
}
