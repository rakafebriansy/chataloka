import 'package:chataloka/models/user.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SendFriendsRequestButton extends StatelessWidget {
  const SendFriendsRequestButton({
    super.key,
    required this.currentUser,
    required this.userModel,
  });

  final UserModel currentUser;
  final UserModel userModel;

  @override
  Widget build(BuildContext context) {
    if (currentUser.uid != userModel.uid) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: (){},
          child: Text(
            'Send Friend Request'.toUpperCase(),
            style: GoogleFonts.openSans(fontWeight: FontWeight.bold),
          ),
        ),
      );
    }
    return SizedBox.shrink();
  }
}
