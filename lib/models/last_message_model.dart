import 'package:chataloka/constants/message_constants.dart';
import 'package:chataloka/models/message_model.dart';

class LastMessageModel {
  final String senderUID;
  final String contactUID;
  final String contactName;
  final String contactImage;
  final String message;
  final MessageEnum messageType;
  final DateTime sentAt;
  final bool isSeen;

  LastMessageModel({
    required this.senderUID,
    required this.contactUID,
    required this.contactName,
    required this.contactImage,
    required this.message,
    required this.messageType,
    required this.sentAt,
    required this.isSeen,
  });

  Map<String, dynamic> toMap() {
    return {
      MessageConstants.senderUID: senderUID,
      MessageConstants.contactName: contactName,
      MessageConstants.contactImage: contactImage,
      MessageConstants.contactUID: contactUID,
      MessageConstants.message: message,
      MessageConstants.messageType: messageType.name,
      MessageConstants.sentAt: sentAt.microsecondsSinceEpoch,
      MessageConstants.isSeen: isSeen,
    };
  }

  factory LastMessageModel.fromMessageModel({
    required MessageModel messageModel,
    required String contactUID,
    required String contactName,
    required String contactImage,
  }) {
    return LastMessageModel(
      senderUID: messageModel.senderUID,
      contactName: contactName,
      contactImage: contactImage,
      contactUID: contactUID,
      message: messageModel.message,
      messageType: messageModel.messageType,
      sentAt: messageModel.sentAt,
      isSeen: false,
    );
  }

  factory LastMessageModel.fromMap(Map<String, dynamic> map) {
    return LastMessageModel(
      senderUID: map[MessageConstants.senderUID] ?? '',
      contactName: map[MessageConstants.contactName] ?? '',
      contactImage: map[MessageConstants.contactImage] ?? '',
      contactUID: map[MessageConstants.contactUID] ?? '',
      message: map[MessageConstants.message] ?? '',
      messageType: map[MessageConstants.messageType].toString().toMessageEnum(),
      sentAt: DateTime.fromMicrosecondsSinceEpoch(map[MessageConstants.sentAt]),
      isSeen: map[MessageConstants.isSeen] ?? false,
    );
  }
}
