import 'package:chataloka/constants/message_constants.dart';

class MessageReplyModel {
  final String senderUID;
  final String senderName;
  final String senderImage;
  final String message;
  final MessageEnum messageType;

  final bool isMe;

  MessageReplyModel({
    required this.senderUID,
    required this.senderName,
    required this.senderImage,
    required this.message,
    required this.messageType,

    required this.isMe,
  });

  Map<String, dynamic> toMap() {
    return {
      MessageConstants.senderUID: senderUID,
      MessageConstants.senderName: senderName,
      MessageConstants.senderImage: senderImage,
      MessageConstants.message: message,
      MessageConstants.messageType: messageType.name,

      MessageConstants.isMe: isMe,
    };
  }

  factory MessageReplyModel.fromMap(Map<String, dynamic> map) {
    return MessageReplyModel(
      senderUID: map[MessageConstants.senderUID] ?? '',
      senderName: map[MessageConstants.senderName] ?? '',
      senderImage: map[MessageConstants.senderImage] ?? '',
      message: map[MessageConstants.message] ?? '',
      messageType: map[MessageConstants.messageType].toString().toMessageEnum(),

      isMe: map[MessageConstants.isMe] ?? false,
    );
  }
}
