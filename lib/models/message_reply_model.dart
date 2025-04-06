import 'package:chataloka/constants/message_constants.dart';

class MessageReplyModel {
  final String senderUID;
  final String contactName;
  final String contactImage;
  final String message;
  final MessageEnum messageType;

  final bool isMe;

  MessageReplyModel({
    required this.senderUID,
    required this.contactName,
    required this.contactImage,
    required this.message,
    required this.messageType,
 
    required this.isMe,
  });

  Map<String, dynamic> toMap() {
    return {
      MessageConstants.senderUID: senderUID,
      MessageConstants.contactName: contactName,
      MessageConstants.contactImage: contactImage,
      MessageConstants.message: message,
      MessageConstants.messageType: messageType.name,
      
      MessageConstants.isMe: isMe,
    };
  }

  factory MessageReplyModel.fromMap(Map<String, dynamic> map) {
    return MessageReplyModel(
      senderUID: map[MessageConstants.senderUID] ?? '',
      contactName: map[MessageConstants.contactName] ?? '',
      contactImage: map[MessageConstants.contactImage] ?? '',
      message: map[MessageConstants.message] ?? '',
      messageType: map[MessageConstants.messageType].toString().toMessageEnum(),
    
      isMe: map[MessageConstants.isMe] ?? false,
    );
  }
}
