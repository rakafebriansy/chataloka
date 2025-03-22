import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:chataloka/constants/route.dart' as RouteConstant;
import 'package:chataloka/providers/authentication_provider.dart';
import 'package:chataloka/screens/auth/login_screen.dart';
import 'package:chataloka/screens/auth/otp_screen.dart';
import 'package:chataloka/screens/auth/user_information.dart';
import 'package:chataloka/screens/home_screen.dart';
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
            initialRoute: RouteConstant.Route.loginScreen,
            routes: {
              RouteConstant.Route.loginScreen: (context) => const LoginScreen(),
              RouteConstant.Route.otpScreen: (context) => const OTPScreen(),
              RouteConstant.Route.userInformationScreen: (context) => const UserInformationScreen(),
              RouteConstant.Route.homeScreen: (context) => const HomeScreen(),
            },
          ),
    );
  }
}
