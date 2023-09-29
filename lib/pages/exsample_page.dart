import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_full/pages/home_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../services/chat/chat_service.dart';
import 'chat_page.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;
final ChatService _chatService = ChatService();
final String currentUserId = _auth.currentUser!.uid;

final usersStreamProvider =
    StreamProvider((ref) => _chatService.getUsersStream());

final keywordProvider = StateProvider<String?>((ref) => '');

TextEditingController _nameSerchController = TextEditingController(text: '');

final usersStream = _firestore.collection('users').snapshots();
String _searchValue = '';

Widget _buildUserList2() {
  return Consumer(
    builder: (context, ref, child) {
      final users = ref.watch(usersStreamProvider);
      final keyword = ref.watch(keywordProvider);
      return users.when(
          data: (data) {
            final docs = data.docs
                .where((element) => (element['name'].contains(_searchValue)))
                .toList();
            return ListView.builder(
              shrinkWrap: true,
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final user = docs[index].data() as Map<String, dynamic>;
                final String imageUrl = user['image'];
                String image = Uri.encodeFull(imageUrl);
                return StreamBuilder<Map<String, dynamic>>(
                    stream: getMessageData(user['uid']),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Text('Loading latest message...');
                      }

                      if (snapshot.hasError) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: ((context) => ChatPage2(
                                    receiverUserEmail: user['email'],
                                    receiverUserID: user['uid'],
                                    userName: user['name'])),
                              ),
                            );
                          },
                          child: ListTile(
                            title: Column(
                              children: [
                                Row(
                                  children: [
                                    ClipOval(
                                        child: Container(
                                      width: 20,
                                      height: 20,
                                      color: Colors.amber,
                                      child: CircleAvatar(
                                        radius: 64,
                                        backgroundImage: NetworkImage(
                                            'https://www.pngitem.com/pimgs/m/421-4212266_transparent-default-avatar-png-default-avatar-images-png.png'),
                                      ),
                                    )),
                                    // Text(imageUrl),
                                    ClipOval(
                                      child: Image.network(
                                        imageUrl,
                                        width: 20, // 画像の幅を調整する場合、必要に応じて変更してください
                                        height:
                                            20, // 画像の高さを調整する場合、必要に応じて変更してください
                                        fit: BoxFit
                                            .cover, // 画像をウィジェットにフィットさせる方法を指定します
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              user['name'],
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        );
                      }
                      Map<String, dynamic> readUserData = snapshot.data!;
                      String latestmessage = readUserData['latestmessage'];
                      String readUser = readUserData['readUser'];
                      Timestamp latesttimestamp =
                          readUserData['latesttimestamp'];

                      void _addReadUser() {
                        if (readUser != currentUserId &&
                            readUser != currentUserId + ', ' + user['uid']) {
                          _chatService.sendreadUser(
                              user['uid'],
                              latesttimestamp,
                              currentUserId + ', ' + user['uid'],
                              latestmessage);
                        }
                      }

                      return StreamBuilder<QuerySnapshot>(
                          stream: getReadUserList(user['uid']),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Text('Loading latest message...');
                            }
                            if (snapshot.hasError) {
                              return Text('');
                            }
                            final messageData = snapshot.data!.docs;
                            List<String> readUserList = messageData
                                .map((doc) =>
                                    (doc['readUser'] as List).join(', '))
                                .toList();
                            int readUserCount = 0;
                            if (readUserData['readUser'] ==
                                currentUserId + ', ' + user['uid']) {
                              readUserCount = 0;
                            }

                            for (String userId in readUserList) {
                              if (readUser != currentUserId &&
                                  readUser !=
                                      currentUserId + ', ' + user['uid'] &&
                                  userId != currentUserId &&
                                  userId !=
                                      currentUserId + ', ' + user['uid']) {
                                readUserCount++;
                              } else {
                                break; // currentUserId を見つけたらループを終了
                              }
                            }
                            String readUserCountString =
                                readUserCount.toString();

                            return Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(color: Colors.grey),
                                ),
                              ),
                              child: ListTile(
                                title: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Image.asset(
                                          user['image'],
                                          scale: 5,
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              user['name'],
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20),
                                            ),
                                            Text(
                                              readUserData['latestmessage'],
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Column(
                                          children: [
                                            SizedBox(
                                              child: StreamBuilder<
                                                  Map<String, dynamic>>(
                                                stream:
                                                    getMessageData(user['uid']),
                                                builder: ((context, snapshot) {
                                                  if (snapshot
                                                          .connectionState ==
                                                      ConnectionState.waiting) {
                                                    return Text(
                                                        'Loading latest message...');
                                                  }

                                                  if (snapshot.hasError) {
                                                    return Text('');
                                                  }

                                                  Map<String, dynamic>?
                                                      messageData =
                                                      snapshot.data!;
                                                  if (messageData[
                                                          'latesttimestamp'] ==
                                                      null) {
                                                    return Text('');
                                                  }

                                                  Timestamp timestamp =
                                                      messageData[
                                                          'latesttimestamp'];
                                                  DateTime dateTime =
                                                      timestamp.toDate();
                                                  String sendtime =
                                                      DateFormat('HH:mm')
                                                          .format(dateTime);
                                                  String sendate =
                                                      DateFormat('MM/dd')
                                                          .format(dateTime);
                                                  return Text(sendate);
                                                }),
                                              ),
                                            ),
                                            readUserCount == 0
                                                ? SizedBox()
                                                : SizedBox(
                                                    child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                                shape: BoxShape
                                                                    .circle,
                                                                color: Colors
                                                                    .orange),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Text(
                                                            readUserCountString,
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white),
                                                          ),
                                                        )),
                                                  ),
                                          ],
                                        ),
                                        SizedBox(width: 10),
                                        Icon(Icons.arrow_forward_ios),
                                      ],
                                    ),
                                  ],
                                ),
                                onTap: () async {
                                  _addReadUser();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: ((context) => ChatPage(
                                          receiverUserEmail: user['email'],
                                          receiverUserID: user['uid'],
                                          readUserList: readUserList,
                                          userName: user['name'])),
                                    ),
                                  );
                                },
                              ),
                            );
                            ;
                          });
                    });
              },
            );
          },
          error: (err, stack) => const Center(
                child: Text('データを取得できませんでした'),
              ),
          loading: () => const Center(
                child: CircularProgressIndicator(),
              ));
    },
  );
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

Stream<QuerySnapshot> getReadUserList(String receiverId) {
  List<String> ids = [currentUserId, receiverId];
  ids.sort();
  String chatRoomId = ids.join("_");

  return _firestore
      .collection('chat_rooms')
      .doc(chatRoomId)
      .collection('messages')
      .orderBy('timestamp', descending: true)
      .limit(10)
      .snapshots();
}
