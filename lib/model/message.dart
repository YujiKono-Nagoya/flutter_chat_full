import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Message {
  final String senderId;
  final String senderEmail;
  final String receiverId;
  final String message;
  final Timestamp timestamp;
  final List readUser;
  final String messageId;

  Message(
      {required this.senderId,
      required this.senderEmail,
      required this.receiverId,
      required this.timestamp,
      required this.message,
      required this.readUser,
      required this.messageId});

  // convert to a map
  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderEmail': senderEmail,
      'receiverId': receiverId,
      'message': message,
      'timestamp': timestamp,
      'readUser': readUser,
      'messageId': messageId
    };
  }
}

class ReadMessage {
  final String latestmessage;
  final Timestamp latesttimestamp;
  final String readUser;

  ReadMessage({
    required this.latesttimestamp,
    required this.latestmessage,
    required this.readUser,
  });

  // convert to a map
  Map<String, dynamic> toMap() {
    return {
      'latestmessage': latestmessage,
      'latesttimestamp': latesttimestamp,
      'readUser': readUser,
    };
  }
}

