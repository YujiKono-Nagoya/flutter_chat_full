// import 'package:flutter/material.dart';
// import 'package:flutter_chat_full/pages/login_page.dart';
// import 'package:flutter_chat_full/pages/register_pages.dart';

// class LoginOrRegister extends StatefulWidget {
//   const LoginOrRegister({super.key});

//   @override
//   State<LoginOrRegister> createState() => _LoginOrRegisterState();
// }

// class _LoginOrRegisterState extends State<LoginOrRegister> {
//   // initiallly show the login screen
//   bool showLoginPage = true;

//   //togglr between login and register page
//   void togglePages() {
//     setState(() {
//       showLoginPage = !showLoginPage;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (showLoginPage) {
//       return LoginPage(onTap: togglePages);
//     } else {
//       return RegisterPage(onTap: togglePages);
//     }
//   }
// }
