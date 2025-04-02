import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:chataloka/models/user.dart';
import 'package:chataloka/utilities/firebase_mocks.dart';
import 'package:chataloka/utilities/global_methods.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:chataloka/constants/route.dart';
import 'package:chataloka/constants/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider extends ChangeNotifier {
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

  final StreamController<QuerySnapshot> _friendsStreamController =
      StreamController();
  final StreamController<QuerySnapshot> _friendRequestsStreamController =
      StreamController.broadcast();
  final StreamController<QuerySnapshot> _strangersStreamController =
      StreamController.broadcast();

  Future<bool> checkAuthenticationState() async {
    bool isSignedIn = _auth.currentUser != null;
    await Future.delayed(const Duration(milliseconds: 500));

    if (isSignedIn) {
      _uid = _auth.currentUser!.uid;
      await getUserDataFromFirestore();
      await saveUserDataToSharedPreferences();
      notifyListeners();
    }

    return isSignedIn;
  }

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
    } on FirebaseAuthException catch (_) {
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

  Stream<DocumentSnapshot> getUserStream({required String userId}) {
    return _firestore.collection(UserConstant.users).doc(userId).snapshots();
  }

  Stream<QuerySnapshot> getAllStrangersStream({required String userId}) {
    _firestore.collection(UserConstant.users).doc(userId).snapshots().listen((
      userDoc,
    ) {
      if (!userDoc.exists || userDoc.data() == null) {
        _friendRequestsStreamController.add(QuerySnapshotMock());
        return;
      }

      List<String> friendsList = List<String>.from(
        userDoc[UserConstant.friendsUIDs] ?? [],
      );

      _firestore
          .collection(UserConstant.users)
          .where(UserConstant.uid, whereNotIn: [...friendsList, _uid])
          .snapshots()
          .listen((snapshot) {
            _friendRequestsStreamController.add(snapshot);
          });
    });

    return _friendRequestsStreamController.stream;
  }

  Stream<QuerySnapshot> getAllFriendRequestsStream({required String userId}) {
    _firestore.collection(UserConstant.users).doc(userId).snapshots().listen((
      userDoc,
    ) {
      if (!userDoc.exists || userDoc.data() == null) {
        _friendRequestsStreamController.add(QuerySnapshotMock());
        return;
      }

      List<String> friendRequestsList = List<String>.from(
        userDoc[UserConstant.friendRequestsUIDs] ?? [],
      );

      if (friendRequestsList.isEmpty) {
        _friendRequestsStreamController.add(QuerySnapshotMock());
        return;
      }

      _firestore
          .collection(UserConstant.users)
          .where(UserConstant.uid, whereIn: friendRequestsList)
          .snapshots()
          .listen((snapshot) {
            _friendRequestsStreamController.add(snapshot);
          });
    });

    return _friendRequestsStreamController.stream;
  }

  Stream<QuerySnapshot> getAllFriendsStream({required String userId}) {
    _firestore.collection(UserConstant.users).doc(userId).snapshots().listen((
      userDoc,
    ) {
      if (!userDoc.exists || userDoc.data() == null) {
        _friendsStreamController.add(QuerySnapshotMock());
        return;
      }

      List<String> friendsList = List<String>.from(
        userDoc[UserConstant.friendsUIDs] ?? [],
      );

      if (friendsList.isEmpty) {
        _friendsStreamController.add(QuerySnapshotMock());
        return;
      }

      _firestore
          .collection(UserConstant.users)
          .where(UserConstant.uid, whereIn: friendsList)
          .snapshots()
          .listen((snapshot) {
            _friendsStreamController.add(snapshot);
          });
    });

    return _friendsStreamController.stream;
  }

  Future<void> sendFriendRequest({required String friendId}) async {
    final senderRef = _firestore.collection(UserConstant.users).doc(_uid);
    final receiverRef = _firestore.collection(UserConstant.users).doc(friendId);

    await _firestore.runTransaction((transaction) async {
      transaction.update(receiverRef, {
        UserConstant.friendRequestsUIDs: FieldValue.arrayUnion([_uid]),
      });
      transaction.update(senderRef, {
        UserConstant.sentFriendRequestsUIDs: FieldValue.arrayUnion([friendId]),
      });
    });
    notifyListeners();
  }

  Future<void> cancelFriendRequest({required String friendId}) async {
    final senderRef = _firestore.collection(UserConstant.users).doc(_uid);
    final receiverRef = _firestore.collection(UserConstant.users).doc(friendId);

    await _firestore.runTransaction((transaction) async {
      transaction.update(receiverRef, {
        UserConstant.friendRequestsUIDs: FieldValue.arrayRemove([_uid]),
      });
      transaction.update(senderRef, {
        UserConstant.sentFriendRequestsUIDs: FieldValue.arrayRemove([friendId]),
      });
    });
    notifyListeners();
  }

  Future<void> acceptFriendRequest({required String friendId}) async {
    final receiverRef = _firestore.collection(UserConstant.users).doc(_uid);
    final senderRef = _firestore.collection(UserConstant.users).doc(friendId);

    await _firestore.runTransaction((transaction) async {
      transaction.update(senderRef, {
        UserConstant.friendsUIDs: FieldValue.arrayUnion([_uid]),
      });
      transaction.update(receiverRef, {
        UserConstant.friendsUIDs: FieldValue.arrayUnion([friendId]),
      });
      transaction.update(senderRef, {
        UserConstant.sentFriendRequestsUIDs: FieldValue.arrayRemove([_uid]),
      });
      transaction.update(receiverRef, {
        UserConstant.friendRequestsUIDs: FieldValue.arrayRemove([friendId]),
      });
    });
    notifyListeners();
  }

  Future<void> removeFriend({required String friendId}) async {
    final userRef = _firestore.collection(UserConstant.users).doc(_uid);
    final friendRef = _firestore.collection(UserConstant.users).doc(friendId);

    await _firestore.runTransaction((transaction) async {
      transaction.update(userRef, {
        UserConstant.friendsUIDs: FieldValue.arrayRemove([friendId]),
      });
      transaction.update(friendRef, {
        UserConstant.friendsUIDs: FieldValue.arrayRemove([_uid]),
      });
    });
    notifyListeners();
  }

  Future<void> logout() async {
    await _auth.signOut();
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.clear();
    notifyListeners();
  }

  void disposeFriendsStream() {
    _friendsStreamController.close();
  }

  void disposeFriendRequestsStream() {
    _friendRequestsStreamController.close();
  }

  void disposeStrangersStream() {
    _strangersStreamController.close();
  }
}
