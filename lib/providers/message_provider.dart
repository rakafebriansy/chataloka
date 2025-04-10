import 'dart:io';

import 'package:chataloka/constants/message_constants.dart';
import 'package:chataloka/constants/user_constants.dart';
import 'package:chataloka/models/last_message_model.dart';
import 'package:chataloka/models/message_model.dart';
import 'package:chataloka/models/message_reply_model.dart';
import 'package:chataloka/models/user_model.dart';
import 'package:chataloka/utilities/global_methods.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class MessageProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool _isSuccess = false;
  bool get isLoading => _isLoading;
  bool get isSuccess => _isSuccess;

  MessageReplyModel? _messageReplyModel;
  MessageReplyModel? get messageReplyModel => _messageReplyModel;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void setMessageReplyModel(MessageReplyModel? messageReplyModel) {
    _messageReplyModel = messageReplyModel;
    notifyListeners();
  }

  Future<void> sendMessageToFirebase({
    required UserModel sender,
    required String contactUID,
    required String contactName,
    required String contactImage,
    required String message,
    required MessageEnum messageType,
    String? groupUID,
    File? file,
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

      final ref =
          '${MessageConstants.chatFiles}/${messageType.name}/${sender.uid}/${contactUID}/${messageUID}';

      String? fileUrl =
          file != null
              ? await storeFileToFirebaseStorage(file: file, reference: ref)
              : null;

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
        fileUrl: fileUrl,
      );

      if (groupUID != null) {
        //
      } else {
        _handleFriendTextMessage(
          senderMessageModel: senderMessageModel,
          contactName: contactName,
          contactImage: contactImage,
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

  Future<void> _handleFriendTextMessage({
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
      final senderChatRef = _firestore
          .collection(UserConstant.users)
          .doc(senderMessageModel.senderUID)
          .collection(MessageConstants.chats)
          .doc(senderMessageModel.contactUID);
      final contactChatRef = _firestore
          .collection(UserConstant.users)
          .doc(senderMessageModel.contactUID)
          .collection(MessageConstants.chats)
          .doc(senderLastMessageModel.senderUID);

      transaction.set(
        senderChatRef
            .collection(MessageConstants.messages)
            .doc(senderMessageModel.messageUID),
        senderMessageModel.toMap(),
      );
      transaction.set(
        contactChatRef
            .collection(MessageConstants.messages)
            .doc(contactMessageModel.messageUID),
        contactMessageModel.toMap(),
      );

      transaction.set(senderChatRef, senderLastMessageModel.toMap());
      transaction.set(
        contactChatRef,
        contactLastMessageModel.toMap(),
        SetOptions(merge: true),
      );
    });
  }

  Stream<QuerySnapshot> getChatListStream({required String userUID}) {
    return _firestore
        .collection(UserConstant.users)
        .doc(userUID)
        .collection(MessageConstants.chats)
        .orderBy(MessageConstants.sentAt, descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot> getMessagesStream({
    required String userUID,
    required String contactUID,
    String? groupUID,
  }) {
    if (groupUID != null) {
      return _firestore
          .collection(UserConstant.groups)
          .doc(contactUID)
          .collection(MessageConstants.messages)
          .orderBy(MessageConstants.sentAt, descending: false)
          .snapshots();
    } else {
      return _firestore
          .collection(UserConstant.users)
          .doc(userUID)
          .collection(MessageConstants.chats)
          .doc(contactUID)
          .collection(MessageConstants.messages)
          .orderBy(MessageConstants.sentAt, descending: false)
          .snapshots();
    }
  }

  Future<void> setMessageAsSeen({
    required String userUID,
    required String contactUID,
    required String messageUID,
    String? groupUID,
  }) async {
    if (groupUID != null) {
      return _firestore
          .collection(UserConstant.groups)
          .doc(contactUID)
          .collection(MessageConstants.messages)
          .doc(messageUID)
          .update({MessageConstants.isSeen: true});
    } else {
      await _firestore.runTransaction((transaction) async {
        final userChatRef = _firestore
            .collection(UserConstant.users)
            .doc(userUID)
            .collection(MessageConstants.chats)
            .doc(contactUID);

        final contactChatRef = _firestore
            .collection(UserConstant.users)
            .doc(contactUID)
            .collection(MessageConstants.chats)
            .doc(userUID);

        transaction.update(
          userChatRef.collection(MessageConstants.messages).doc(messageUID),
          {MessageConstants.isSeen: true},
        );
        transaction.update(
          contactChatRef.collection(MessageConstants.messages).doc(messageUID),
          {MessageConstants.isSeen: true},
        );
        transaction.update(userChatRef, {MessageConstants.isSeen: true});
        transaction.update(contactChatRef, {MessageConstants.isSeen: true});
      });
    }
  }
}
