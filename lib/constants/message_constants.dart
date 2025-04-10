class MessageConstants {
  static const String chats = 'chats';
  static const String chatFiles = 'chatFiles';
  static const String contactUID = 'contactUID';
  static const String contactName = 'contactName';
  static const String contactImage = 'contactImage';
  static const String fileUrl = 'fileUrl';
  static const String isMe = 'isMe';
  static const String isSeen = 'isSeen';
  static const String groupUID = 'groupUID';
  static const String lastMessage = 'lastMessage';
  static const String message = 'message';
  static const String messages = 'messages';
  static const String messageType = 'messageType';
  static const String messageUID = 'messageUID';
  static const String repliedMessage = 'repliedMessage';
  static const String repliedMessageType = 'repliedMessageType';
  static const String repliedTo = 'repliedTo';
  static const String senderImage = 'senderImage';
  static const String senderName = 'senderName';
  static const String senderUID = 'senderUID';
  static const String sentAt = 'sentAt';
}

enum MessageEnum { text, image, video, audio }

extension MessageEnumExtension on String {
  MessageEnum toMessageEnum() {
    switch (this) {
      case 'image':
        return MessageEnum.image;
      case 'video':
        return MessageEnum.video;
      case 'audio':
        return MessageEnum.audio;
      case 'text':
      default:
        return MessageEnum.text;
    }
  }
}

class ChatScreenArguments {
  String contactUID;
  String contactName;
  String contactImage;
  String? groupUID;

  ChatScreenArguments({
    required this.contactUID,
    required this.contactName,
    required this.contactImage,
    this.groupUID,
  });
}
