import 'package:academyteacher/LIve/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authChanges => _auth.authStateChanges();
  User get user => _auth.currentUser!;

  Future<bool> signInWithEmailPassword(
      String email, String password, BuildContext context) async {
    bool res = false;
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('teachers')
          .where('email', isEqualTo: email)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // User exists in Firestore, proceed with login
        UserCredential userCredential =
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        User? user = userCredential.user;
        if (user != null) {
          res = true;
        } else {
          // Handle the case where userCredential.user is null
          res = false;
        }
      } else {
        // User does not exist in the Firestore "teachers" collection
        // You might want to show an error message or take appropriate action
        showSnackBar(context, 'User not found by LIVE');
        res = false;
      }
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message!);
      res = false;
    }
    return res;
  }
}
