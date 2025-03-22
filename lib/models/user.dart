import 'package:chataloka/constants/user.dart' as UserConstant;

class User {
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

  User({
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

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      uid: map[UserConstant.User.uid] ?? '',
      name: map[UserConstant.User.name] ?? '',
      phoneNumber: map[UserConstant.User.phoneNumber] ?? '',
      image: map[UserConstant.User.image] ?? '',
      token: map[UserConstant.User.token] ?? '',
      aboutMe: map[UserConstant.User.aboutMe] ?? '',
      lastSeen: map[UserConstant.User.lastSeen] ?? '',
      createdAt: map[UserConstant.User.createdAt] ?? '',
      isOnline: map[UserConstant.User.isOnline] ?? '',
      friendsUIDs: List<String>.from(map[UserConstant.User.friendsUIDs] ?? []),
      friendRequestsUIDs: List<String>.from(map[UserConstant.User.friendRequestsUIDs] ?? []),
      sentFriendRequestUIDs: List<String>.from(map[UserConstant.User.sentFriendRequestsUIDs] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      UserConstant.User.uid: uid,
      UserConstant.User.name: name,
      UserConstant.User.phoneNumber: phoneNumber,
      UserConstant.User.image: image,
      UserConstant.User.token: token,
      UserConstant.User.aboutMe: aboutMe,
      UserConstant.User.lastSeen: lastSeen,
      UserConstant.User.createdAt: createdAt,
      UserConstant.User.isOnline: isOnline,
      UserConstant.User.friendsUIDs: friendsUIDs,
      UserConstant.User.friendRequestsUIDs: friendRequestsUIDs,
      UserConstant.User.sentFriendRequestsUIDs: sentFriendRequestUIDs,
    };
  }
}
