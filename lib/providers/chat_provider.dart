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

      final MessageModel senderMessageModel = MessageModel(
        senderUID: sender.uid,
        senderName: sender.name,
        senderImage: sender.image,
        contactUID: contactUID,
        messageUID: messageUID,
        message: message,
        messageType: messageType,
        sentAt: DateTime.now(),
        isSeen: false,
        repliedMessage: repliedMessage,
        repliedTo: repliedTo,
        repliedMessageType: repliedMessageType,
      );

      if (groupUID != null) {
        //
      } else {
        _handleFriendMessage(
          senderMessageModel: senderMessageModel,
          contactName: contactName,
          contactImage: contactImage
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
    required MessageModel senderMessageModel,
    required String contactName,
    required String contactImage,
  }) async {
    final MessageModel contactMessageModel = senderMessageModel.copyWith(
      contactUID: senderMessageModel.senderUID,
    );
    final senderLastMessageModel = LastMessageModel.fromMessageModel(
      messageModel: senderMessageModel,
      contactUID: senderMessageModel.contactUID,
      contactName: contactName,
      contactImage: contactImage,
    );
    final contactLastMessageModel = LastMessageModel.fromMessageModel(
      messageModel: contactMessageModel,
      contactUID: contactMessageModel.senderUID,
      contactName: contactMessageModel.senderName,
      contactImage: contactMessageModel.senderImage,
    );
    await _firestore.runTransaction((transaction) async {
      final senderRef = _firestore
          .collection(UserConstant.users)
          .doc(senderMessageModel.senderUID)
          .collection(MessageConstants.chats)
          .doc(senderMessageModel.contactUID);
      final contactRef = _firestore
          .collection(UserConstant.users)
          .doc(senderMessageModel.contactUID)
          .collection(MessageConstants.chats)
          .doc(senderLastMessageModel.senderUID);

      transaction.set(
        senderRef
            .collection(MessageConstants.messages)
            .doc(senderMessageModel.messageUID),
        senderMessageModel.toMap(),
      );
      transaction.set(
        contactRef
            .collection(MessageConstants.messages)
            .doc(contactMessageModel.messageUID),
        contactMessageModel.toMap(),
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
