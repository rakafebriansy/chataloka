import 'package:chataloka/constants/message_constants.dart';

class MessageModel {
  final String senderUID;
  final String receiverUID;
  final String contactName;
  final String contactImage;
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
    required this.receiverUID,
    required this.contactName,
    required this.contactImage,
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
      MessageConstants.receiverUID: receiverUID,
      MessageConstants.contactName: contactName,
      MessageConstants.contactImage: contactImage,
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
      contactName: map[MessageConstants.contactName] ?? '',
      contactImage: map[MessageConstants.contactImage] ?? '',
      receiverUID: map[MessageConstants.receiverUID] ?? '',
      messageUID: map[MessageConstants.messageUID] ?? '',
      message: map[MessageConstants.message] ?? '',
      messageType: map[MessageConstants.messageType].toString().toMessageEnum(),
      sentAt: DateTime.fromMicrosecondsSinceEpoch(map[MessageConstants.sentAt]),
      isSeen: map[MessageConstants.isSeen] ?? false,
      repliedMessage: map[MessageConstants.repliedMessage] ?? '',
      repliedTo: map[MessageConstants.repliedTo] ?? '',
      repliedMessageType:
          map[MessageConstants.repliedMessageType].toString().toMessageEnum(),
    );
  }

  copyWith({required contactName, required contactImage}) {
    return MessageModel(
      senderUID: this.senderUID,
      receiverUID: this.receiverUID,
      contactName: contactName,
      contactImage: contactImage,
      messageUID: this.messageUID,
      message: this.message,
      messageType: this.messageType,
      sentAt: this.sentAt,
      isSeen: this.isSeen,
      repliedMessage: this.repliedMessage,
      repliedTo: this.repliedTo,
      repliedMessageType: this.repliedMessageType,
    );
  }
}
