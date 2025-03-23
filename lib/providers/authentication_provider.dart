import 'dart:convert';

import 'package:chataloka/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:chataloka/constants/route.dart';
import 'package:chataloka/constants/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthenticationProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool _isSuccess = false;
  String? _uid;
  String? _phoneNumber;

  UserModel? _user;

  bool get isLoading => _isLoading;
  bool get isSuccess => _isSuccess;
  String? get uid => _uid;
  String? get phoneNumber => _phoneNumber;
  UserModel? get user => _user;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<bool> checkUserExists() async {
    final DocumentSnapshot documentSnapshot =
        await _firestore.collection(UserConstant.users).doc(_uid).get();
    return documentSnapshot.exists;
  }

  Future<void> getUserDataFromFirestore() async {
    final DocumentSnapshot documentSnapshot =
        await _firestore.collection(UserConstant.users).doc(_uid).get();
    _user = UserModel.fromMap(documentSnapshot.data() as Map<String, dynamic>);
    notifyListeners();
  }

  Future<void> saveUserDataToSharedPreferences() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (user != null) {
      await sharedPreferences.setString(
        UserConstant.userModel,
        jsonEncode(user?.toMap()),
      );
    }
  }

  Future<void> getUserDataFromSharedPreferences() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? userModelString = sharedPreferences.getString(
      UserConstant.userModel,
    );
    if (userModelString != null) {
      _user = UserModel.fromMap(jsonDecode(userModelString));
      _uid = user?.uid;
      notifyListeners();
    }
  }

  Future<void> signInWithPhoneNumber({
    required String phoneNumber,
    required BuildContext context,
  }) async {
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
        Navigator.of(context).pushNamed(
          RouteConstant.otpScreen,
          arguments: {
            UserConstant.verificationId: verificationId,
            UserConstant.phoneNumber: phoneNumber,
          },
        );
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  Future<void> verifyOTPCode({
    required String verificationId,
    required String otpCode,
    required BuildContext context,
    required Function onSuccess,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otpCode,
      );

      final UserCredential result = await _auth.signInWithCredential(
        credential,
      );

      if (result.user == null) {
        throw Exception(
          'AuthenticationProvider/verifyOTPCode: Invalid Credentials.',
        );
      }

      _uid = result.user!.uid;
      _phoneNumber = result.user!.phoneNumber;
      _isSuccess = true;
      _isLoading = false;
      onSuccess();
      notifyListeners();
    } catch (error) {
      _isSuccess = false;
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
}
