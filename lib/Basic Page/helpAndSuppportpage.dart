import 'package:academyteacher/myHomePage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HelpAndSupportPage extends StatelessWidget {
  const HelpAndSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Handle the back button press here
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>MyHomePage(user: FirebaseAuth.instance.currentUser!.uid))); // This pops the current page
        return false; // Return false to prevent app from closing
      },
      child: Scaffold(
        appBar: AppBar(
          leading: BackButton(
            onPressed: (){
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>MyHomePage(user: FirebaseAuth.instance.currentUser!.uid))); // This pops the current page
            },
          ),
          title: Text('Help & Support'),
        ),
        body: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Frequently Asked Questions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              // List of frequently asked questions
              FAQItem(
                question: 'How do I create a new course?',
                answer: 'To create a new course, go to the Courses section...',
              ),
              FAQItem(
                question: 'What is a live session?',
                answer: 'A live session allows you to interact...',
              ),
              // Add more FAQ items as needed

              Divider(),

              Text(
                'Contact Support',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              ListTile(
                leading: Icon(Icons.email),
                title: Text('Email Support'),
                subtitle: Text('support@teacingacademy.com'),
                onTap: () {
                  // Open email app with pre-filled support email
                  // You can use the "url_launcher" package for this.
                },
              ),
              ListTile(
                leading: Icon(Icons.phone),
                title: Text('Phone Support'),
                subtitle: Text('+91 6396219233'),
                onTap: () {
                  // Open phone dialer with pre-filled support phone number
                  // You can use the "url_launcher" package for this.
                },
              ),
              // Add more contact options as needed
            ],
          ),
        ),
      ),
    );
  }
}

class FAQItem extends StatelessWidget {
  final String question;
  final String answer;

  FAQItem({required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(question),
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(answer),
        ),
      ],
    );
  }
}


