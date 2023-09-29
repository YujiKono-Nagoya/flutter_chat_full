import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_full/components/my_text_field.dart';
import 'package:flutter_chat_full/pages/account_setting_page.dart';
import 'package:flutter_chat_full/services/auth/auth_gate.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/chat/chat_service.dart';
import 'chat_page.dart';
import 'exsample_page.dart';

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

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  Widget build(
    BuildContext context,
  ) {
    final keyword = ref.watch(keywordProvider);
    String keywordtext = _nameSerchController.text;
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Home Page'),
      //   actions: [
      //     IconButton(
      //       onPressed: () async {
      //         await FirebaseAuth.instance.signOut();
      //       },
      //       icon: Icon(Icons.logout),
      //     ),
      //   ],
      // ),
      body: SingleChildScrollView(child: SafeArea(
        child: Consumer(
          builder: (BuildContext context, WidgetRef ref, Widget? child) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '友達',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 25),
                      ),
                      IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AccountPage()),
                            );
                          },
                          icon: Icon(Icons.edit))
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Container(
                      decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(5)),
                      child: Row(
                        children: [
                          SizedBox(width: 10),
                          Icon(Icons.search),
                          SizedBox(width: 10),
                          Flexible(
                            child: TextFormField(
                              controller: _nameSerchController, // 初期値を変数から取得
                              decoration: InputDecoration(
                                suffixIcon: _searchValue.isEmpty
                                    ? SizedBox()
                                    : IconButton(
                                        onPressed: () {
                                          setState(() {
                                            _searchValue = '';
                                          });
                                          setState(() {
                                            _nameSerchController.clear();
                                            // 値をクリア
                                          });
                                        },
                                        icon: Icon(
                                          Icons.cancel,
                                        ),
                                      ),
                                border: InputBorder.none,
                                hintText: '検索',
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _searchValue = value; // テキストが変更されたときに変数にセット
                                });
                              },
                            ),
                          ),
                        ],
                      )),
                ),
                SizedBox(height: 20),
                // _buildUserList(),

                _buildUserList2(),
                // _buildUserList3(serchValue: _searchValue)
                // _buildUserList4()
              ],
            );
          },
        ),
      )),
    );
  }
}

Widget _buildUserList2() {
  return SingleChildScrollView(
    child: Consumer(
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
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
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
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(color: Colors.grey),
                                ),
                              ),
                              child: ListTile(
                                title: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            imageUrl == ''
                                                ? ClipOval(
                                                    child: Container(
                                                    width: 50,
                                                    height: 50,
                                                    color: Colors.amber,
                                                    child: CircleAvatar(
                                                      radius: 64,
                                                      backgroundImage: NetworkImage(
                                                          'https://www.pngitem.com/pimgs/m/421-4212266_transparent-default-avatar-png-default-avatar-images-png.png'),
                                                    ),
                                                  ))
                                                : ClipOval(
                                                    child: Image.network(
                                                      imageUrl,
                                                      width:
                                                          50, // 画像の幅を調整する場合、必要に応じて変更してください
                                                      height:
                                                          50, // 画像の高さを調整する場合、必要に応じて変更してください
                                                      fit: BoxFit
                                                          .cover, // 画像をウィジェットにフィットさせる方法を指定します
                                                    ),
                                                  ),
                                            SizedBox(width: 10),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  user['name'],
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 20),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        Icon(Icons.arrow_forward_ios),
                                      ],
                                    )
                                  ],
                                ),
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
                                          imageUrl == ''
                                              ? ClipOval(
                                                  child: Container(
                                                  width: 70,
                                                  height: 70,
                                                  color: Colors.amber,
                                                  child: CircleAvatar(
                                                    radius: 64,
                                                    backgroundImage: NetworkImage(
                                                        'https://www.pngitem.com/pimgs/m/421-4212266_transparent-default-avatar-png-default-avatar-images-png.png'),
                                                  ),
                                                ))
                                              : ClipOval(
                                                  child: Image.network(
                                                    imageUrl,
                                                    width:
                                                        50, // 画像の幅を調整する場合、必要に応じて変更してください
                                                    height:
                                                        50, // 画像の高さを調整する場合、必要に応じて変更してください
                                                    fit: BoxFit
                                                        .cover, // 画像をウィジェットにフィットさせる方法を指定します
                                                  ),
                                                ),
                                          SizedBox(width: 10),
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
                                                  stream: getMessageData(
                                                      user['uid']),
                                                  builder:
                                                      ((context, snapshot) {
                                                    if (snapshot
                                                            .connectionState ==
                                                        ConnectionState
                                                            .waiting) {
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
    ),
  );
}

Widget _buildUserList3({required String serchValue}) {
  return Consumer(builder: (context, ref, child) {
    final keyword = ref.watch(keywordProvider);
    return StreamBuilder(
      stream: usersStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('error');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('loading..');
        }

        return Column(
          children: snapshot.data!.docs
              .where((element) => (element['name'].contains(serchValue)))
              .map<Widget>((doc) => _buildUserListItem(doc, context))
              .toList(),
        );
      },
    );
  });
}

//build individual user list items

Widget _buildUserListItem(DocumentSnapshot document, BuildContext context) {
  //どうやってドキュメントの判別をしている？ streamでusersを指定？
  Map<String, dynamic> userData = document.data()! as Map<String, dynamic>;

  if (userData['email'] == null) {
    // userDataがNullかemailがNullの場合に対するエラーハンドリング
    return Container();
  }

  if (userData['name'] == null) {
    return Container();
  }

  if (userData['uid'] == null) {
    return Container();
  }

  if ((_auth.currentUser!.email != userData['email'])) {
    return StreamBuilder<Map<String, dynamic>>(
      stream: getMessageData(userData['uid']),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text('Loading latest message...');
        }

        if (snapshot.hasError) {
          return Text('');
        }
        Map<String, dynamic> readUserData = snapshot.data!;
        String latestmessage = readUserData['latestmessage'];
        String readUser = readUserData['readUser'];
        Timestamp latesttimestamp = readUserData['latesttimestamp'];

        void _addReadUser() {
          if (readUser != currentUserId &&
              readUser != currentUserId + ', ' + userData['uid']) {
            _chatService.sendreadUser(userData['uid'], latesttimestamp,
                currentUserId + ', ' + userData['uid'], latestmessage);
          }
        }

        return StreamBuilder<QuerySnapshot>(
            stream: getReadUserList(userData['uid']),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Text('Loading latest message...');
              }

              if (snapshot.hasError) {
                return Text('');
              }

              final messagesData = snapshot.data!.docs;
              List<String> readUserList = messagesData
                  .map((doc) => (doc['readUser'] as List).join(', '))
                  .toList();

              int readUserCount = 0;

              if (readUserData['readUser'] ==
                  currentUserId + ', ' + userData['uid']) {
                readUserCount = 0;
              }

              for (String userId in readUserList) {
                if (readUser != currentUserId &&
                    readUser != currentUserId + ', ' + userData['uid'] &&
                    userId != currentUserId &&
                    userId != currentUserId + ', ' + userData['uid']) {
                  readUserCount++;
                } else {
                  break; // currentUserId を見つけたらループを終了
                }
              }
              String readUserCountString = readUserCount.toString();

              return Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey),
                  ),
                ),
                child: ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Image.asset(
                            userData['image'],
                            scale: 5,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userData['name'],
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20),
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
                                child: StreamBuilder<Map<String, dynamic>>(
                                  stream: getMessageData(userData['uid']),
                                  builder: ((context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return Text('Loading latest message...');
                                    }

                                    if (snapshot.hasError) {
                                      return Text('');
                                    }

                                    Map<String, dynamic>? messageData =
                                        snapshot.data!;
                                    if (messageData['latesttimestamp'] ==
                                        null) {
                                      return Text('');
                                    }

                                    Timestamp timestamp =
                                        messageData['latesttimestamp'];
                                    DateTime dateTime = timestamp.toDate();
                                    String sendtime =
                                        DateFormat('HH:mm').format(dateTime);
                                    String sendate =
                                        DateFormat('MM/dd').format(dateTime);
                                    return Text(sendate);
                                  }),
                                ),
                              ),
                              readUserCount == 0
                                  ? SizedBox()
                                  : SizedBox(
                                      child: Container(
                                          decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.orange),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              readUserCountString,
                                              style: TextStyle(
                                                  color: Colors.white),
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
                            receiverUserEmail: userData['email'],
                            receiverUserID: userData['uid'],
                            readUserList: readUserList,
                            userName: userData['name'])),
                      ),
                    );
                  },
                ),
              );
            });
      },
    );

    // return Column(
    //   children: [
    //     Column(
    //       children:
    //           readUserList.map((readUser) => Text(readUser)).toList(),
    //     ),
    //     Text(readUserCountString)
    //   ],
    // );
  } else {
    return Container();
  }
}

Widget _buildUserList4() {
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
                return Card(
                  child: Container(
                    child: Column(
                      children: [
                        Expanded(
                          child: Text(user['name']),
                        ),
                      ],
                    ),
                  ),
                );
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

  // return FirebaseFirestore.instance
  //     .collection('chat_rooms')
  //     .doc(chatRoomId)
  //     .collection('latestmessage')
  //     .doc('latestmessage')
  //     .snapshots()
  //     .map((snapshot) => snapshot.data() as Map<String, dynamic>);
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

StreamBuilder<QuerySnapshot> getMessages() {
  Stream<QuerySnapshot> userDocStream =
      FirebaseFirestore.instance.collection('users').snapshots();
  return StreamBuilder<QuerySnapshot>(
    stream: userDocStream,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return CircularProgressIndicator();
      }

      if (!snapshot.hasData) {
        return Text('No data available');
      }

      QueryDocumentSnapshot userDocument =
          snapshot.data!.docs[0]; // Accessing the first document

      if (!userDocument.exists) {
        return Text('User document does not exist');
      }

      Map<String, dynamic> userData =
          userDocument.data() as Map<String, dynamic>;
      String userId =
          userData['uid']; // Assuming 'uid' field exists in the document

      return Text('User ID: $userId');
    },
  );
}
