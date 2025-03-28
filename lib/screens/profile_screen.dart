import 'package:chataloka/constants/route.dart';
import 'package:chataloka/models/user.dart';
import 'package:chataloka/providers/authentication_provider.dart';
import 'package:chataloka/utilities/global_methods.dart';
import 'package:chataloka/widgets/app_bar_back_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthenticationProvider>();

    final String? uid = ModalRoute.of(context)?.settings.arguments as String?;

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
                          title: const Text('Logout'),
                          content: const Text('Are you sure want to logout?'),
                          actions: [
                            TextButton(
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
                              child: const Text('Logout'),
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
      body: StreamBuilder<DocumentSnapshot>(
        stream: authProvider.getUserStream(userId: uid!),
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

          return ListTile(
            leading: CircleAvatar(
              radius: 30,
              backgroundImage: NetworkImage(userModel.image),
            ),
            title: Text(userModel.name),
            subtitle: Text(userModel.aboutMe),
          );
        },
      ),
    );
  }
}
