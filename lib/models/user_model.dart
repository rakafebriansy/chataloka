import 'package:chataloka/constants/user_constants.dart';

class UserModel {
  String uid;
  String name;
  String phoneNumber;
  String image;
  String token;
  String aboutMe;
  String lastSeen;
  String createdAt;
  bool isOnline;
  List<String> friendsUIDs;
  List<String> friendRequestsUIDs;
  List<String> sentFriendRequestUIDs;

  UserModel({
    required this.uid,
    required this.name,
    required this.phoneNumber,
    required this.image,
    required this.token,
    required this.aboutMe,
    required this.lastSeen,
    required this.createdAt,
    required this.isOnline,
    required this.friendsUIDs,
    required this.friendRequestsUIDs,
    required this.sentFriendRequestUIDs,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map[UserConstant.uid] ?? '',
      name: map[UserConstant.name] ?? '',
      phoneNumber: map[UserConstant.phoneNumber] ?? '',
      image: map[UserConstant.image] ?? '',
      token: map[UserConstant.token] ?? '',
      aboutMe: map[UserConstant.aboutMe] ?? '',
      lastSeen: map[UserConstant.lastSeen] ?? '',
      createdAt: map[UserConstant.createdAt] ?? '',
      isOnline: map[UserConstant.isOnline] ?? '',
      friendsUIDs: List<String>.from(map[UserConstant.friendsUIDs] ?? []),
      friendRequestsUIDs: List<String>.from(map[UserConstant.friendRequestsUIDs] ?? []),
      sentFriendRequestUIDs: List<String>.from(map[UserConstant.sentFriendRequestsUIDs] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      UserConstant.uid: uid,
      UserConstant.name: name,
      UserConstant.phoneNumber: phoneNumber,
      UserConstant.image: image,
      UserConstant.token: token,
      UserConstant.aboutMe: aboutMe,
      UserConstant.lastSeen: lastSeen,
      UserConstant.createdAt: createdAt,
      UserConstant.isOnline: isOnline,
      UserConstant.friendsUIDs: friendsUIDs,
      UserConstant.friendRequestsUIDs: friendRequestsUIDs,
      UserConstant.sentFriendRequestsUIDs: sentFriendRequestUIDs,
    };
  }
}
