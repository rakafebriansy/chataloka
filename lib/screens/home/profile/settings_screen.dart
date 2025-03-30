import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:chataloka/constants/route.dart';
import 'package:chataloka/providers/user_provider.dart';
import 'package:chataloka/widgets/app_bar_back_button.dart';
import 'package:flutter/material.dart';
import 'package:chataloka/utilities/global_methods.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isDarkMode = false;

  // Method: get the saved theme mode
  void getThemeMode() async {
    final savedThemeMode = await AdaptiveTheme.getThemeMode();
    if (savedThemeMode == AdaptiveThemeMode.dark) {
      setState(() {
        isDarkMode = true;
      });
    } else {
      setState(() {
        isDarkMode = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getThemeMode();
  }

  @override
  Widget build(BuildContext context) {
    final String? uid = ModalRoute.of(context)?.settings.arguments as String?;
    final userProvider = context.read<UserProvider>();

    return Scaffold(
      appBar: AppBar(
        leading: AppBarBackButton(
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        title: const Text('Settings'),
        actions: [
          userProvider.userModel?.uid == uid
              ? IconButton(
                onPressed: () async {
                  showChatalokaDialog(
                    context: context,
                    content: Text(
                      'Are you sure want to logout?',
                      style: GoogleFonts.openSans(),
                    ),
                    confirmLabel: 'Log Out',
                    cancelLabel: 'Cancel',
                    confirmColor: Colors.red,
                    onConfirm: () async {
                      try {
                        await userProvider.logout();
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          RouteConstant.loginScreen,
                          (route) => false,
                        );
                      } catch (error) {
                        showErrorSnackbar(context, error);
                      }
                    },
                    onCancel: () {
                      Navigator.pop(context);
                    },
                  );
                },
                icon: const Icon(Icons.logout),
              )
              : SizedBox.shrink(),
        ],
      ),
      body: Center(
        child: Card(
          child: SwitchListTile(
            title: const Text('Change Theme'),
            secondary: Container(
              height: 30,
              width: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
              child: Icon(
                isDarkMode ? Icons.nightlight_round : Icons.wb_sunny_rounded,
                color: isDarkMode ? Colors.black : Colors.white,
              ),
            ),
            value: isDarkMode,
            onChanged: (value) {
              setState(() {
                isDarkMode = value;
              });

              if (value) {
                AdaptiveTheme.of(context).setDark();
              } else {
                AdaptiveTheme.of(context).setLight();
              }
            },
          ),
        ),
      ),
    );
  }
}
