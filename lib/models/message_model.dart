import 'package:chataloka/constants/message_constants.dart';

class MessageModel {
  final String senderUID;
  final String senderName;
  final String senderImage;
  final String receiverUID;
  final String messageUID;
  final String message;
  final MessageEnum messageType;
  final DateTime sentAt;
  final bool isSeen;
  final String repliedMessage;
  final String repliedTo;
  final MessageEnum repliedMessageType;

  MessageModel({
    required this.senderUID,
    required this.senderName,
    required this.senderImage,
    required this.receiverUID,
    required this.messageUID,
    required this.message,
    required this.messageType,
    required this.sentAt,
    required this.isSeen,
    required this.repliedMessage,
    required this.repliedTo,
    required this.repliedMessageType,
  });

  Map<String, dynamic> toMap() {
    return {
      MessageConstants.senderUID: senderUID,
      MessageConstants.senderName: senderName,
      MessageConstants.senderImage: senderImage,
      MessageConstants.receiverUID: receiverUID,
      MessageConstants.messageUID: messageUID,
      MessageConstants.message: message,
      MessageConstants.messageType: messageType.name,
      MessageConstants.sentAt: sentAt.microsecondsSinceEpoch,
      MessageConstants.isSeen: isSeen,
      MessageConstants.repliedMessage: repliedMessage,
      MessageConstants.repliedTo: repliedTo,
      MessageConstants.repliedMessageType: repliedMessageType.name,
    };
  }

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      senderUID: map[MessageConstants.senderUID] ?? '',
      senderName: map[MessageConstants.senderName] ?? '',
      senderImage: map[MessageConstants.senderImage] ?? '',
      receiverUID: map[MessageConstants.receiverUID] ?? '',
      messageUID: map[MessageConstants.messageUID] ?? '',
      message: map[MessageConstants.message] ?? '',
      messageType: map[MessageConstants.messageType].toString().toMessageEnum(),
      sentAt: DateTime.fromMicrosecondsSinceEpoch(map[MessageConstants.sentAt]),
      isSeen: map[MessageConstants.isSeen] ?? '',
      repliedMessage: map[MessageConstants.repliedMessage] ?? '',
      repliedTo: map[MessageConstants.repliedTo] ?? '',
      repliedMessageType:
          map[MessageConstants.repliedMessageType].toString().toMessageEnum(),
    );
  }
}
