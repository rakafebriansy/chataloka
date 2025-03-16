import 'package:chataloka/models/user.dart' as userModel;
import 'package:chataloka/utilities/global_methods.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class AuthenticationProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool _isSuccess = false;
  String? _uid;
  String? _phoneNumber;

  userModel.User? _user;

  bool get isLoading => _isLoading;
  bool get isSuccess => _isSuccess;
  String? get uid => _uid;
  String? get phoneNumber => _phoneNumber;
  userModel.User? get user => _user;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<void> signInWithPhoneNumber({
    required String phoneNumber,
    required BuildContext context,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          UserCredential userCredential = await _auth.signInWithCredential(
            credential,
          );
          _uid = userCredential.user?.uid;
          _phoneNumber = userCredential.user?.phoneNumber;
          _isSuccess = true;
          _isLoading = false;
          notifyListeners();
        },
        verificationFailed: (FirebaseAuthException error) {
          _isSuccess = false;
          _isLoading = false;
          notifyListeners();
          throw error;
        },
        codeSent: (String verificationId, int? resendToken) async {
          _isLoading = false;
          notifyListeners();
          // navigate
          print('navigate');
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (error) {
      print((error as FirebaseAuthException).message);
      showSnackBar(context: context, message: "Something went wrong.");
    }
  }
}
