import 'package:academyteacher/Authentication/myHomePage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HelpAndSupportPage extends StatelessWidget {
  const HelpAndSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Frequently Asked Questions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
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

            const Divider(),

            const Text(
              'Contact Support',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ListTile(
              leading: const Icon(Icons.email),
              title: const Text('Email Support'),
              subtitle: const Text('support@teacingacademy.com'),
              onTap: () {
                // Open email app with pre-filled support email
                // You can use the "url_launcher" package for this.
              },
            ),
            ListTile(
              leading: const Icon(Icons.phone),
              title: const Text('Phone Support'),
              subtitle: const Text('+91 6396219233'),
              onTap: () {
                // Open phone dialer with pre-filled support phone number
                // You can use the "url_launcher" package for this.
              },
            ),
            // Add more contact options as needed
          ],
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
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(answer),
        ),
      ],
    );
  }
}


