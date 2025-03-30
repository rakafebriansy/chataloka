import 'package:chataloka/constants/route.dart';
import 'package:chataloka/constants/user.dart';
import 'package:chataloka/providers/user_provider.dart';
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

  Future<void> verifyOTPCode({
    required String verificationId,
    required String otpCode,
  }) async {
    final userProvider = context.read<UserProvider>();
    await userProvider.verifyOTPCode(
      verificationId: verificationId,
      otpCode: otpCode,
      context: context,
    );
    final bool userExists = await userProvider.checkUserExists();
    if (userExists) {
      await userProvider.getUserDataFromFirestore();
      await userProvider.saveUserDataToSharedPreferences();
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(RouteConstant.homeScreen, (route) => false);
    } else {
      Navigator.of(context).pushNamed(RouteConstant.userInformationScreen);
    }
  }

  Future<void> submitOTPCode(String pin, String verificationId) async {
    try {
      setState(() {
        otpCode = pin;
      });
      if (otpCode == null) {
        throw Exception('OTP code is invalid');
      }
      await verifyOTPCode(verificationId: verificationId, otpCode: otpCode!);
    } catch (error) {
      showErrorSnackbar(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map args = ModalRoute.of(context)!.settings.arguments as Map;
    final String verificationId = args[UserConstant.verificationId] as String;
    final String phoneNumber = args[UserConstant.phoneNumber] as String;

    final userProvider = context.watch<UserProvider>();

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
                      submitOTPCode(pin, verificationId);
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
                userProvider.isLoading
                    ? const CircularProgressIndicator()
                    : SizedBox.shrink(),
                userProvider.isSuccess
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
                userProvider.isSuccess || userProvider.isLoading
                    ? const SizedBox(height: 10)
                    : SizedBox.shrink(),
                userProvider.isLoading
                    ? SizedBox.shrink()
                    : Text(
                      'Didn\'t receive the code?',
                      style: GoogleFonts.openSans(fontSize: 16),
                    ),
                const SizedBox(height: 10),
                userProvider.isLoading
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
