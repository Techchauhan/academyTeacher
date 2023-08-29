import 'package:flutter/material.dart';

class LectureDetailsPage extends StatelessWidget {
  final String lectureTitle;
  final String videoUrl;

  LectureDetailsPage({required this.lectureTitle, required this.videoUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lecture Details'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              lectureTitle,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(videoUrl),
          ],
        ),
      ),
    );
  }
}