import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_full/components/my_button.dart';
import 'package:flutter_chat_full/components/my_text_field.dart';
import 'package:flutter_chat_full/utils.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:flutter_chat_full/utils.dart';
// import 'package:image_picker_web/image_picker_web.dart';

import '../services/chat/chat_service.dart';
import 'package:flutter_chat_full/resources/add.data.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;
final ChatService _chatService = ChatService();
final String currentUserId = _auth.currentUser!.uid;
final StoreData _storeData = StoreData();

class AccountPage extends StatefulWidget {
  AccountPage({
    Key? key,
  }) : super(key: key);

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final _nameController = TextEditingController();

  Uint8List? _image;

  void selectImage() async {
    Uint8List img = await pickImage(ImageSource.gallery);
    setState(() {
      _image = img;
    });
  }

  void cameraImage() async {
    Uint8List img = await pickImage(ImageSource.camera);
    setState(() {
      _image = img;
    });
  }

  void saveProfile() async {
    String name = _nameController.text;

    String resp = await StoreData().saveData(name: name, file: _image!);
  }

  // void selectImage() async {
  //   Uint8List img = await pickImage2(source)
  // }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SizedBox(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('users').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text('エラー: ${snapshot.error}');
              }
              if (!snapshot.hasData || snapshot.data == null) {
                return Text('データがありません');
              }
              final usersData = snapshot.data!.docs;

              // ユーザー情報を取得
              Map<String, dynamic> userData = {};
              for (final userDoc in usersData) {
                final userMap = userDoc.data() as Map<String, dynamic>;
                if (userMap['uid'] == currentUserId) {
                  userData = userMap;
                  break;
                }
              }

              final String imageUrl = userData['image'];

              return SafeArea(
                child: Column(
                  children: [
                    Row(children: [
                      IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Icon(Icons.arrow_back)),
                      SizedBox(width: 20),
                      Text(
                        'アカウント設定',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      )
                    ]),
                    SizedBox(height: 20),
                    Stack(
                      children: [
                        imageUrl == ''
                            ? ClipOval(
                                child: Container(
                                width: 100,
                                height: 100,
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
                                  width: 100, // 画像の幅を調整する場合、必要に応じて変更してください
                                  height: 100, // 画像の高さを調整する場合、必要に応じて変更してください
                                  fit:
                                      BoxFit.cover, // 画像をウィジェットにフィットさせる方法を指定します
                                ),
                              ),
                        Positioned(
                            right: 2,
                            bottom: 2,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.orange,
                              ),
                              child: IconButton(
                                  iconSize: 10,
                                  icon: Icon(
                                    Icons.mode_edit,
                                    color: Colors.white,
                                  ),
                                  onPressed: selectImage),
                            )),
                      ],
                    ),
                    SizedBox(height: 20),
                    MyTextField(
                      controller: _nameController,
                      hintText: '',
                      watch: false,
                    ),
                    SizedBox(height: 100),
                    MyButton(
                      onTap: saveProfile, // プロフィールを更新
                      text: 'プロフィールを更新',
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
      // floatingActionButton: FloatingActionButton(onPressed: () {
      //   Navigator.push(
      //     context,
      //     MaterialPageRoute(builder: (context) => ImagePage()),
      //   );
      // }),
    );
  }
}
