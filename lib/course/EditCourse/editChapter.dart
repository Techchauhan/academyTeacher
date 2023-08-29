import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';


class EditChapterPage extends StatefulWidget {
  final String courseId;
  final String chapterId;

  EditChapterPage({required this.courseId, required this.chapterId});

  @override
  _EditChapterPageState createState() => _EditChapterPageState();
}

class _EditChapterPageState extends State<EditChapterPage> {
  String chapterTitle = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Chapter'),
      ),
      body: Column(
        children: [
          TextField(
            decoration: InputDecoration(labelText: 'Chapter Title'),
            onChanged: (value) {
              setState(() {
                chapterTitle = value;
              });
            },
          ),
          ElevatedButton(
            onPressed: () {
              _updateChapter();
            },
            child: Text('Save Changes'),
          ),
        ],
      ),
    );
  }

  void _updateChapter() {
    FirebaseDatabase.instance
        .reference()
        .child('courses')
        .child(widget.courseId)
        .child('chapters')
        .child(widget.chapterId)
        .child('title')
        .set(chapterTitle);

    Navigator.pop(context); // Return to previous page
  }
}