import 'package:academyteacher/Authentication/NaivtaorPage.dart';
import 'package:academyteacher/Authentication/loginPage.dart';
import 'package:academyteacher/Authentication/myHomePage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          User? user = snapshot.data;
          if (user == null) {
            return LoginPage();
          } else {
            return NavigatorPage();
          }
        }
        return const CircularProgressIndicator();
      },
    );
  }
}
