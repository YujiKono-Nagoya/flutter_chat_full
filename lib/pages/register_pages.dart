import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_full/resources/add.data.dart';
import 'package:flutter_chat_full/services/auth/auth_service.dart';
import 'package:provider/provider.dart';

import '../components/my_button.dart';
import '../components/my_text_field.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({
    super.key,
  });

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  //text
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmpasswordController = TextEditingController();

  bool alreadySignedUp = false;

  void signUp() async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .set({
        'email': emailController.text.trim(),
        'name': '', // ユーザーに入力させた名前を取得する
        'image': '', // デフォルトの画像パスを指定する
        'uid': userCredential.user!.uid
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('既に使用されているメールアドレスです'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ));
      } else if (e.code == 'weak-password') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('パスワードは最低でも６文字以上です'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ));
      } else if (e.code == 'invalid-email') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('メールアドレスが正しくありません'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ));
      }
    }
  }

  void signIn() async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('登録されていないメールアドレスです'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ));
      } else if (e.code == 'wrong-password') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('パスワードが違います'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ));
      } else if (e.code == 'invalid-email') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('メールアドレスが正しくありません'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ));
      }
    }
  }

  Future<void> _addUserToFirestore({
    required String email,
    required String name,
    required String image,
  }) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // ユーザー情報をFirestoreに追加
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'email': email,
        'uid': user.uid,
        'name': name,
        'image': image,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 50),
                //logo
                Text('Chat App',
                    style:
                        TextStyle(fontSize: 50, fontWeight: FontWeight.bold)),

                const SizedBox(height: 50),

                //email textfield
                MyTextField(
                  controller: emailController,
                  hintText: 'Email',
                  watch: false,
                ),

                const SizedBox(height: 10),

                //password textField
                MyTextField(
                  controller: passwordController,
                  hintText: 'Password',
                  watch: true,
                ),

                // confirm passwword textField

                const SizedBox(height: 200),
                //sugn in button
                alreadySignedUp
                    ? MyButton(onTap: signIn, text: 'ログイン')
                    : MyButton(onTap: signUp, text: '新規作成'),

                const SizedBox(height: 30),

                //not a member? register now
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('アカウントをお持ちではありませんか？'),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          alreadySignedUp = !alreadySignedUp;
                        });
                      },
                      child: TextButton(
                          onPressed: () {
                            setState(() {
                              alreadySignedUp = !alreadySignedUp;
                            });
                          },
                          child: Text(
                            alreadySignedUp ? '新しくアカウントを作成' : '既にアカウントをお持ちですか',
                            style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold),
                          )),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
