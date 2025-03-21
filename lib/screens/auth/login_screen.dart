import 'package:chataloka/providers/authentication_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:chataloka/utilities/assets_manager.dart';
import 'package:country_picker/country_picker.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneNumberController = TextEditingController();
  final RoundedLoadingButtonController _btnController =
      RoundedLoadingButtonController();

  Country selectedCountry = Country(
    phoneCode: "62",
    countryCode: "ID",
    e164Sc: 0,
    geographic: true,
    level: 1,
    name: "Indonesia",
    example: "812345678",
    displayName: "Indonesia (+62)",
    displayNameNoCountryCode: "Indonesia",
    e164Key: "",
  );

  @override
  void dispose() {
    _phoneNumberController.dispose();
    // _buttonController.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthenticationProvider>();
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 50),
              SizedBox(
                height: 200,
                width: 200,
                child: Lottie.asset(AssetsManager.chatBubble),
              ),
              Text(
                'Chataloka',
                style: GoogleFonts.openSans(
                  fontSize: 28,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Add your phone number will send youn a code to verify',
                textAlign: TextAlign.center,
                style: GoogleFonts.openSans(fontSize: 16),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _phoneNumberController,
                maxLength: 15,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                onChanged: (value) {
                  setState(() {
                    _phoneNumberController.text = value;
                  });
                },
                decoration: InputDecoration(
                  counterText: '',
                  hintStyle: GoogleFonts.openSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  hintText: 'Phone Number',
                  prefixIcon: Container(
                    padding: const EdgeInsets.fromLTRB(8, 12, 8, 12),
                    child: InkWell(
                      onTap: () {
                        showCountryPicker(
                          context: context,
                          showPhoneCode: true,
                          countryListTheme: CountryListThemeData(
                            bottomSheetHeight: 400,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          onSelect: (Country country) {
                            setState(() {
                              selectedCountry = country;
                            });
                          },
                        );
                      },
                      child: Text(
                        '${selectedCountry.flagEmoji} +${selectedCountry.phoneCode}',
                        style: GoogleFonts.openSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  suffixIcon:
                      _phoneNumberController.text.length > 5
                          ? authProvider.isLoading
                              ? Transform.scale(
                                scale:
                                    0.5,
                                child: CircularProgressIndicator(),
                              )
                              : Container(
                                height: 20,
                                width: 20,
                                margin: const EdgeInsets.all(10),
                                decoration: const BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.done,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              )
                          : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              RoundedLoadingButton(
                controller: _btnController,
                onPressed: () async {
                  await authProvider.signInWithPhoneNumber(
                    phoneNumber:
                        '+${selectedCountry.phoneCode}${_phoneNumberController.text}',
                    context: context,
                  );
                },
                child: Text('Send Code', style: TextStyle(color: Colors.white)),
                borderRadius: 10,
                width: screenWidth - 40,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
