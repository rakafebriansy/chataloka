import 'package:chataloka/constants/route.dart';
import 'package:chataloka/constants/user.dart';
import 'package:chataloka/providers/authentication_provider.dart';
import 'package:chataloka/utilities/global_methods.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';

class OTPScreen extends StatefulWidget {
  const OTPScreen({super.key});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final controller = TextEditingController();
  final focusNode = FocusNode();
  String? otpCode;

  @override
  void dispose() {
    controller.dispose();
    focusNode.dispose();
    super.dispose();
  }

  void verifyOTPCode({
    required String verificationId,
    required String otpCode,
  }) async {
    try {
      final authProvider = context.read<AuthenticationProvider>();
      authProvider.verifyOTPCode(
        verificationId: verificationId,
        otpCode: otpCode,
        context: context,
        onSuccess: () async {
          final bool userExists = await authProvider.checkUserExists();
          if (userExists) {
            await authProvider.getUserDataFromFirestore();
            await authProvider.saveUserDataToSharedPreferences();
            Navigator.of(context).pushNamedAndRemoveUntil(
              RouteConstant.homeScreen,
              (route) => false,
            );
          } else {
            Navigator.of(
              context,
            ).pushNamed(RouteConstant.userInformationScreen);
          }
        },
      );
    } catch (error) {
      showErrorSnackbar(context, error as Exception);
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    final verificationId = args[UserConstant.verificationId] as String;
    final phoneNumber = args[UserConstant.phoneNumber] as String;

    final authProvider = context.watch<AuthenticationProvider>();

    final defaultPinTheme = PinTheme(
      width: 50,
      height: 60,
      textStyle: GoogleFonts.openSans(
        fontSize: 22,
        fontWeight: FontWeight.w600,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey.shade200,
        border: Border.all(color: Colors.transparent),
      ),
    );

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 50),
                Text(
                  'Verification',
                  style: GoogleFonts.openSans(
                    fontSize: 28,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 50),
                Text(
                  'Enter the 6-digit code sent to the number',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.openSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  phoneNumber,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.openSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 50),
                SizedBox(
                  height: 68,
                  child: Pinput(
                    length: 6,
                    controller: controller,
                    focusNode: focusNode,
                    defaultPinTheme: defaultPinTheme,
                    onCompleted: (pin) {
                      try {
                        setState(() {
                          otpCode = pin;
                        });
                        if (otpCode == null) {
                          throw Exception('OTP code is invalid');
                        }
                      } catch (error) {
                        showErrorSnackbar(context, error as Exception);
                      }
                      verifyOTPCode(
                        verificationId: verificationId,
                        otpCode: otpCode!,
                      );
                    },
                    focusedPinTheme: defaultPinTheme.copyWith(
                      height: 68,
                      width: 64,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.grey.shade200,
                        border: Border.all(color: Colors.deepPurple),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                authProvider.isLoading
                    ? const CircularProgressIndicator()
                    : SizedBox.shrink(),
                authProvider.isSuccess
                    ? Container(
                      height: 50,
                      width: 50,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.done,
                        color: Colors.white,
                        size: 30,
                      ),
                    )
                    : const SizedBox.shrink(),
                authProvider.isSuccess || authProvider.isLoading
                    ? const SizedBox(height: 10)
                    : SizedBox.shrink(),
                authProvider.isLoading
                    ? SizedBox.shrink()
                    : Text(
                      'Didn\'t receive the code?',
                      style: GoogleFonts.openSans(fontSize: 16),
                    ),
                const SizedBox(height: 10),
                authProvider.isLoading
                    ? SizedBox.shrink()
                    : TextButton(
                      onPressed: () {},
                      child: Text(
                        'Resend Code',
                        style: GoogleFonts.openSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
