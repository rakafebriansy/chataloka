import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:chataloka/constants/route_constants.dart';
import 'package:chataloka/providers/message_provider.dart';
import 'package:chataloka/providers/user_provider.dart';
import 'package:chataloka/screens/home/chat_list/chat_screen.dart';
import 'package:chataloka/screens/home/friends/friend_requests_screen.dart';
import 'package:chataloka/screens/home/friends/add_friend_screen.dart';
import 'package:chataloka/screens/landing_screen.dart';
import 'package:chataloka/screens/login_screen.dart';
import 'package:chataloka/screens/otp_screen.dart';
import 'package:chataloka/screens/user_information_screen.dart';
import 'package:chataloka/screens/home_screen.dart';
import 'package:chataloka/screens/home/profile_screen.dart';
import 'package:chataloka/screens/home/profile/settings_screen.dart';
import 'package:chataloka/theme/custom_theme_data.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get_time_ago/get_time_ago.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:chataloka/libs/get_time_ago/custom_messages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final savedThemeMode = await AdaptiveTheme.getThemeMode();
  GetTimeAgo.setCustomLocaleMessages('en', CustomMessages()); 
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => MessageProvider()),
      ],
      child: AdaptiveTheme(
        light: CustomThemeData.lightTheme,
        dark: CustomThemeData.darkTheme,
        initial: savedThemeMode ?? AdaptiveThemeMode.light,
        builder:
            (theme, darkTheme) => MyApp(theme: theme, darkTheme: darkTheme),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  final ThemeData theme;
  final ThemeData darkTheme;

  const MyApp({super.key, required this.theme, required this.darkTheme});

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chataloka',
      theme: theme,
      darkTheme: darkTheme,
      initialRoute: RouteConstant.landingScreen,
      routes: {
        RouteConstant.addFriendScreen: (context) => const AddFriendScreen(),
        RouteConstant.chatScreen: (context) => const ChatScreen(),
        RouteConstant.friendRequestsScreen:
            (context) => const FriendRequestsScreen(),
        RouteConstant.homeScreen: (context) => const HomeScreen(),
        RouteConstant.landingScreen: (context) => const LandingScreen(),
        RouteConstant.loginScreen: (context) => const LoginScreen(),
        RouteConstant.profileScreen: (context) => const ProfileScreen(),
        RouteConstant.otpScreen: (context) => const OTPScreen(),
        RouteConstant.settingsScreen: (context) => const SettingsScreen(),
        RouteConstant.userInformationScreen:
            (context) => const UserInformationScreen(),
      },
    );
  }
}
