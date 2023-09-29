import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_full/components/chat_bubble.dart';
import 'package:flutter_chat_full/components/my_text_field.dart';
import 'package:flutter_chat_full/pages/home_page.dart';
import 'package:flutter_chat_full/services/chat/chat_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;
final usersStream = _firestore.collection('users').snapshots();
ScrollController _scrollController = ScrollController();
final String currentUserId = _auth.currentUser!.uid;
final ChatService _chatService = ChatService();
final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

class ChatPage extends ConsumerStatefulWidget {
  final String receiverUserEmail; //(=data['email])
  final String receiverUserID; //(=data['uid])
  final List<String> readUserList;
  final String userName;

  const ChatPage({
    super.key,
    required this.receiverUserEmail,
    required this.receiverUserID,
    required this.readUserList,
    required this.userName,
  });

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final String currentUserId = _auth.currentUser!.uid;
  final TextEditingController _messageController = TextEditingController();

  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      await _chatService.sendMessage(
          widget.receiverUserID, _messageController.text);
      // clear the text controller after sending the message
      _messageController.clear();
    }
  }

  @override
  void initState() {
    super.initState();

    List<String> ids = [currentUserId, widget.receiverUserID];
    ids.sort();
    String chatRoomId = ids.join("_");

    // Update 'readUsers' field in all messages except 'latestmessage'
    FirebaseFirestore.instance
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .where('documentId',
            isNotEqualTo:
                'latestmessage') // Assuming you have a field 'documentId' to identify each message
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        doc.reference.update({'readUsers': currentUserId});
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<Map<String, dynamic>>(
            stream: getMessageData(widget.receiverUserID),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Text('Loading latest message...');
              }

              if (snapshot.hasError) {
                return Text('');
              }

              Map<String, dynamic>? messageData = snapshot.data!;
              if (messageData['latesttimestamp'] == null) {
                return Text('');
              }

              Timestamp timestamp = messageData['latesttimestamp'];
              DateTime dateTime = timestamp.toDate();
              String sendtime = DateFormat('HH:mm').format(dateTime);
              String sendate = DateFormat('MM/dd').format(dateTime);

              return Column(
                children: [
                  //
                  Row(children: [
                    IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(Icons.arrow_back)),
                    SizedBox(width: 20),
                    Text(
                      widget.userName,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    )
                  ]),

                  SizedBox(height: 50),

                  Text(sendate),
                  SizedBox(height: 10),

                  //messages
                  Expanded(
                    child: _buildMessageList(),
                  ),
                  // Column(
                  //   children: widget.readUserList
                  //       .map((readUser) => Text(readUser))
                  //       .toList(),
                  // ),

                  // user input
                  _buildMessageInput(),
                ],
              );
            }),
      ),
    );
  }

  // build message list
  Widget _buildMessageList() {
    return StreamBuilder(
      stream: _chatService.getMessages(
          widget.receiverUserID, _firebaseAuth.currentUser!.uid),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('Loading..');
        }

        return ListView(
          controller: _scrollController,
          children: snapshot.data!.docs
              .map((document) => _buildMessageItem(document))
              .toList(),
        );
      },
    );
  }

  // build message item
  Widget _buildMessageItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    bool isCurrentUser = data['senderId'] == _firebaseAuth.currentUser!.uid;

    // along the messages to the right if the sender is the current user, otherwise to the left
    var alignment =
        isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;

    //メッセージの送信時間を取得
    Timestamp timestamp = data['timestamp'];
    DateTime dateTime = timestamp.toDate();
    String sendtime = DateFormat('HH:mm').format(dateTime);

    return Container(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment:
              (data['senderId'] == _firebaseAuth.currentUser!.uid)
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.end,
          mainAxisAlignment:
              (data['senderId'] == _firebaseAuth.currentUser!.uid)
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start,
          children: [
            ChatBubble(
              message: data['message'],
              conditions: data['senderId'] == _firebaseAuth.currentUser!.uid,
            ),
            Column(
              children: [
                Text(sendtime),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // build message input
  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.all(25.0),
      child: Row(
        children: [
          //textField
          Expanded(
            child: MyTextField(
              controller: _messageController,
              hintText: 'メッセージ',
              watch: false,
            ),
          ),

          // send button
          IconButton(
            onPressed: sendMessage,
            icon: Icon(
              Icons.arrow_upward,
              size: 40,
            ),
          ),
        ],
      ),
    );
  }

  Stream<QuerySnapshot> getReadUserList(String receiverId) {
    List<String> ids = [currentUserId, receiverId];
    ids.sort();
    String chatRoomId = ids.join("_");

    return _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .snapshots();
  }
}

Stream<Map<String, dynamic>> getMessageData(String receiverId) {
  List<String> ids = [currentUserId, receiverId];
  ids.sort();
  String chatRoomId = ids.join("_");

  return FirebaseFirestore.instance
      .collection('chat_rooms')
      .doc(chatRoomId)
      .collection('latestmessage')
      .doc('latestmessage')
      .snapshots()
      .map((snapshot) => snapshot.data() as Map<String, dynamic>);
}

class ChatPage2 extends ConsumerStatefulWidget {
  final String receiverUserEmail; //(=data['email])
  final String receiverUserID; //(=data['uid])
  final String userName;
  ChatPage2({
    required this.receiverUserEmail,
    required this.receiverUserID,
    required this.userName,
    super.key,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ChatPage2State();
}

class _ChatPage2State extends ConsumerState<ChatPage2> {
  final TextEditingController _messageController = TextEditingController();
  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      await _chatService.sendMessage(
          widget.receiverUserID, _messageController.text);
      // clear the text controller after sending the message
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Column(
          children: [
            Text(currentUserId),
            Text(widget.receiverUserEmail),
            Text(widget.receiverUserID),
            Text(widget.userName),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _chatService.getMessages(
                    currentUserId, widget.receiverUserID),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error${snapshot.error}');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Text('Loading..');
                  }

                  return ListView(
                    controller: _scrollController,
                    children: snapshot.data!.docs
                        .map((document) => _buildMessageItem2(document))
                        .toList(),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(25.0),
              child: Row(
                children: [
                  //textField
                  Expanded(
                    child: MyTextField(
                      controller: _messageController,
                      hintText: 'メッセージ',
                      watch: false,
                    ),
                  ),

                  // send button
                  IconButton(
                    onPressed: sendMessage,
                    icon: Icon(
                      Icons.arrow_upward,
                      size: 40,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

Widget _buildMessageItem2(DocumentSnapshot document) {
  Map<String, dynamic> data = document.data() as Map<String, dynamic>;
  bool isCurrentUser = data['senderId'] == _firebaseAuth.currentUser!.uid;

  // along the messages to the right if the sender is the current user, otherwise to the left
  var alignment = isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;

  //メッセージの送信時間を取得
  Timestamp timestamp = data['timestamp'];
  DateTime dateTime = timestamp.toDate();
  String sendtime = DateFormat('HH:mm').format(dateTime);

  return Container(
    alignment: alignment,
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: (data['senderId'] == _firebaseAuth.currentUser!.uid)
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.end,
        mainAxisAlignment: (data['senderId'] == _firebaseAuth.currentUser!.uid)
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          ChatBubble(
            message: data['message'],
            conditions: data['senderId'] == _firebaseAuth.currentUser!.uid,
          ),
          Column(
            children: [
              Text(sendtime),
            ],
          ),
        ],
      ),
    ),
  );
}
