import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_full/pages/login_page.dart';
import 'package:flutter_chat_full/pages/register_pages.dart';

import '../../pages/home_page.dart';

// class AuthGate extends StatelessWidget {
//   const AuthGate({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: StreamBuilder(
//         stream: FirebaseAuth.instance.authStateChanges(),
//         builder: (context, snapshot) {
//           // user is logged in
//           if (snapshot.hasData) {
//             return const HomePage();
//           }

//           // user is Not logged in
//           else {
//             return const LoginOrRegister();
//           }
//         },
//       ),
//     );
//   }
// }

class AuthGate2 extends StatefulWidget {
  const AuthGate2({super.key});

  @override
  State<AuthGate2> createState() => _AuthGate2State();
}

class _AuthGate2State extends State<AuthGate2> {
  bool _isSinedIn = false;
  String userId = '';

  void checkSignInState() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        setState(() {
          _isSinedIn = false;
        });
      } else {
        userId = user.uid;
        setState(() {
          _isSinedIn = true;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    checkSignInState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(),
      body: _isSinedIn ? HomePage() : RegisterPage(),
    );
  }
}
