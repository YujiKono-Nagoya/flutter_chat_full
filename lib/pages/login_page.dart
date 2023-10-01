// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_chat_full/components/my_button.dart';
// import 'package:flutter_chat_full/components/my_text_field.dart';
// import 'package:flutter_chat_full/services/auth/auth_service.dart';
// import 'package:provider/provider.dart';

// import 'exsample_page.dart';

// class LoginPage extends StatefulWidget {
//   final void Function()? onTap;
//   const LoginPage({super.key, required this.onTap});

//   @override
//   State<LoginPage> createState() => _LoginPageState();
// }

// class _LoginPageState extends State<LoginPage> {
//   final emailController = TextEditingController();
//   final passwordController = TextEditingController();

//   // カスタムSnackBarウィジェット
//   Widget _customSnackBar(String message) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 10), // 左右に10の空白を追加
//       child: Container(
//         decoration: BoxDecoration(
//           color: Colors.grey[200], // グレーの背景色
//           borderRadius: BorderRadius.circular(8), // 角丸の設定
//           boxShadow: [
//             BoxShadow(
//               color: Colors.grey[400]!, // 影の色
//               blurRadius: 2, // ブラー半径
//               offset: Offset(0, 2), // 影のオフセット（位置）
//             ),
//           ],
//         ),
//         child: SnackBar(
//           content: Text(message),
//           duration: const Duration(seconds: 2),
//           backgroundColor: Colors.transparent, // SnackBar自体の背景色は透明にする
//         ),
//       ),
//     );
//   }

//   // sign in user
//   void signIn() async {
//     try {
//       await FirebaseAuthService().signInWithEmailAndPassword(
//         email: emailController.text.trim(),
//         password: passwordController.text.trim(),
//       );

//       // await _addUserToFirestore();
//     } on FirebaseAuthException catch (e) {
//       if (e.code == 'user-not-found') {
//         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//           elevation: 20,
//           behavior: SnackBarBehavior.floating,
//           margin: EdgeInsets.all(20),
//           content: Text('登録されていないメールアドレスです'),
//           backgroundColor: Colors.red,
//           duration: Duration(seconds: 2),
//         ));
//       } else if (e.code == 'wrong-password') {
//         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//           elevation: 20,
//           behavior: SnackBarBehavior.floating,
//           margin: EdgeInsets.all(20),
//           content: Text('パスワードが間違ってます'),
//           backgroundColor: Colors.red,
//           duration: Duration(seconds: 2),
//         ));
//       } else if (e.code == 'invalid-email') {
//         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//           elevation: 2,
//           behavior: SnackBarBehavior.floating,
//           margin: EdgeInsets.all(20),
//           content: Text('メールアドレスが正しくありません'),
//           backgroundColor: Colors.red,
//           duration: Duration(seconds: 2),
//         ));
//       }
//     }
//   }

//   // Future<void> _addUserToFirestore() async {
//   //   User? user = FirebaseAuth.instance.currentUser;
//   //   if (user != null) {
//   //     // ユーザー情報をFirestoreに追加
//   //     await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
//   //       'name': '',
//   //       'image': 'images/iconImage/defaultIcon.png',
//   //     });
//   //   }
//   // }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: Center(
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 15),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const SizedBox(height: 50),
//                 //logo
//                 Text('Chat App',
//                     style:
//                         TextStyle(fontSize: 50, fontWeight: FontWeight.bold)),

//                 const SizedBox(height: 50),

//                 //email textfield
//                 MyTextField(
//                   controller: emailController,
//                   hintText: 'Email',
//                   watch: false,
//                 ),

//                 const SizedBox(height: 10),

//                 //password textField
//                 MyTextField(
//                   controller: passwordController,
//                   hintText: 'Password',
//                   watch: true,
//                 ),

//                 const SizedBox(height: 100),

//                 //sugn in button
//                 MyButton(onTap: signIn, text: 'ログイン'),

//                 const SizedBox(height: 25),

//                 //not a member? register now
//                 Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     const Text('アカウントをお持ちではありませんか？'),
//                     const SizedBox(height: 10),
//                     GestureDetector(
//                       onTap: widget.onTap,
//                       child: Text(
//                         'アカウントの作成はこちら',
//                         style: TextStyle(
//                             fontWeight: FontWeight.bold, color: Colors.blue),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
