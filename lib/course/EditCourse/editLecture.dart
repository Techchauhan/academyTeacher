import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';


class EditLecturePage extends StatefulWidget {
  final String courseId;
  final String chapterId;
  final String lectureId;

  EditLecturePage({required this.courseId, required this.chapterId, required this.lectureId});

  @override
  _EditLecturePageState createState() => _EditLecturePageState();
}

class _EditLecturePageState extends State<EditLecturePage> {
  String lectureTitle = '';
  String videoUrl = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Lecture'),
      ),
      body: Column(
        children: [
          TextField(
            decoration: InputDecoration(labelText: 'Lecture Title'),
            onChanged: (value) {
              setState(() {
                lectureTitle = value;
              });
            },
          ),
          TextField(
            decoration: InputDecoration(labelText: 'YouTube Link'),
            onChanged: (value) {
              setState(() {
                videoUrl = value;
              });
            },
          ),
          ElevatedButton(
            onPressed: () {
              _updateLecture();
            },
            child: Text('Save Changes'),
          ),
        ],
      ),
    );
  }

  void _updateLecture() {
    FirebaseDatabase.instance
        .reference()
        .child('courses')
        .child(widget.courseId)
        .child('chapters')
        .child(widget.chapterId)
        .child('lectures')
        .child(widget.lectureId)
        .set({
      'title': lectureTitle,
      'videoUrl': videoUrl,
    });

    Navigator.pop(context); // Return to previous page
  }
}