import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:chataloka/constants/route.dart';
import 'package:chataloka/providers/authentication_provider.dart';
import 'package:chataloka/screens/landing_screen.dart';
import 'package:chataloka/screens/login_screen.dart';
import 'package:chataloka/screens/otp_screen.dart';
import 'package:chataloka/screens/user_information_screen.dart';
import 'package:chataloka/screens/home/home_screen.dart';
import 'package:chataloka/screens/home/profile/profile_screen.dart';
import 'package:chataloka/screens/home/profile/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final savedThemeMode = await AdaptiveTheme.getThemeMode();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthenticationProvider()),
      ],
      child: MyApp(savedThemeMode: savedThemeMode),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.savedThemeMode});

  final AdaptiveThemeMode? savedThemeMode;

  @override
  Widget build(BuildContext context) {
    return AdaptiveTheme(
      light: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: Colors.deepPurple,
      ),
      dark: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.deepPurple,
      ),
      initial: savedThemeMode ?? AdaptiveThemeMode.light,
      builder:
          (theme, darkTheme) => MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Chataloka',
            theme: theme,
            darkTheme: darkTheme,
            initialRoute: RouteConstant.landingScreen,
            routes: {
              RouteConstant.landingScreen: (context) => const LandingScreen(),
              RouteConstant.loginScreen: (context) => const LoginScreen(),
              RouteConstant.otpScreen: (context) => const OTPScreen(),
              RouteConstant.userInformationScreen:
                  (context) => const UserInformationScreen(),
              RouteConstant.homeScreen: (context) => const HomeScreen(),
              RouteConstant.profileScreen: (context) => const ProfileScreen(),
              RouteConstant.settingsScreen: (context) => const SettingsScreen(),
            },
          ),
    );
  }
}
