class MessageConstants {
    static const String senderUID = 'senderUID';
  static const String senderName = 'senderName';
  static const String senderImage = 'senderImage';
  static const String receiverUID = 'receiverUID';
  static const String messageUID = 'messageUID';
  static const String message = 'message';
  static const String messageType = 'messageType';
  static const String sentAt = 'sentAt';
  static const String isSeen = 'isSeen';
  static const String repliedMessage = 'repliedMessage';
  static const String repliedTo = 'repliedTo';
  static const String repliedMessageType = 'repliedMessageType';
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
