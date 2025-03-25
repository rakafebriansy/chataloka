import 'dart:convert';
import 'dart:io';

import 'package:chataloka/models/user.dart';
import 'package:chataloka/utilities/global_methods.dart';
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

  UserModel? _userModel;

  bool get isLoading => _isLoading;
  bool get isSuccess => _isSuccess;
  String? get uid => _uid;
  String? get phoneNumber => _phoneNumber;
  UserModel? get userModel => _userModel;

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
    _userModel = UserModel.fromMap(
      documentSnapshot.data() as Map<String, dynamic>,
    );
    notifyListeners();
  }

  Future<void> saveUserDataToSharedPreferences() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (userModel != null) {
      await sharedPreferences.setString(
        UserConstant.userModel,
        jsonEncode(userModel?.toMap()),
      );
    }
  }

  Future<void> getUserDataFromSharedPreferences() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? userModelString = sharedPreferences.getString(
      UserConstant.userModel,
    );
    if (userModelString != null) {
      _userModel = UserModel.fromMap(jsonDecode(userModelString));
      _uid = userModel?.uid;
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
        throw Exception('Invalid Credentials.');
      }

      _uid = result.user!.uid;
      _phoneNumber = result.user!.phoneNumber;
      _isSuccess = true;
    } catch (error) {
      _isSuccess = false;
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveUserDataToFirestore({
    required UserModel userModel,
    required File? imageFile,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      if (imageFile != null) {
        String fileName = generateFileName(fileName: userModel.uid);
        String imageUrl = await storeFileToFirebaseStorage(
          file: imageFile,
          reference: '${UserConstant.userImages}/${fileName}',
        );
        userModel.image = imageUrl;
      }

      userModel.lastSeen = DateTime.now().microsecondsSinceEpoch.toString();
      userModel.createdAt = DateTime.now().microsecondsSinceEpoch.toString();

      _userModel = userModel;
      _uid = userModel.uid;

      await _firestore
          .collection(UserConstant.users)
          .doc(userModel.uid)
          .set(userModel.toMap());
      _isSuccess = true;
    } on FirebaseAuthException catch (error) {
      _isSuccess = false;
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String> storeFileToFirebaseStorage({
    required File file,
    required String reference,
  }) async {
    UploadTask uploadTask = _storage.ref().child(reference).putFile(file);
    TaskSnapshot taskSnapshot = await uploadTask;
    String fileUrl = await taskSnapshot.ref.getDownloadURL();
    return fileUrl;
  }
}
