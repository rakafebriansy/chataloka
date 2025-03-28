import 'package:chataloka/constants/route.dart';
import 'package:chataloka/providers/authentication_provider.dart';
import 'package:chataloka/utilities/assets_manager.dart';
import 'package:chataloka/utilities/global_methods.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  Future<void> checkAuthentication() async {
    try {
      final authProvider = context.read<AuthenticationProvider>();
      bool isAuthenticated = await authProvider.checkAuthenticationState();

      Navigator.of(context).pushReplacementNamed(
        !isAuthenticated ? RouteConstant.loginScreen : RouteConstant.homeScreen,
      );
    } catch (error) {
      showErrorSnackbar(context, error as Exception);
    }
  }

  @override
  void initState() {
    checkAuthentication();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          height: 400,
          width: 200,
          child: Column(
            children: [
              Lottie.asset(AssetsManager.chatBubble),
              LinearProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
