import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_full/model/message.dart';
import 'package:intl/intl.dart';

class ChatService extends ChangeNotifier {
  // get instance of auth and firestore
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // SEND MESSAGE
  Future<void> sendMessage(String receiverId, String message) async {
    // get current user info

    final String currentUserId = _firebaseAuth.currentUser!.uid;
    final String currentUserEmail = _firebaseAuth.currentUser!.email.toString();
    final Timestamp latesttimestamp = Timestamp.now();
    final Timestamp timestamp = Timestamp.now();
    DateTime dateTime = timestamp.toDate();

    String formattedTime =
        DateFormat('yyyy-MM-dd HH:mm:ss.SSS').format(dateTime);

    // create a new message
    Message newMessage = Message(
        senderId: currentUserId,
        senderEmail: currentUserEmail,
        receiverId: receiverId,
        timestamp: timestamp,
        message: message,
        readUser: [currentUserId], // 配列として要素を追加
        messageId: formattedTime);

    ReadMessage readMessage = ReadMessage(
        latesttimestamp: latesttimestamp,
        latestmessage: message,
        readUser: currentUserId);

    // construct chat room id from current user id and receiver id
    List<String> ids = [currentUserId, receiverId];
    ids.sort(); //sort the ids (this ensures the chat room id is always the same for any pair of people)
    String chatRoomId =
        ids.join("_"); // combine the info a single to use as a chatroomId

    // add new message to database
    await _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .doc(formattedTime)
        .set(newMessage.toMap());

    await _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('latestmessage')
        .doc('latestmessage')
        .set({
      'latestmessage': message,
      'latesttimestamp': timestamp,
      'readUser': currentUserId
    });

    await _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('latestmessage')
        .doc(currentUserId)
        .set(readMessage.toMap());
  }

  Future<void> sendreadUser(String receiverId, Timestamp latesttimestamp,
      String readUser, String latestmessage) async {
    final String currentUserId = _firebaseAuth.currentUser!.uid;
    List<String> ids = [currentUserId, receiverId];
    ids.sort(); //sort the ids (this ensures the chat room id is always the same for any pair of people)
    String chatRoomId = ids.join("_");

    await _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('latestmessage')
        .doc('latestmessage')
        .set({
      'latesttimestamp': latesttimestamp,
      'latestmessage': latestmessage,
      'readUser': currentUserId + ', ' + receiverId
    });
  }

  // GET MESSAGES
  Stream<QuerySnapshot> getMessages(String userId, String otherUserId) {
    // construct chat room id from user ids (sorted to ensure it matches the id used when sending messages)
    List<String> ids = [userId, otherUserId];
    ids.sort();
    String chatRoomId = ids.join('_');

    return _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  Stream<QuerySnapshot> getnotreadMessages(String userId, String otherUserId) {
    // construct chat room id from user ids (sorted to ensure it matches the id used when sending messages)
    List<String> ids = [userId, otherUserId];
    ids.sort();
    String chatRoomId = ids.join('_');

    return _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .where('readUsers', arrayContains: userId)
        .snapshots();
  }

  Stream<QuerySnapshot> getLatestMessage(String userId, String otherUserId) {
    // Construct chat room id from user ids (sorted to ensure it matches the id used when sending messages)
    List<String> ids = [userId, otherUserId];
    ids.sort();
    String chatRoomId = ids.join('_');

    // Query messages collection and order by timestamp in descending order (latest first)
    return _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp',
            descending:
                true) // Assuming 'timestamp' is the field with message timestamps
        .limit(10) // Limit the result to 1 message (the latest one)
        .snapshots();
  }

  Stream<QuerySnapshot> getUsersStream({Query Function(Query)? changeQuery}) {
    Query query = _firestore.collection('users');
    if (changeQuery != null) {
      query = changeQuery(query);
    }
    return query.snapshots();
  }
}
