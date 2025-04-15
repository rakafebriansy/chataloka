import 'package:chataloka/constants/message_constants.dart';

class MessageModel {
  final String senderUID;
  final String senderName;
  final String senderImage;
  final String contactUID;
  final String messageUID;
  final String message;
  final MessageEnum messageType;
  final DateTime sentAt;
  final bool isSeen;
  final String repliedMessage;
  final String repliedTo;
  final MessageEnum repliedMessageType;
  final String? fileUrl;
  final String? repliedFileUrl;

  MessageModel({
    required this.senderUID,
    required this.senderName,
    required this.senderImage,
    required this.contactUID,
    required this.messageUID,
    required this.message,
    required this.messageType,
    required this.sentAt,
    required this.isSeen,
    required this.repliedMessage,
    required this.repliedTo,
    required this.repliedMessageType,
    required this.fileUrl,
    required this.repliedFileUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      MessageConstants.senderUID: senderUID,
      MessageConstants.senderName: senderName,
      MessageConstants.senderImage: senderImage,
      MessageConstants.contactUID: contactUID,
      MessageConstants.messageUID: messageUID,
      MessageConstants.message: message,
      MessageConstants.messageType: messageType.name,
      MessageConstants.sentAt: sentAt.millisecondsSinceEpoch,
      MessageConstants.isSeen: isSeen,
      MessageConstants.repliedMessage: repliedMessage,
      MessageConstants.repliedTo: repliedTo,
      MessageConstants.repliedMessageType: repliedMessageType.name,
      MessageConstants.fileUrl: fileUrl,
      MessageConstants.repliedFileUrl: repliedFileUrl,
    };
  }

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      senderUID: map[MessageConstants.senderUID] ?? '',
      senderName: map[MessageConstants.senderName] ?? '',
      senderImage: map[MessageConstants.senderImage] ?? '',
      contactUID: map[MessageConstants.contactUID] ?? '',
      messageUID: map[MessageConstants.messageUID] ?? '',
      message: map[MessageConstants.message] ?? '',
      messageType: map[MessageConstants.messageType].toString().toMessageEnum(),
      sentAt: DateTime.fromMillisecondsSinceEpoch(map[MessageConstants.sentAt]),
      isSeen: map[MessageConstants.isSeen] ?? false,
      repliedMessage: map[MessageConstants.repliedMessage] ?? '',
      repliedTo: map[MessageConstants.repliedTo] ?? '',
      repliedMessageType:
          map[MessageConstants.repliedMessageType].toString().toMessageEnum(),
      fileUrl: map[MessageConstants.fileUrl] ?? '',
      repliedFileUrl: map[MessageConstants.repliedFileUrl] ?? '',
    );
  }

  copyWith({required contactUID}) {
    return MessageModel(
      senderUID: this.senderUID,
      senderName: this.senderName,
      senderImage: this.senderImage,
      contactUID: contactUID,
      messageUID: this.messageUID,
      message: this.message,
      messageType: this.messageType,
      sentAt: this.sentAt,
      isSeen: this.isSeen,
      repliedMessage: this.repliedMessage,
      repliedTo: this.repliedTo,
      repliedMessageType: this.repliedMessageType,
      fileUrl: this.fileUrl,
      repliedFileUrl: this.repliedFileUrl,
    );
  }
}


