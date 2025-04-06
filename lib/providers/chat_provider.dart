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
    required String receiverUID,
    required String receiverName,
    required String receiverImage,
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
              : _messageReplyModel!.contactName;
      MessageEnum repliedMessageType =
          _messageReplyModel?.messageType ?? MessageEnum.text;

      final MessageModel senderMessageModel = MessageModel(
        senderUID: sender.uid,
        receiverUID: receiverUID,
        contactName: receiverName,
        contactImage: receiverImage,
        messageUID: messageUID,
        message: message,
        messageType: messageType,
        sentAt: DateTime.now(),
        isSeen: false,
        repliedMessage: repliedMessage,
        repliedTo: repliedTo,
        repliedMessageType: repliedMessageType,
      );

      final MessageModel receiverMessageModel = senderMessageModel.copyWith(
        contactName: sender.image,
        contactImage: sender.name,
      );

      if (groupUID != null) {
        //
      } else {
        _handleFriendMessage(
          senderMessageModel: senderMessageModel,
          receiverMessageModel: receiverMessageModel,
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
    required MessageModel receiverMessageModel,
  }) async {
    final senderLastMessageModel = LastMessageModel.fromMessageModel(
      senderMessageModel,
    );
    final receiverLastMessageModel = LastMessageModel.fromMessageModel(
      senderMessageModel,
    );

    await _firestore.runTransaction((transaction) async {
      final senderRef = _firestore
          .collection(UserConstant.users)
          .doc(senderMessageModel.senderUID)
          .collection(MessageConstants.chats)
          .doc(receiverMessageModel.receiverUID);
      final receiverRef = _firestore
          .collection(UserConstant.users)
          .doc(receiverMessageModel.senderUID)
          .collection(MessageConstants.chats)
          .doc(senderMessageModel.receiverUID);

      transaction.set(
        senderRef
            .collection(MessageConstants.messages)
            .doc(senderMessageModel.messageUID),
        senderMessageModel.toMap(),
      );
      transaction.set(
        receiverRef
            .collection(MessageConstants.messages)
            .doc(receiverMessageModel.messageUID),
        receiverMessageModel.toMap(),
      );

      transaction.set(senderRef, {
        'lastMessage': senderLastMessageModel.toMap(),
      }, SetOptions(merge: true));
      transaction.set(receiverRef, {
        'lastMessage': receiverLastMessageModel.toMap(),
      }, SetOptions(merge: true));
    });
  }
}
