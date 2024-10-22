import 'package:academyteacher/Authentication/myHomePage.dart';
import 'package:academyteacher/Authentication/singupPage.dart';
import 'package:academyteacher/LIve/resources/auth_methods.dart';
import 'package:academyteacher/Authentication/NaivtaorPage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';

class LoginPage extends StatelessWidget {
  final AuthMethods _authMethods = AuthMethods();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _login(BuildContext context) async {
    try {
      final email = _emailController.text;
      final password = _passwordController.text;

      // Check if the user exists in the Firestore "teachers" collection
      final querySnapshot = await FirebaseFirestore.instance
          .collection('teachers')
          .where('email', isEqualTo: email)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // User exists in Firestore, proceed with login
        bool signInSuccess = await _authMethods.signInWithEmailPassword(
          email,
          password,
          context,
        );

        if (signInSuccess) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => NavigatorPage(
              ),
            ),
          );
        }
      } else {
        // User doesn't exist in Firestore
        print("User not found in 'teachers' collection");
      }
    } catch (e) {
      print("Error: $e");
      // Handle login error, you can show a snackbar or error message here.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: LottieBuilder.network(
                      'https://lottie.host/e96a5b09-99c0-4265-8663-ab96589b607b/OoobGvDZfT.json'),
                ),
                Center(
                  child: Text(
                    "Verify Yourself as a Teacher",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: "Email",
                    prefixIcon: Icon(Icons.email),
                  ),
                ),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: "Password",
                    prefixIcon: Icon(Icons.key),
                  ),
                  obscureText: true, // Hide the password text
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _login(context),
                  child: Text("Login"),
                ),
                SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SignUpPage(),
                      ),
                    );
                  },
                  child: Text("Don't have an account? Sign up"),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
