import 'package:chataloka/constants/message_constants.dart';
import 'package:chataloka/constants/user_constants.dart';
import 'package:chataloka/models/last_message_model.dart';
import 'package:chataloka/models/message_model.dart';
import 'package:chataloka/models/message_reply_model.dart';
import 'package:chataloka/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class ChatProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool _isSuccess = false;
  bool get isLoading => _isLoading;
  bool get isSuccess => _isSuccess;

  MessageReplyModel? _messageReplyModel;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  void setMessageReplyModel(MessageReplyModel? messageReplyModel) {
    _messageReplyModel = messageReplyModel;
    notifyListeners();
  }

  Future<void> sendTextMessageToFirestore({
    required UserModel sender,
    required String contactUID,
    required String contactName,
    required String contactImage,
    required String message,
    required MessageEnum messageType,
    String? groupUID,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      var messageUID = const Uuid().v4();
      String repliedMessage = _messageReplyModel?.message ?? '';
      String repliedTo =
          _messageReplyModel == null
              ? ''
              : _messageReplyModel!.isMe
              ? 'You'
              : _messageReplyModel!.senderName;
      MessageEnum repliedMessageType =
          _messageReplyModel?.messageType ?? MessageEnum.text;

      final MessageModel messageModel = MessageModel(
        senderUID: sender.uid,
        contactUID: contactUID,
        senderName: contactName,
        senderImage: contactImage,
        messageUID: messageUID,
        message: message,
        messageType: messageType,
        sentAt: DateTime.now(),
        isSeen: false,
        repliedMessage: repliedMessage,
        repliedTo: repliedTo,
        repliedMessageType: repliedMessageType,
      );

      final senderLastMessageModel = LastMessageModel.fromMessageModel(
        messageModel: messageModel,
        contactUID: contactUID,
        contactName: contactName,
        contactImage: contactImage,
      );
      final contactLastMessageModel = LastMessageModel.fromMessageModel(
        messageModel: messageModel,
        contactUID: messageModel.senderUID,
        contactName: messageModel.senderName,
        contactImage: messageModel.senderImage,
      );

      if (groupUID != null) {
        //
      } else {
        _handleFriendMessage(
          messageModel: messageModel,
          senderLastMessageModel: senderLastMessageModel,
          contactLastMessageModel: contactLastMessageModel,
        );

        setMessageReplyModel(null);
      }
      _isSuccess = true;
    } catch (error) {
      _isSuccess = false;
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _handleFriendMessage({
    required MessageModel messageModel,
    required LastMessageModel senderLastMessageModel,
    required LastMessageModel contactLastMessageModel,
  }) async {
    await _firestore.runTransaction((transaction) async {
      final senderRef = _firestore
          .collection(UserConstant.users)
          .doc(messageModel.senderUID)
          .collection(MessageConstants.chats)
          .doc(messageModel.contactUID);
      final contactRef = _firestore
          .collection(UserConstant.users)
          .doc(messageModel.contactUID)
          .collection(MessageConstants.chats)
          .doc(messageModel.senderUID);

      transaction.set(
        senderRef
            .collection(MessageConstants.messages)
            .doc(messageModel.messageUID),
        messageModel.toMap(),
      );
      transaction.set(
        contactRef
            .collection(MessageConstants.messages)
            .doc(messageModel.messageUID),
        messageModel.toMap(),
      );

      transaction.set(senderRef, {
        'lastMessage': senderLastMessageModel.toMap(),
      }, SetOptions(merge: true));
      transaction.set(contactRef, {
        'lastMessage': contactLastMessageModel.toMap(),
      }, SetOptions(merge: true));
    });
  }
}
